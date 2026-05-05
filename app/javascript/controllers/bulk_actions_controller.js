import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. Added "exportButton" to targets
  static targets = ["checkbox", "addButton", "deleteButton", "exportSelectedText", "selectAllText", "exportButton"]

  connect() {
    this.update()
  }

  update() {
    // Unique IDs set to handle desktop + mobile duplicates
    const selectedIds = new Set(
      this.checkboxTargets
        .filter(cb => cb.checked)
        .map(cb => cb.value)
    )
    
    const selectedCount = selectedIds.size
    const anyChecked = selectedCount > 0
    
    // Logic for "allChecked" needs to account for unique IDs vs total unique checkboxes
    const totalUniqueItems = new Set(this.checkboxTargets.map(cb => cb.value)).size
    const allChecked = selectedCount === totalUniqueItems && totalUniqueItems > 0

    // 1. Swap "Add Contact" with "Delete Selected"
    if (this.hasAddButtonTarget && this.hasDeleteButtonTarget) {
      this.addButtonTarget.classList.toggle("hidden", anyChecked)
      this.deleteButtonTarget.classList.toggle("hidden", !anyChecked)
    }

    // 2. Update and Disable/Enable Export Button
    if (this.hasExportSelectedTextTarget && this.hasExportButtonTarget) {
      this.exportSelectedTextTarget.innerText = anyChecked ? `Export Selected (${selectedCount})` : "Export Selected"
      
      // Disable the button if nothing is checked
      this.exportButtonTarget.disabled = !anyChecked
      
      // Visual feedback: Make it look unclickable
      if (anyChecked) {
        this.exportButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
        this.exportButtonTarget.classList.add("hover:bg-gray-50")
      } else {
        this.exportButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
        this.exportButtonTarget.classList.remove("hover:bg-gray-50")
      }
    }

    // 3. Update Mobile "Select All" Button Text
    if (this.hasSelectAllTextTarget) {
      this.selectAllTextTarget.innerText = allChecked ? "Deselect All" : "Select All"
    }
  }

  toggleAll(e) {
    const currentSelectedCount = new Set(this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)).size
    const totalUniqueItems = new Set(this.checkboxTargets.map(cb => cb.value)).size
    
    const isChecked = e.target.type === "checkbox" 
      ? e.target.checked 
      : (currentSelectedCount !== totalUniqueItems)
    
    this.checkboxTargets.forEach(cb => cb.checked = isChecked)
    this.update()
  }
}