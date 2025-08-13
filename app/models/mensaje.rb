class Mensaje < ApplicationRecord
  belongs_to :conversacion
  
  validates :contenido, presence: true, length: { minimum: 1, maximum: 5000 }
  
  scope :recientes, -> { order(created_at: :desc) }
  scope :por_conversacion, ->(conversacion_id) { where(conversacion_id: conversacion_id) }
  
  def contenido_corto
    contenido.length > 100 ? "#{contenido[0..97]}..." : contenido
  end
end
