import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

const RELOAD_HEIGHT_FROM_BOTTOM = 300
const DELAY_BETWEEN_LOADING = 500

export default class extends Controller {
  static targets = ["entries", "pagination"]

  connect() {
    this.recently_triggered = false;
  }

  scroll() {
    let next_page = this.paginationTarget.querySelector("a[rel='next']")
    if (next_page == null ) { return }

    let url = next_page.href

    var body = document.body, 
      html = document.documentElement

    var height = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight)

    if (window.pageYOffset >= height - window.innerHeight - RELOAD_HEIGHT_FROM_BOTTOM) {
      if (this.recently_triggered == false) {
        this.loadMore(url)
      }
    }
  }

  loadMore(url) {
    this.recently_triggered = true
    Rails.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: (data) => {
        this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
        this.paginationTarget.innerHTML = data.pagination
      }
    })
    setTimeout(() => {
      this.recently_triggered = false;    
    }, DELAY_BETWEEN_LOADING)
  }
}