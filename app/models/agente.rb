class Agente < ApplicationRecord
  belongs_to :user
  has_many :conversaciones, class_name: 'Conversacion', dependent: :destroy
  validates :name, presence: true
  validates :status, inclusion: { in: [0, 1, 2] }, allow_nil: true # 0: inactivo, 1: activo, 2: ocupado
  
  scope :activos, -> { where(status: 1) }
  scope :por_usuario, ->(user_id) { where(user_id: user_id) }
end
