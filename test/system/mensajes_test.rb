require "application_system_test_case"

class MensajesTest < ApplicationSystemTestCase
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
    @mensaje = mensajes(:one)
  end

  test "visitando el índice de mensajes" do
    sign_in_as(@user)
    visit mensajes_url
    assert_selector "h1", text: "Mensajes"
  end

  test "creando un mensaje" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"
    fill_in "Contenido", with: "Este es un nuevo mensaje de prueba"
    click_on "Crear Mensaje"

    assert_text "Mensaje creado exitosamente"
    assert_text "Este es un nuevo mensaje de prueba"
  end

  test "actualizando un mensaje" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Editar", match: :first

    fill_in "Contenido", with: "Contenido actualizado del mensaje"
    click_on "Actualizar Mensaje"

    assert_text "Mensaje was successfully updated"
    assert_text "Contenido actualizado del mensaje"
  end

  test "destruyendo un mensaje" do
    sign_in_as(@user)
    visit mensajes_url
    page.accept_confirm do
      click_on "Eliminar", match: :first
    end

    assert_text "Mensaje was successfully destroyed"
  end

  test "mostrando un mensaje" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Mostrar", match: :first

    assert_text @mensaje.contenido
    assert_text @mensaje.conversacion.agente.name
  end

  test "validación de campos requeridos" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    # Intentar crear sin contenido
    select @conversacion.id.to_s, from: "Conversación"
    click_on "Crear Mensaje"
    assert_text "no puede estar en blanco"

    # Intentar crear sin conversación
    fill_in "Contenido", with: "Mensaje de prueba"
    select "", from: "Conversación"
    click_on "Crear Mensaje"
    assert_text "debe existir"
  end

  test "validación de longitud del contenido" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"

    # Contenido muy largo
    contenido_largo = "a" * 5001
    fill_in "Contenido", with: contenido_largo
    click_on "Crear Mensaje"
    assert_text "es demasiado largo"

    # Contenido vacío
    fill_in "Contenido", with: ""
    click_on "Crear Mensaje"
    assert_text "no puede estar en blanco"
  end

  test "creación de mensaje con contenido mínimo" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"
    fill_in "Contenido", with: "a"
    click_on "Crear Mensaje"

    assert_text "Mensaje creado exitosamente"
  end

  test "navegación entre páginas" do
    sign_in_as(@user)
    visit mensajes_url

    # Ir a nuevo mensaje
    click_on "Nuevo Mensaje"
    assert_text "Nuevo Mensaje"

    # Volver al índice
    click_on "Volver"
    assert_text "Mensajes"

    # Ir a mostrar mensaje
    click_on "Mostrar", match: :first
    assert_text @mensaje.contenido

    # Volver al índice
    click_on "Volver"
    assert_text "Mensajes"
  end

  test "filtrado por conversación" do
    sign_in_as(@user)

    # Crear otra conversación
    otra_conversacion = @agente.conversaciones.create!

    # Crear mensajes para diferentes conversaciones
    @conversacion.mensajes.create!(contenido: "Mensaje Conversación 1")
    otra_conversacion.mensajes.create!(contenido: "Mensaje Conversación 2")

    visit mensajes_url

    # Filtrar por conversación
    select @conversacion.id.to_s, from: "Filtrar por conversación"
    click_on "Filtrar"

    assert_text "Mensaje Conversación 1"
    assert_no_text "Mensaje Conversación 2"
  end

  test "acceso sin autenticación" do
    visit mensajes_url
    assert_current_path new_session_path
  end

  test "acceso a mensaje de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    visit mensaje_url(otro_mensaje)
    assert_text "No tienes permisos para acceder a este mensaje"
  end

  test "contenido corto truncado" do
    sign_in_as(@user)
    visit mensajes_url

    # Crear mensaje largo
    mensaje_largo = @conversacion.mensajes.create!(contenido: "Este es un mensaje muy largo que excede los 100 caracteres y por lo tanto debe ser truncado para mostrar solo una vista previa del contenido completo")

    visit mensajes_url

    # Verificar que se muestra contenido truncado en el índice
    assert_text "#{mensaje_largo.contenido[0..97]}..."
    assert_no_text mensaje_largo.contenido
  end

  test "ordenamiento por fecha" do
    sign_in_as(@user)

    # Crear mensajes con fechas específicas
    mensaje_antiguo = @conversacion.mensajes.create!(contenido: "Mensaje antiguo", created_at: 2.days.ago)
    mensaje_reciente = @conversacion.mensajes.create!(contenido: "Mensaje reciente", created_at: 1.day.ago)

    visit mensajes_url

    # Verificar orden por defecto (más recientes primero)
    assert_text mensaje_reciente.contenido
    assert_text mensaje_antiguo.contenido
  end

  test "búsqueda por contenido" do
    sign_in_as(@user)

    # Crear mensajes con contenido específico
    @conversacion.mensajes.create!(contenido: "Mensaje sobre soporte técnico")
    @conversacion.mensajes.create!(contenido: "Mensaje sobre ventas")
    @conversacion.mensajes.create!(contenido: "Mensaje sobre marketing")

    visit mensajes_url

    # Buscar por palabra clave
    fill_in "Buscar", with: "soporte"
    click_on "Buscar"

    assert_text "Mensaje sobre soporte técnico"
    assert_no_text "Mensaje sobre ventas"
    assert_no_text "Mensaje sobre marketing"
  end

  test "creación de mensaje con caracteres especiales" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"
    contenido_especial = "¡Hola! ¿Cómo estás? Este mensaje tiene: puntos, comas; y otros símbolos @#$%^&*()"
    fill_in "Contenido", with: contenido_especial
    click_on "Crear Mensaje"

    assert_text "Mensaje creado exitosamente"
    assert_text contenido_especial
  end

  test "creación de mensaje con emojis" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"
    contenido_emoji = "¡Hola! 😊 Este mensaje tiene emojis 🎉 y símbolos especiales ✨"
    fill_in "Contenido", with: contenido_emoji
    click_on "Crear Mensaje"

    assert_text "Mensaje creado exitosamente"
    assert_text contenido_emoji
  end

  test "creación de mensaje con saltos de línea" do
    sign_in_as(@user)
    visit mensajes_url
    click_on "Nuevo Mensaje"

    select @conversacion.id.to_s, from: "Conversación"
    contenido_multilinea = "Primera línea\nSegunda línea\nTercera línea"
    fill_in "Contenido", with: contenido_multilinea
    click_on "Crear Mensaje"

    assert_text "Mensaje creado exitosamente"
    assert_text contenido_multilinea
  end

  test "estadísticas de mensajes" do
    sign_in_as(@user)

    # Crear mensajes con diferentes longitudes
    @conversacion.mensajes.create!(contenido: "Mensaje corto")
    @conversacion.mensajes.create!(contenido: "Este es un mensaje de longitud media")
    @conversacion.mensajes.create!(contenido: "Este es un mensaje muy largo que contiene mucha información detallada sobre el tema principal de la conversación")

    visit mensajes_url

    # Verificar estadísticas
    assert_text "Total: 4"
    assert_text "Longitud promedio: 45 caracteres"
    assert_text "Mensaje más largo: 120 caracteres"
    assert_text "Mensaje más corto: 12 caracteres"
  end

  test "exportación de mensajes" do
    sign_in_as(@user)
    visit mensajes_url

    # Exportar a CSV
    click_on "Exportar CSV"
    assert_text "Descargando archivo CSV"

    # Exportar a JSON
    click_on "Exportar JSON"
    assert_text "Descargando archivo JSON"
  end

  test "paginación de mensajes" do
    sign_in_as(@user)

    # Crear múltiples mensajes para probar paginación
    15.times do |i|
      @conversacion.mensajes.create!(contenido: "Mensaje #{i + 1}")
    end

    visit mensajes_url

    # Verificar que hay paginación
    assert_selector ".pagination"

    # Ir a la siguiente página
    click_on "Siguiente"
    assert_text "Mensaje 11"
  end

  test "filtrado por rango de fechas" do
    sign_in_as(@user)

    # Crear mensajes con fechas específicas
    mensaje_hoy = @conversacion.mensajes.create!(created_at: Date.current)
    mensaje_semana_pasada = @conversacion.mensajes.create!(created_at: 1.week.ago)
    mensaje_mes_pasado = @conversacion.mensajes.create!(created_at: 1.month.ago)

    visit mensajes_url

    # Filtrar por fecha de hoy
    fill_in "Fecha desde", with: Date.current.to_s
    fill_in "Fecha hasta", with: Date.current.to_s
    click_on "Filtrar"

    assert_text mensaje_hoy.contenido
    assert_no_text mensaje_semana_pasada.contenido
    assert_no_text mensaje_mes_pasado.contenido
  end

  test "filtrado por longitud de contenido" do
    sign_in_as(@user)

    # Crear mensajes con diferentes longitudes
    @conversacion.mensajes.create!(contenido: "Corto")
    @conversacion.mensajes.create!(contenido: "Este es un mensaje de longitud media")
    @conversacion.mensajes.create!(contenido: "Este es un mensaje muy largo que contiene mucha información detallada sobre el tema principal de la conversación")

    visit mensajes_url

    # Filtrar mensajes largos (más de 50 caracteres)
    fill_in "Longitud mínima", with: "50"
    click_on "Filtrar"

    assert_text "Este es un mensaje de longitud media"
    assert_text "Este es un mensaje muy largo"
    assert_no_text "Corto"
  end

  test "vista de conversación con mensajes" do
    sign_in_as(@user)

    # Crear varios mensajes en la conversación
    @conversacion.mensajes.create!(contenido: "Primer mensaje")
    @conversacion.mensajes.create!(contenido: "Segundo mensaje")
    @conversacion.mensajes.create!(contenido: "Tercer mensaje")

    visit conversacion_url(@conversacion)

    # Verificar que se muestran todos los mensajes
    assert_text "Primer mensaje"
    assert_text "Segundo mensaje"
    assert_text "Tercer mensaje"
  end

  test "creación de mensaje desde vista de conversación" do
    sign_in_as(@user)
    visit conversacion_url(@conversacion)

    # Crear mensaje desde la vista de conversación
    fill_in "Contenido", with: "Nuevo mensaje desde conversación"
    click_on "Enviar Mensaje"

    assert_text "Mensaje creado exitosamente"
    assert_text "Nuevo mensaje desde conversación"
  end

  test "respuesta en tiempo real" do
    sign_in_as(@user)
    visit conversacion_url(@conversacion)

    # Simular mensaje entrante
    mensaje_entrante = @conversacion.mensajes.create!(contenido: "Mensaje entrante")

    # Verificar que se actualiza automáticamente
    assert_text "Mensaje entrante"
  end

  test "indicador de mensajes no leídos" do
    sign_in_as(@user)

    # Crear mensaje no leído
    @conversacion.mensajes.create!(contenido: "Mensaje no leído")

    visit mensajes_url

    # Verificar indicador
    assert_selector ".unread-indicator"
    assert_text "1 mensaje no leído"
  end

  test "marcar mensaje como leído" do
    sign_in_as(@user)

    # Crear mensaje no leído
    mensaje_no_leido = @conversacion.mensajes.create!(contenido: "Mensaje no leído")

    visit mensaje_url(mensaje_no_leido)

    # Verificar que se marca como leído
    assert_selector ".read-indicator"
    assert_text "Leído"
  end
end
