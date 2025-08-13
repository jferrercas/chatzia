class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Índices para mejorar consultas por usuario
    add_index :agentes, [:user_id, :status]
    add_index :conversacions, [:agente_id, :created_at]
    add_index :mensajes, [:conversacion_id, :created_at]
    
    # Índices para búsquedas por fecha
    add_index :sessions, [:user_id, :created_at]
    add_index :conversacions, :created_at
    add_index :mensajes, :created_at
  end
end
