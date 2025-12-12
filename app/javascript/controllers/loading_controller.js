import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["spinner"]

    show() {
        this.spinnerTarget.classList.remove("hidden")
    }

    hide() {
        this.spinnerTarget.classList.add("hidden")
    }
}