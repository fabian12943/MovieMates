import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "selectedYear" ]

    connect() {
        this.filmographyLists = document.getElementsByClassName("filmography-list")
    }

    selectYear() {
        this.selectedYearTarget.value != 0 ? this.showYear(this.selectedYearTarget.value) : this.showAll()
    }

    showYear(year) {
        for (var filmographyList of this.filmographyLists) {
            if (filmographyList.id == "filmography-" + year) {
                filmographyList.classList.remove("d-none")
            } else {
                filmographyList.classList.add("d-none")
            }
        }
    }

    showAll() {
        for (var filmographyList of this.filmographyLists) {
            filmographyList.classList.remove("d-none")
        }
    }

}