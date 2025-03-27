import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Connects to data-controller="comment"
export default class extends Controller {
  static targets = ["textarea", "formattingTools", "submitButton", "commentsList", "sortOption", "voteButton"]

  connect() {
    console.log("Comment controller connected")
    this.initializeBootstrapComponents()
    
    // Add a small delay to ensure everything is rendered
    setTimeout(() => {
      this.initializeDropdowns()
    }, 100)
  }
  
  // Initialize Bootstrap components
  initializeBootstrapComponents() {
    // Initialize dropdowns in this controller's scope
    this.element.querySelectorAll('.dropdown-toggle, [data-bs-toggle="dropdown"]').forEach(dropdown => {
      if (!dropdown.initialized) {
        new bootstrap.Dropdown(dropdown)
        dropdown.initialized = true
      }
    })
    
    // Initialize collapse elements
    this.element.querySelectorAll('[data-bs-toggle="collapse"]').forEach(collapse => {
      if (!collapse.initialized) {
        new bootstrap.Collapse(collapse, { toggle: false })
        collapse.initialized = true
      }
    })
  }
  
  // Manually initialize dropdowns
  initializeDropdowns() {
    // Find all dropdown toggles in this controller
    this.element.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(toggle => {
      // Only initialize if not already initialized
      if (!toggle._dropdown) {
        // Create new dropdown
        const dropdown = new bootstrap.Dropdown(toggle)
        
        // Store reference to dropdown
        toggle._dropdown = dropdown
        
        // Add click listener to manually control dropdown
        toggle.addEventListener('click', (event) => {
          event.stopPropagation()
          if (toggle.getAttribute('aria-expanded') === 'true') {
            dropdown.hide()
          } else {
            dropdown.show()
          }
        })
      }
    })
    
    // Add global click handler to close dropdowns when clicking outside
    if (!this.element._hasClickListener) {
      document.addEventListener('click', (event) => {
        const dropdownMenus = this.element.querySelectorAll('.dropdown-menu.show')
        if (dropdownMenus.length && !event.target.closest('.dropdown')) {
          dropdownMenus.forEach(menu => {
            const toggle = document.querySelector(`[data-bs-toggle="dropdown"][aria-expanded="true"][aria-controls="${menu.id}"]`)
            if (toggle && toggle._dropdown) {
              toggle._dropdown.hide()
            }
          })
        }
      })
      this.element._hasClickListener = true
    }
  }

  // Method to apply formatting to text
  applyFormatting(event) {
    const button = event.currentTarget
    const format = button.dataset.format
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = textarea.value.substring(start, end)
    let formattedText = selectedText

    switch(format) {
      case 'bold':
        formattedText = `**${selectedText}**`
        break
      case 'italic':
        formattedText = `*${selectedText}*`
        break
      case 'underline':
        formattedText = `_${selectedText}_`
        break
      case 'link':
        formattedText = `[${selectedText}](url)`
        break
      default:
        return
    }

    // Replace the selected text with the formatted text
    textarea.value = textarea.value.substring(0, start) + formattedText + textarea.value.substring(end)
    
    // Reset focus to the textarea
    textarea.focus()
    
    // Set selection after the inserted text
    textarea.selectionStart = start + formattedText.length
    textarea.selectionEnd = start + formattedText.length
  }

  // Toggle reply form visibility
  toggleReplyForm(event) {
    event.preventDefault()
    const replyFormId = event.currentTarget.dataset.replyForm
    const replyForm = document.getElementById(replyFormId)
    
    if (replyForm) {
      replyForm.classList.toggle('d-none')
      if (!replyForm.classList.contains('d-none')) {
        replyForm.querySelector('textarea').focus()
      }
    }
  }
  
  // AJAX vote handling
  vote(event) {
    event.preventDefault()
    const link = event.currentTarget
    const url = link.getAttribute('href')
    
    fetch(url, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      // Update the vote count
      const countSpan = link.querySelector('.vote-count')
      if (countSpan) {
        countSpan.textContent = data.helpful_vote
      }
      
      // Update the icon based on voted status
      const icon = link.querySelector('i')
      if (icon) {
        if (data.voted) {
          icon.classList.remove('bi-hand-thumbs-up')
          icon.classList.add('bi-hand-thumbs-up-fill')
          link.classList.remove('text-dark')
          link.classList.add('text-primary')
        } else {
          icon.classList.remove('bi-hand-thumbs-up-fill')
          icon.classList.add('bi-hand-thumbs-up')
          link.classList.remove('text-primary')
          link.classList.add('text-dark')
        }
      }
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }
  
  // Sort comments based on selected option
  sortComments(event) {
    event.preventDefault()
    const sortType = event.currentTarget.dataset.sortType
    
    // Update active state in dropdown
    this.sortOptionTargets.forEach(option => {
      if (option.dataset.sortType === sortType) {
        option.classList.add('active')
      } else {
        option.classList.remove('active')
      }
    })
    
    // In a real implementation, you would fetch comments with the new sort
    // For now, we'll just update the sort button text
    const sortButtonText = event.currentTarget.textContent.trim()
    document.querySelector('#sortDropdown').innerHTML = `<i class="bi bi-arrow-down-up me-1"></i> ${sortButtonText}`
    
    // You would normally make an AJAX request here to get the sorted comments
    // For example:
    // fetch(`/products/${productId}/comments?sort=${sortType}`)
    //   .then(response => response.html())
    //   .then(html => {
    //     this.commentsListTarget.innerHTML = html
    //   })
  }
  
  // Show more comments (pagination)
  showMoreComments(event) {
    event.preventDefault()
    const button = event.currentTarget
    const page = parseInt(button.dataset.page || 1) + 1
    
    // Update the button to show loading state
    const originalText = button.innerHTML
    button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...'
    button.disabled = true
    
    // In a real implementation, you would fetch more comments
    // For demonstration, we'll just simulate a delay and enable the button again
    setTimeout(() => {
      button.innerHTML = originalText
      button.disabled = false
      button.dataset.page = page
    }, 1000)
  }
} 