import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "form" ]

  // Increases by 10 and submits
  increment() {
    let value = parseInt(this.inputTarget.value)
    if (value < 100) {
      this.inputTarget.value = value + 5
      this.submitForm()
    }
  }

  // Decreases by 10 and submits
  decrement() {
    let value = parseInt(this.inputTarget.value)
    if (value > 5) {
      this.inputTarget.value = value - 5
      this.submitForm()
    }
  }

  submitForm() {
    // requestSubmit() triggers the Turbo submission correctly
    this.formTarget.requestSubmit()
  }
}