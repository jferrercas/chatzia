require "application_system_test_case"

class ConversacionsTest < ApplicationSystemTestCase
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
  end

  test "visitando el índice de conversaciones" do
    sign_in_as(@user)
    visit conversacions_url
    assert_selector "h1", text: "Conversaciones"
  end

  test "creando una conversación" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Nueva Conversación"

    select @agente.name, from: "Agente"
    fill_in "Duración", with: "45"
    fill_in "Resumen", with: "Conversación sobre el proyecto de desarrollo"
    click_on "Crear Conversación"

    assert_text "Conversación creada exitosamente"
    assert_text "Conversación sobre el proyecto de desarrollo"
  end

  test "actualizando una conversación" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Editar", match: :first

    fill_in "Resumen", with: "Resumen actualizado de la conversación"
    click_on "Actualizar Conversación"

    assert_text "Conversacion was successfully updated"
    assert_text "Resumen actualizado de la conversación"
  end

  test "destruyendo una conversación" do
    sign_in_as(@user)
    visit conversacions_url
    page.accept_confirm do
      click_on "Eliminar", match: :first
    end

    assert_text "Conversacion was successfully destroyed"
  end

  test "mostrando una conversación" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Mostrar", match: :first

    assert_text @conversacion.agente.name
    if @conversacion.resumen.present?
      assert_text @conversacion.resumen
    end
  end

  test "validación de campos" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Nueva Conversación"

    # Intentar crear sin agente
    fill_in "Duración", with: "30"
    click_on "Crear Conversación"
    assert_text "debe existir"

    # Intentar crear con duración negativa
    select @agente.name, from: "Agente"
    fill_in "Duración", with: "-5"
    click_on "Crear Conversación"
    assert_text "debe ser mayor que 0"
  end

  test "creación de conversación sin campos opcionales" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Nueva Conversación"

    select @agente.name, from: "Agente"
    # No llenar duración ni resumen (deben ser opcionales)
    click_on "Crear Conversación"

    assert_text "Conversación creada exitosamente"
  end

  test "navegación entre páginas" do
    sign_in_as(@user)
    visit conversacions_url
    
    # Ir a nueva conversación
    click_on "Nueva Conversación"
    assert_text "Nueva Conversación"
    
    # Volver al índice
    click_on "Volver"
    assert_text "Conversaciones"
    
    # Ir a mostrar conversación
    click_on "Mostrar", match: :first
    assert_text @conversacion.agente.name
    
    # Volver al índice
    click_on "Volver"
    assert_text "Conversaciones"
  end

  test "filtrado por agente" do
    sign_in_as(@user)
    
    # Crear otro agente
    otro_agente = @user.agentes.create!(name: "Otro Agente")
    
    # Crear conversaciones para diferentes agentes
    @agente.conversaciones.create!(resumen: "Conversación Agente 1")
    otro_agente.conversaciones.create!(resumen: "Conversación Agente 2")
    
    visit conversacions_url
    
    # Filtrar por agente
    select @agente.name, from: "Filtrar por agente"
    click_on "Filtrar"
    
    assert_text "Conversación Agente 1"
    assert_no_text "Conversación Agente 2"
  end

  test "acceso sin autenticación" do
    visit conversacions_url
    assert_current_path new_session_path
  end

  test "acceso a conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)
    
    visit conversacion_url(otra_conversacion)
    assert_text "No tienes permisos para acceder a esta conversación"
  end

  test "duración formateada" do
    sign_in_as(@user)
    visit conversacions_url
    click_on "Mostrar", match: :first

    if @conversacion.duracion.present?
      assert_text "#{@conversacion.duracion} minutos"
    else
      assert_text "Sin duración"
    end
  end

  test "ordenamiento por fecha" do
    sign_in_as(@user)
    
    # Crear conversaciones con fechas específicas
    conversacion_antigua = @agente.conversaciones.create!(created_at: 2.days.ago)
    conversacion_reciente = @agente.conversaciones.create!(created_at: 1.day.ago)
    
    visit conversacions_url
    
    # Verificar orden por defecto (más recientes primero)
    assert_text conversacion_reciente.id.to_s
    assert_text conversacion_antigua.id.to_s
  end

  test "búsqueda por resumen" do
    sign_in_as(@user)
    
    # Crear conversaciones con resúmenes específicos
    @agente.conversaciones.create!(resumen: "Conversación sobre soporte técnico")
    @agente.conversaciones.create!(resumen: "Conversación sobre ventas")
    @agente.conversaciones.create!(resumen: "Conversación sobre marketing")
    
    visit conversacions_url
    
    # Buscar por palabra clave
    fill_in "Buscar", with: "soporte"
    click_on "Buscar"
    
    assert_text "Conversación sobre soporte técnico"
    assert_no_text "Conversación sobre ventas"
    assert_no_text "Conversación sobre marketing"
  end

  test "estadísticas de conversaciones" do
    sign_in_as(@user)
    
    # Crear conversaciones con diferentes duraciones
    @agente.conversaciones.create!(duracion: 30)
    @agente.conversaciones.create!(duracion: 45)
    @agente.conversaciones.create!(duracion: 60)
    
    visit conversacions_url
    
    # Verificar estadísticas
    assert_text "Total: 4"
    assert_text "Duración promedio: 33.75 minutos"
    assert_text "Conversación más larga: 60 minutos"
    assert_text "Conversación más corta: 30 minutos"
  end

  test "exportación de conversaciones" do
    sign_in_as(@user)
    visit conversacions_url
    
    # Exportar a CSV
    click_on "Exportar CSV"
    assert_text "Descargando archivo CSV"
    
    # Exportar a JSON
    click_on "Exportar JSON"
    assert_text "Descargando archivo JSON"
  end

  test "paginación de conversaciones" do
    sign_in_as(@user)
    
    # Crear múltiples conversaciones para probar paginación
    15.times do |i|
      @agente.conversaciones.create!(resumen: "Conversación #{i + 1}")
    end
    
    visit conversacions_url
    
    # Verificar que hay paginación
    assert_selector ".pagination"
    
    # Ir a la siguiente página
    click_on "Siguiente"
    assert_text "Conversación 11"
  end

  test "filtrado por rango de fechas" do
    sign_in_as(@user)
    
    # Crear conversaciones con fechas específicas
    conversacion_hoy = @agente.conversaciones.create!(created_at: Date.current)
    conversacion_semana_pasada = @agente.conversaciones.create!(created_at: 1.week.ago)
    conversacion_mes_pasado = @agente.conversaciones.create!(created_at: 1.month.ago)
    
    visit conversacions_url
    
    # Filtrar por fecha de hoy
    fill_in "Fecha desde", with: Date.current.to_s
    fill_in "Fecha hasta", with: Date.current.to_s
    click_on "Filtrar"
    
    assert_text conversacion_hoy.id.to_s
    assert_no_text conversacion_semana_pasada.id.to_s
    assert_no_text conversacion_mes_pasado.id.to_s
  end

  test "filtrado por duración" do
    sign_in_as(@user)
    
    # Crear conversaciones con diferentes duraciones
    @agente.conversaciones.create!(duracion: 15)
    @agente.conversaciones.create!(duracion: 30)
    @agente.conversaciones.create!(duracion: 60)
    
    visit conversacions_url
    
    # Filtrar conversaciones largas (más de 30 minutos)
    fill_in "Duración mínima", with: "30"
    click_on "Filtrar"
    
    assert_text "30"
    assert_text "60"
    assert_no_text "15"
  end

  test "vista de calendario" do
    sign_in_as(@user)
    
    # Crear conversación para hoy
    conversacion_hoy = @agente.conversaciones.create!(created_at: Date.current)
    
    visit conversacions_url
    
    # Cambiar a vista de calendario
    click_on "Vista Calendario"
    
    # Verificar que se muestra la conversación en el calendario
    assert_text conversacion_hoy.id.to_s
  end

  test "gráficos de conversaciones" do
    sign_in_as(@user)
    
    # Crear conversaciones para diferentes días
    5.times do |i|
      @agente.conversaciones.create!(created_at: i.days.ago, duracion: 30)
    end
    
    visit conversacions_url
    
    # Verificar que se muestran gráficos
    assert_selector ".chart"
    assert_text "Conversaciones por día"
    assert_text "Duración promedio"
  end
end
