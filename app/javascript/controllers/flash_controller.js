import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
   
    if (this.element.showPopover) {
      this.element.showPopover()
    }

    // 2. Set a timer to start the fade out after 3 seconds
    setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  dismiss() {

    this.element.classList.add("hiding")

    // 4. Wait for the animation to finish, then remove the element from the page
    this.element.addEventListener("animationend", () => {
      this.element.remove()
    }, { once: true })
  }
}