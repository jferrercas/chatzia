class Conversacion < ApplicationRecord
  belongs_to :agente
  has_many :mensajes, dependent: :destroy
  
  validates :duracion, numericality: { greater_than: 0 }, allow_nil: true
  validates :resumen, length: { maximum: 1000 }, allow_nil: true
  
  scope :recientes, -> { order(created_at: :desc) }
  scope :por_agente, ->(agente_id) { where(agente_id: agente_id) }
  
  def duracion_formateada
    return "Sin duración" unless duracion
    "#{duracion} minutos"
  end
end
