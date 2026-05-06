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

            belongs_to :admin_role,
             class_name: "Admin",
             foreign_key: :admin_role_code,
             primary_key: :role_code,
             optional: true

             before_validation :assign_default_role, on: :create

  def admin?
    admin_role_code == "adm"
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.current
    save!
  end

  def password_token_valid?
    (self.reset_password_sent_at + 1.hour) > Time.current
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end

  private

  

  def generate_token
    SecureRandom.hex(10)
  end

  def assign_default_role
    self.admin_role_code = "usr" if admin_role_code.nil?
  end
end
