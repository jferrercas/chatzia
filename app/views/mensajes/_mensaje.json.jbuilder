json.extract! mensaje, :id, :contenido, :conversacion_id, :created_at, :updated_at
json.url mensaje_url(mensaje, format: :json)
