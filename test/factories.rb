FactoryBot.define do
  factory :user do |f|
    f.sequence(:username) { |n| "Test User#{n}" }
    f.sequence(:email) { |n| "test#{n}@example.com" }
    f.password { "password" }
    f.password_confirmation { |d| d.password }
  end

  factory :category do |f|
    f.sequence(:name) { |n| "Category #{n}" }
  end

  factory :product do |f|
    f.sequence(:name) { |n| "Product #{n}" }
    f.description { "Test description" }
    f.price { 99.99 }
    f.association :user
    f.association :category
  end

  factory :comment do
    content { "Test comment" }
    association :user
    association :product
    helpful_vote { 0 }
  end
end
