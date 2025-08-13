require "test_helper"

class ApplicationIntegrationTest < ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
    @mensaje = mensajes(:one)
  end

  test "flujo completo de creación de agente y conversación" do
    sign_in_as(@user)

    # 1. Crear un nuevo agente
    post agentes_url, params: { agente: { name: "Agente de Soporte", status: 1 } }
    assert_response :redirect
    agente = Agente.last
    assert_equal "Agente de Soporte", agente.name

    # 2. Crear una conversación para ese agente
    post conversacions_url, params: { conversacion: {
      agente_id: agente.id,
      duracion: 30,
      resumen: "Conversación de soporte técnico"
    } }
    assert_response :redirect
    conversacion = Conversacion.last
    assert_equal agente.id, conversacion.agente_id
    assert_equal 30, conversacion.duracion

    # 3. Crear mensajes en la conversación
    post mensajes_url, params: { mensaje: {
      conversacion_id: conversacion.id,
      contenido: "Hola, necesito ayuda con mi cuenta"
    } }
    assert_response :redirect
    mensaje = Mensaje.last
    assert_equal conversacion.id, mensaje.conversacion_id

    # 4. Verificar que todo está conectado correctamente
    get agente_url(agente)
    assert_response :success
    assert_includes @response.body, "Agente de Soporte"

    get conversacion_url(conversacion)
    assert_response :success
    assert_includes @response.body, "Conversación de soporte técnico"

    get mensaje_url(mensaje)
    assert_response :success
    assert_includes @response.body, "Hola, necesito ayuda con mi cuenta"
  end

  test "flujo de autenticación y autorización" do
    # 1. Intentar acceder sin autenticación
    get agentes_url
    assert_redirected_to new_session_path

    # 2. Autenticarse
    sign_in_as(@user)

    # 3. Verificar acceso a recursos propios
    get agentes_url
    assert_response :success

    get agente_url(@agente)
    assert_response :success

    # 4. Verificar que no se puede acceder a recursos de otros usuarios
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")

    get agente_url(otro_agente)
    assert_redirected_to agentes_path
    assert_equal "No tienes permisos para acceder a este agente.", flash[:alert]
  end

  test "flujo de actualización y eliminación" do
    sign_in_as(@user)

    # 1. Actualizar agente
    patch agente_url(@agente), params: { agente: { name: "Agente Actualizado" } }
    assert_response :redirect
    @agente.reload
    assert_equal "Agente Actualizado", @agente.name

    # 2. Actualizar conversación
    patch conversacion_url(@conversacion), params: { conversacion: { resumen: "Resumen actualizado" } }
    assert_response :redirect
    @conversacion.reload
    assert_equal "Resumen actualizado", @conversacion.resumen

    # 3. Actualizar mensaje
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "Contenido actualizado" } }
    assert_response :redirect
    @mensaje.reload
    assert_equal "Contenido actualizado", @mensaje.contenido

    # 4. Eliminar en orden inverso (por dependencias)
    delete mensaje_url(@mensaje)
    assert_response :redirect

    delete conversacion_url(@conversacion)
    assert_response :redirect

    delete agente_url(@agente)
    assert_response :redirect
  end

  test "flujo de respuestas JSON" do
    sign_in_as(@user)

    # 1. Obtener índice en JSON
    get agentes_url, as: :json
    assert_response :success
    assert_not_nil response.parsed_body

    # 2. Crear agente en JSON
    post agentes_url, params: { agente: { name: "Agente JSON", status: 1 } }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body

    # 3. Obtener agente en JSON
    agente = Agente.last
    get agente_url(agente), as: :json
    assert_response :success
    assert_not_nil response.parsed_body

    # 4. Actualizar agente en JSON
    patch agente_url(agente), params: { agente: { name: "Agente JSON Actualizado" } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body

    # 5. Eliminar agente en JSON
    delete agente_url(agente), as: :json
    assert_response :no_content
  end

  test "flujo de validaciones y errores" do
    sign_in_as(@user)

    # 1. Intentar crear agente sin nombre
    post agentes_url, params: { agente: { status: 1 } }
    assert_response :unprocessable_entity
    assert_includes @response.body, "no puede estar en blanco"

    # 2. Intentar crear conversación sin agente
    post conversacions_url, params: { conversacion: { duracion: 30 } }
    assert_response :unprocessable_entity
    assert_includes @response.body, "debe existir"

    # 3. Intentar crear mensaje sin contenido
    post mensajes_url, params: { mensaje: { conversacion_id: @conversacion.id } }
    assert_response :unprocessable_entity
    assert_includes @response.body, "no puede estar en blanco"

    # 4. Intentar crear mensaje con contenido muy largo
    contenido_largo = "a" * 5001
    post mensajes_url, params: { mensaje: {
      conversacion_id: @conversacion.id,
      contenido: contenido_largo
    } }
    assert_response :unprocessable_entity
    assert_includes @response.body, "es demasiado largo"
  end

  test "flujo de scopes y filtros" do
    sign_in_as(@user)

    # 1. Crear agentes con diferentes status
    agente_activo = @user.agentes.create!(name: "Agente Activo", status: 1)
    agente_inactivo = @user.agentes.create!(name: "Agente Inactivo", status: 0)
    agente_ocupado = @user.agentes.create!(name: "Agente Ocupado", status: 2)

    # 2. Verificar scope activos
    agentes_activos = Agente.activos
    assert_includes agentes_activos, agente_activo
    assert_not_includes agentes_activos, agente_inactivo
    assert_not_includes agentes_activos, agente_ocupado

    # 3. Verificar scope por_usuario
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")

    agentes_del_user = Agente.por_usuario(@user.id)
    assert_includes agentes_del_user, agente_activo
    assert_not_includes agentes_del_user, otro_agente

    # 4. Crear conversaciones y verificar scopes
    conversacion_reciente = agente_activo.conversaciones.create!(created_at: 1.day.ago)
    conversacion_antigua = agente_activo.conversaciones.create!(created_at: 2.days.ago)

    conversaciones_recientes = Conversacion.recientes
    assert_equal conversacion_reciente, conversaciones_recientes.first
    assert_equal conversacion_antigua, conversaciones_recientes.last

    # 5. Crear mensajes y verificar scopes
    mensaje_reciente = conversacion_reciente.mensajes.create!(contenido: "Mensaje reciente", created_at: 1.day.ago)
    mensaje_antiguo = conversacion_reciente.mensajes.create!(contenido: "Mensaje antiguo", created_at: 2.days.ago)

    mensajes_recientes = Mensaje.recientes
    assert_equal mensaje_reciente, mensajes_recientes.first
    assert_equal mensaje_antiguo, mensajes_recientes.last
  end

  test "flujo de métodos de instancia" do
    sign_in_as(@user)

    # 1. Probar nombre_mostrar del usuario
    @user.email_address = "juan.perez@example.com"
    @user.save!
    assert_equal "Juan.perez", @user.nombre_mostrar

    # 2. Probar duracion_formateada de conversación
    @conversacion.duracion = 45
    @conversacion.save!
    assert_equal "45 minutos", @conversacion.duracion_formateada

    @conversacion.duracion = nil
    @conversacion.save!
    assert_equal "Sin duración", @conversacion.duracion_formateada

    # 3. Probar contenido_corto del mensaje
    @mensaje.contenido = "Este es un mensaje corto"
    @mensaje.save!
    assert_equal "Este es un mensaje corto", @mensaje.contenido_corto

    contenido_largo = "Este es un mensaje muy largo que excede los 100 caracteres y por lo tanto debe ser truncado para mostrar solo una vista previa del contenido completo"
    @mensaje.contenido = contenido_largo
    @mensaje.save!
    assert_equal "#{contenido_largo[0..97]}...", @mensaje.contenido_corto
  end

  test "flujo de dependencias y eliminación en cascada" do
    sign_in_as(@user)

    # 1. Crear estructura completa
    agente = @user.agentes.create!(name: "Agente para Eliminar")
    conversacion = agente.conversaciones.create!(resumen: "Conversación para eliminar")
    mensaje = conversacion.mensajes.create!(contenido: "Mensaje para eliminar")

    # 2. Verificar que existe
    assert_equal 1, agente.conversaciones.count
    assert_equal 1, conversacion.mensajes.count

    # 3. Eliminar agente y verificar eliminación en cascada
    delete agente_url(agente)
    assert_response :redirect

    # Verificar que se eliminó todo
    assert_raises(ActiveRecord::RecordNotFound) { agente.reload }
    assert_raises(ActiveRecord::RecordNotFound) { conversacion.reload }
    assert_raises(ActiveRecord::RecordNotFound) { mensaje.reload }
  end

  test "flujo de normalización de datos" do
    sign_in_as(@user)

    # 1. Probar normalización de email
    post users_url, params: { user: {
      email_address: "  TEST@EXAMPLE.COM  ",
      password: "password123",
      password_confirmation: "password123"
    } }
    assert_response :redirect

    user = User.last
    assert_equal "test@example.com", user.email_address
  end

  test "flujo de autenticación con password seguro" do
    # 1. Crear usuario con password
    post users_url, params: { user: {
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    } }
    assert_response :redirect

    user = User.last

    # 2. Verificar que puede autenticarse
    post session_path, params: {
      email_address: "test@example.com",
      password: "password123"
    }
    assert_response :redirect

    # 3. Verificar que no puede autenticarse con password incorrecto
    post session_path, params: {
      email_address: "test@example.com",
      password: "password_incorrecto"
    }
    assert_response :unprocessable_entity
  end
end
