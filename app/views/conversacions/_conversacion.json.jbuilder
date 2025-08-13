json.extract! conversacion, :id, :agente_id, :duracion, :resumen, :created_at, :updated_at
json.url conversacion_url(conversacion, format: :json)
