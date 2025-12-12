// app/javascript/controllers/auto_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.timeout = null
    }

    submit() {
        clearTimeout(this.timeout)

        // Debounce for search input (wait 300ms after user stops typing)
        this.timeout = setTimeout(() => {
            this.element.requestSubmit()
        }, 300)
    }

    disconnect() {
        clearTimeout(this.timeout)
    }
}