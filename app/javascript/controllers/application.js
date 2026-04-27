import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }


document.addEventListener("turbo:load", () => {
  const selectAll = document.getElementById("select_all_contacts");
  const checkboxes = document.querySelectorAll(".contact-checkbox");

  if (selectAll) {
    selectAll.addEventListener("change", (e) => {
      checkboxes.forEach(cb => cb.checked = e.target.checked);
    });
  }
});