class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  has_many :contacts, dependent: :destroy

  validates :password, 
            presence: true, 
            length: { minimum: 6 }, 
            format: { 
              with: /(?=.*[A-Za-z])(?=.*\d)/, 
              message: "must include at least one letter and one number" 
            },
            if: -> { password.present? }
end
