class Contact < ApplicationRecord
  belongs_to :user
  validates :phone_number, presence: true, length: { maximum: 10 }
  validates :first_name, presence: true
  validates :last_name, presence: true
end
