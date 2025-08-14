class Mensaje < ApplicationRecord
  belongs_to :conversacion
  validates :contenido, presence: true, 
            length: { minimum: AppConstants::LIMITES[:mensaje_contenido_min], 
                     maximum: AppConstants::LIMITES[:mensaje_contenido_max] }

  scope :recientes, -> { order(created_at: :desc) }
  scope :por_conversacion, ->(conversacion_id) { where(conversacion_id: conversacion_id) }

  def contenido_corto
    return contenido if contenido.length <= 100
    "#{contenido[0..97]}..."
  end
  
  def contenido_limpio
    contenido.strip
  end
end
