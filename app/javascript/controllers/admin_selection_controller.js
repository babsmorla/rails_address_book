import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "createActions", "bulkActions", "count"]

  connect() {
    this.updateUI()
  }

  // Toggles all checkboxes when the header checkbox is clicked
  toggleAll() {
    const isChecked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })
    this.updateUI()
  }

  // Shows/Hides the button groups based on selection
  updateUI() {
    const selectedCount = this.checkboxTargets.filter(c => c.checked).length

    if (selectedCount > 0) {
      this.createActionsTarget.classList.add("hidden")
      this.bulkActionsTarget.classList.remove("hidden")
      // Update the count span in the export/delete buttons
      this.countTargets.forEach(el => el.textContent = `(${selectedCount})`)
    } else {
      this.createActionsTarget.classList.remove("hidden")
      this.bulkActionsTarget.classList.add("hidden")
      if (this.hasSelectAllTarget) this.selectAllTarget.checked = false
    }
  }

  reset() {
    // 1. Clear all individual row checkboxes
    this.checkboxTargets.forEach(cb => cb.checked = false)

    // 2. Clear the master "Select All" checkbox
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = false
    }

    // 3. Update the UI visibility (Fix: called updateUI instead of update)
    this.updateUI()
  }
}