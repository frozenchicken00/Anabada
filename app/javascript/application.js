// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core" // Explicitly import Popper.js first
import * as bootstrap from "bootstrap"

// Function to manually initialize a specific dropdown
function initializeSpecificDropdown(dropdownElement) {
  if (dropdownElement && !dropdownElement._dropdown) {
    const dropdown = new bootstrap.Dropdown(dropdownElement);
    dropdownElement._dropdown = dropdown;
    
    // Add event listener for click to manually toggle dropdown
    dropdownElement.addEventListener('click', function(event) {
      event.stopPropagation();
      if (dropdownElement.classList.contains('show')) {
        dropdown.hide();
      } else {
        dropdown.show();
      }
    });
  }
}

// Function to initialize dropdowns
const initializeDropdowns = () => {
  document.querySelectorAll('.dropdown-toggle').forEach(dropdown => {
    if (!dropdown.initialized) {
      new bootstrap.Dropdown(dropdown);
      dropdown.initialized = true;
    }
  });
  
  // Fix for dropdowns in dynamically loaded content
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(dropdownToggle => {
    if (!dropdownToggle.initialized) {
      new bootstrap.Dropdown(dropdownToggle);
      dropdownToggle.initialized = true;
    }
  });
  
  // Call the manual initialization for specific problematic dropdowns
  const sortDropdown = document.getElementById('sortDropdown');
  if (sortDropdown) {
    initializeSpecificDropdown(sortDropdown);
  }
  
  // Initialize comment option dropdowns
  document.querySelectorAll('[id^="commentOptions"], [id^="replyOptions"]').forEach(dropdown => {
    initializeSpecificDropdown(dropdown);
  });
};

// Initialize on load and on navigation
document.addEventListener("turbo:load", () => {
  // Initialize all dropdowns
  initializeDropdowns();
  
  // Initialize any other Bootstrap components like tooltips, popovers, etc.
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(tooltip => {
    new bootstrap.Tooltip(tooltip);
  });
  
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(popover => {
    new bootstrap.Popover(popover);
  });
  
  // Collapsible elements
  document.querySelectorAll('[data-bs-toggle="collapse"]').forEach(collapse => {
    new bootstrap.Collapse(collapse, { toggle: false });
  });
});

// Also initialize after Turbo replaces just a part of the page
document.addEventListener("turbo:frame-load", () => {
  initializeDropdowns();
});

// Also initialize after Turbo replaces just a part of the page
document.addEventListener("turbo:render", () => {
  initializeDropdowns();
});

// Navbar code
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

// app/javascript/packs/application.jsimport "./channels"
