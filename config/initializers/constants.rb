# Constantes globales de la aplicación

module AppConstants
  # Estados de agentes
  AGENTE_ESTADOS = {
    inactivo: 0,
    activo: 1,
    ocupado: 2
  }.freeze
  
  # Límites de validación
  LIMITES = {
    mensaje_contenido_max: 5000,
    mensaje_contenido_min: 1,
    resumen_max: 1000,
    password_min: 6,
    nombre_agente_max: 100
  }.freeze
  
  # Configuración de sesiones
  SESION_CONFIG = {
    dias_expiracion: 30,
    max_sesiones_por_usuario: 5
  }.freeze
  
  # Mensajes de error comunes
  MENSAJES_ERROR = {
    acceso_denegado: "No tienes permisos para acceder a este recurso.",
    recurso_no_encontrado: "El recurso solicitado no fue encontrado.",
    parametros_invalidos: "Los parámetros proporcionados son inválidos.",
    sesion_expirada: "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."
  }.freeze
end
