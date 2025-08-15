class Agente < ApplicationRecord
  belongs_to :user
  has_many :conversacions, dependent: :destroy

  validates :name, presence: true, length: { maximum: AppConstants::LIMITES[:nombre_agente_max] }
  validates :status, inclusion: { in: AppConstants::AGENTE_ESTADOS.values }, allow_nil: true

  scope :activos, -> { where(status: AppConstants::AGENTE_ESTADOS[:activo]) }
  scope :por_usuario, ->(user_id) { where(user_id: user_id) }

  def estado_nombre
    AppConstants::AGENTE_ESTADOS.key(status)&.to_s&.capitalize || "Desconocido"
  end
end
