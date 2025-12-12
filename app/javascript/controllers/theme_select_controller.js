import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu", "input", "button", "label", "dot"]

    toggle() {
        this.menuTarget.classList.toggle("hidden")
    }

    select(event) {
        const value = event.currentTarget.dataset.themeSelectValue

        // update field
        this.inputTarget.value = value

        // update label
        this.labelTarget.textContent = value

        // update dot color
        const dot = event.currentTarget.querySelector("span span")
        this.dotTarget.style.backgroundColor = dot.style.backgroundColor

        // close
        this.menuTarget.classList.add("hidden")
    }
}
