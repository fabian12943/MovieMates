import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "submit", "comment" ]

  connect() {
      this.submitTarget.style.display = "none"
  }

  showSubmitButton() {
    this.submitTarget.style.display = "block"
  }

  hideSubmitButton(element) {
    var form_textarea = element.target
    if (form_textarea.value.trim() == "") {
      form_textarea.value = ""
      this.submitTarget.style.display = "none"
    }
  }

}