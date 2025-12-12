// app/javascript/controllers/frequency_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["dayOfMonth", "dayOfWeek"]

    connect() {
        // Set initial state based on current value
        this.toggle()
    }

    toggle() {
        const frequencyType = this.element.querySelector('select[name="recurring_bill[frequency_type]"]').value

        if (frequencyType === 'Monthly' || frequencyType === 'Yearly') {
            this.dayOfMonthTarget.classList.remove('hidden')
            this.dayOfWeekTarget.classList.add('hidden')
        } else if (frequencyType === 'Weekly') {
            this.dayOfMonthTarget.classList.add('hidden')
            this.dayOfWeekTarget.classList.remove('hidden')
        } else {
            this.dayOfMonthTarget.classList.add('hidden')
            this.dayOfWeekTarget.classList.add('hidden')
        }
    }
}