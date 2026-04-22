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

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.current # Use Time.current for Rails timezone support
    save!
  end

  def password_token_valid?
    # Ensure both sides of the comparison use the same timezone logic
    (self.reset_password_sent_at + 1.hour) > Time.current
  end

  def reset_password!(password)
    self.reset_password_token = nil # Clear the token so it can't be used twice
    self.password = password
    save! # CRITICAL: You must save the record to the database
  end

  private 

  def generate_token
    SecureRandom.hex(10)
  end
end