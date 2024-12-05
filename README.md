# Anabada
Second-hand online shop for my community# Anabada - A Sustainable Marketplace Platform

## Overview
Anabada is a community-driven marketplace that promotes sustainable consumption through sharing and reusing. The name "Anabada" reflects our core values: using items sparingly, sharing resources, exchanging goods, and reusing products to reduce waste.

## Features

### User Authentication
- Traditional email/password signup and login
- OAuth integration with GitHub for federated login
- User profile management
- Admin role with special privileges

### Product Management
- Create, edit, and delete product listings
- Upload multiple product images
- Categorize products
- Search functionality using Searchkick/Elasticsearch
- Product filtering by categories

### Category System
- Admin-controlled category management
- Products organized by categories
- Category-based product filtering

### Comments and Interaction
- Comment on products
- Nested replies to comments
- Helpful vote system for comments

### Search Functionality
- Full-text search across products
- Search by product name, description, or category

## Technical Stack

### Backend
- Ruby 3.3.4
- Rails 7.2.1
- PostgreSQL database
- Elasticsearch for search functionality

### Frontend
- Bootstrap 5 for styling
- Bootstrap Icons
- Responsive design

### Testing
- Minitest for unit and integration testing
- FactoryBot for test data
- Capybara for integration tests

### Authentication
- BCrypt for password hashing
- OmniAuth for GitHub integration

## Getting Started

### Prerequisites
- Ruby 3.3.4
- PostgreSQL
- Node.js
- Yarn
- Elasticsearch

### Installation
1. Clone the repository
```bash
git clone https://github.com/frozenchicken00/Anabada.git
cd anabada
```

2. Install dependencies
```bash
bundle install
yarn install
```


3. Setup database
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server
```bash
bin/dev

#Visit http://localhost:3000
```

## Testing
```bash
guard
```
