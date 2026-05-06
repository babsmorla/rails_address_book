import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.dialogTarget.showModal()
  }

  // Close the modal and clear the turbo frame
  close() {
    this.dialogTarget.close()
    const frame = document.getElementById("modal")
    frame.removeAttribute("src")
    frame.innerHTML = ""
  }

  // Close if clicking outside the modal content
  clickOutside(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}