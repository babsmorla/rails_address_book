import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  submit() {
    // Clear the previous timer so we don't spam the server
    clearTimeout(this.timeout)

    // Wait 300ms after the user stops typing before submitting
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}