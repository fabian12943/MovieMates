import { Controller } from "@hotwired/stimulus"
import { useResize } from 'stimulus-use/dist/use-resize'

export default class extends Controller {
    static values = { "collapse-when-height": Number, "collapse-to-height": Number }
    static targets = [ "unfoldMessage", "collapseMessage" ]

    connect() {
        this.initial = true
        this.collapsed = false
        useResize(this)
    }

    resize() {
        if (this.initial) {
            if (this.element.clientHeight > this.collapseWhenHeightValue) {
                this.initial = false
                this.collapse()
                return
            }
        }

        if (!this.initial && this.collapsed) {
            if (this.element.clientHeight <= this.collapseWhenHeightValue) {
                this.show_all()
            }
            if (this.element.clientHeight > this.collapseWhenHeightValue) {
                this.show_less()
            }
        } else {
            if (this.element.clientHeight <= this.collapseWhenHeightValue) {
                this.collapseMessageTarget.classList.add("d-none")
            }
            if (this.element.clientHeight > this.collapseWhenHeightValue) {
                this.collapseMessageTarget.classList.remove("d-none")
            }
        }
    }

    show_all() {
        this.element.parentElement.style.height = "auto"
        this.element.parentElement.style.overflow = "auto"
        this.unfoldMessageTarget.classList.add("d-none")
        this.collapseMessageTarget.classList.add("d-none")
    }

    show_less() {
        this.element.parentElement.style.height = this.collapseToHeightValue + "px"
        this.element.parentElement.style.overflow = "hidden"
        this.unfoldMessageTarget.classList.remove("d-none")
        this.collapseMessageTarget.classList.add("d-none")
    }

    unfold() {
        this.show_all()
        this.collapsed = false
        this.collapseMessageTarget.classList.remove("d-none")
    }

    collapse() {
        this.show_less()
        this.collapsed = true
    }

}