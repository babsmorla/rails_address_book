class Contact < ApplicationRecord

  GH_PHONE_REGEX = /\A(\+?233|0)(2[034567]|5[0345679])\d{7}\z/
  
  belongs_to :user
  validates :phone_number, presence: true, length: { is: 10 }, format: { 
    with: GH_PHONE_REGEX, 
    message: "must be a valid Ghana number (e.g., 0241234567)" 
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
end


