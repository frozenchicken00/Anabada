// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

document.addEventListener("turbo:load", () => {
  // Initialize all dropdowns
  var dropdownElementList = [].slice.call(document.querySelectorAll('.dropdown-toggle'))
  dropdownElementList.map(function (dropdownToggleEl) {
    return new bootstrap.Dropdown(dropdownToggleEl)
  })
})

// app/javascript/packs/application.js

document.addEventListener('turbo:load', () => {
  const navbar = document.getElementById('mainNavbar');

  if (navbar) {
    // Function to check scroll position and update data-border attribute
    const updateNavbarBorder = () => {
      if (window.scrollY > 0) {
        navbar.setAttribute('data-border', 'true');
      } else {
        navbar.removeAttribute('data-border');
      }
    };

    // Initial check
    updateNavbarBorder();

    // Listen for scroll events
    window.addEventListener('scroll', updateNavbarBorder);
  }
});