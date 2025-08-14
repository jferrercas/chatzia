class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :agentes, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "debe ser un email válido" }
  validates :password, length: { minimum: AppConstants::LIMITES[:password_min] }, if: :password_required?
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  scope :activos, -> { joins(:sessions).where("sessions.created_at > ?", 30.days.ago).distinct }

  def nombre_mostrar
    email_address.split("@").first.capitalize
  end
  
  def email_dominio
    email_address.split("@").last
  end

  def admin?
    # Por ahora, considerar como admin al primer usuario registrado
    # En producción, deberías tener un campo admin en la base de datos
    id == 1
  end
  
  private
  
  def password_required?
    new_record? || password.present?
  end
end
