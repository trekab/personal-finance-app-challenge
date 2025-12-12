// app/javascript/controllers/character_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "counter"]
    static values = {
        max: { type: Number, default: 30 }
    }

    connect() {
        this.updateCounter()
    }

    updateCounter() {
        const currentLength = this.inputTarget.value.length
        const remaining = this.maxValue - currentLength

        this.counterTarget.textContent = `${remaining} characters left`

        // Optional: Change color when approaching limit
        if (remaining <= 5) {
            this.counterTarget.classList.add('text-red-500')
            this.counterTarget.classList.remove('text-gray-500')
        } else {
            this.counterTarget.classList.add('text-gray-500')
            this.counterTarget.classList.remove('text-red-500')
        }
    }
}