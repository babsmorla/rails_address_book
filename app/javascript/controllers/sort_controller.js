// app/javascript/controllers/sort_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    currentDir: String,
    frameId: String
  }

  toggle(event) {
    event.preventDefault()

    // 1. Determine the next direction
    const nextDir = this.currentDirValue === "asc" ? "desc" : "asc"

    // 2. Build the new URL based on current browser location
    const url = new URL(window.location.href)
    url.searchParams.set("sort", nextDir)

    // 3. Find the turbo frame and change its source
    const frame = document.getElementById(this.frameIdValue)
    if (frame) {
      frame.src = url.toString()

      // 4. Update the browser URL bar (optional but recommended)
      window.history.pushState({}, "", url.toString())

      // 5. Update the controller value so the next click flips correctly
      this.currentDirValue = nextDir

      // 6. Optional: Update the UI text/icon manually if needed
      this.updateUI(nextDir)
    }
  }

  updateUI(dir) {
    const label = this.element.querySelector("[data-sort-label]")
    if (label) label.innerText = dir === "asc" ? "A-Z" : "Z-A"
  }
}