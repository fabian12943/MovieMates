// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"
import "@fortawesome/fontawesome-free/js/all"

import './add_jquery'

// Setting the mutateApproach configuration to sync (available in Version 5.8.0 or greater), 
// provides a way to skip this flash of missing icons by rendering them as soon as Turbolinks 
// receives the new body.
FontAwesome.config.mutateApproach = 'sync'

var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})
