class Conversacion < ApplicationRecord
  belongs_to :agente
  has_many :mensajes, dependent: :destroy

  validates :duracion, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :resumen, length: { maximum: AppConstants::LIMITES[:resumen_max] }, allow_nil: true

  scope :recientes, -> { order(created_at: :desc) }
  scope :por_agente, ->(agente_id) { where(agente_id: agente_id) }

  def duracion_formateada
    return "Sin duración" unless duracion
    "#{duracion} minutos"
  end
end
