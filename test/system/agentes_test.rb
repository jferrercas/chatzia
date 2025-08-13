require "application_system_test_case"

class AgentesTest < ApplicationSystemTestCase
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
  end

  test "visitando el índice de agentes" do
    sign_in_as(@user)
    visit agentes_url
    assert_selector "h1", text: "Agentes"
  end

  test "creando un agente" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Nuevo Agente"

    fill_in "Name", with: "Mi Nuevo Agente"
    fill_in "Channels", with: "web,email,chat"
    select "Activo", from: "Status"
    click_on "Crear Agente"

    assert_text "Agente creado exitosamente"
    assert_text "Mi Nuevo Agente"
  end

  test "actualizando un agente" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Editar", match: :first

    fill_in "Name", with: "Agente Actualizado"
    click_on "Actualizar Agente"

    assert_text "Agente was successfully updated"
    assert_text "Agente Actualizado"
  end

  test "destruyendo un agente" do
    sign_in_as(@user)
    visit agentes_url
    page.accept_confirm do
      click_on "Eliminar", match: :first
    end

    assert_text "Agente was successfully destroyed"
  end

  test "mostrando un agente" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Mostrar", match: :first

    assert_text @agente.name
  end

  test "validación de campos requeridos" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Nuevo Agente"

    click_on "Crear Agente"
    assert_text "no puede estar en blanco"
  end

  test "navegación entre páginas" do
    sign_in_as(@user)
    visit agentes_url

    # Ir a nuevo agente
    click_on "Nuevo Agente"
    assert_text "Nuevo Agente"

    # Volver al índice
    click_on "Volver"
    assert_text "Agentes"

    # Ir a mostrar agente
    click_on "Mostrar", match: :first
    assert_text @agente.name

    # Volver al índice
    click_on "Volver"
    assert_text "Agentes"
  end

  test "filtrado por status" do
    sign_in_as(@user)

    # Crear agentes con diferentes status
    @user.agentes.create!(name: "Agente Activo", status: 1)
    @user.agentes.create!(name: "Agente Inactivo", status: 0)
    @user.agentes.create!(name: "Agente Ocupado", status: 2)

    visit agentes_url

    # Verificar que todos los agentes se muestran
    assert_text "Agente Activo"
    assert_text "Agente Inactivo"
    assert_text "Agente Ocupado"
  end

  test "acceso sin autenticación" do
    visit agentes_url
    assert_current_path new_session_path
  end

  test "acceso a agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)

    visit agente_url(otro_agente)
    assert_text "No tienes permisos para acceder a este agente"
  end

  test "creación de agente con campos opcionales" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Nuevo Agente"

    fill_in "Name", with: "Agente Sin Status"
    # No llenar status (debe ser opcional)
    click_on "Crear Agente"

    assert_text "Agente creado exitosamente"
    assert_text "Agente Sin Status"
  end

  test "edición de agente mantiene datos existentes" do
    sign_in_as(@user)
    visit agentes_url
    click_on "Editar", match: :first

    # Verificar que los campos están pre-llenados
    assert_field "Name", with: @agente.name
    if @agente.channels.present?
      assert_field "Channels", with: @agente.channels
    end
  end

  test "confirmación de eliminación" do
    sign_in_as(@user)
    visit agentes_url

    # Intentar eliminar sin confirmar
    click_on "Eliminar", match: :first

    # Debe mostrar diálogo de confirmación
    assert_text "¿Estás seguro?"

    # Cancelar eliminación
    click_on "Cancelar"
    assert_text @agente.name
  end

  test "búsqueda y filtrado" do
    sign_in_as(@user)

    # Crear agentes con nombres específicos
    @user.agentes.create!(name: "Agente de Soporte")
    @user.agentes.create!(name: "Agente de Ventas")
    @user.agentes.create!(name: "Agente de Marketing")

    visit agentes_url

    # Buscar por nombre
    fill_in "Buscar", with: "Soporte"
    click_on "Buscar"

    assert_text "Agente de Soporte"
    assert_no_text "Agente de Ventas"
    assert_no_text "Agente de Marketing"
  end

  test "paginación" do
    sign_in_as(@user)

    # Crear múltiples agentes para probar paginación
    15.times do |i|
      @user.agentes.create!(name: "Agente #{i + 1}")
    end

    visit agentes_url

    # Verificar que hay paginación
    assert_selector ".pagination"

    # Ir a la siguiente página
    click_on "Siguiente"
    assert_text "Agente 11"
  end

  test "ordenamiento de agentes" do
    sign_in_as(@user)

    # Crear agentes con nombres específicos para ordenamiento
    @user.agentes.create!(name: "Agente Zeta")
    @user.agentes.create!(name: "Agente Alfa")
    @user.agentes.create!(name: "Agente Beta")

    visit agentes_url

    # Ordenar por nombre ascendente
    click_on "Nombre"
    assert_text "Agente Alfa"
    assert_text "Agente Beta"
    assert_text "Agente Zeta"

    # Ordenar por nombre descendente
    click_on "Nombre"
    assert_text "Agente Zeta"
    assert_text "Agente Beta"
    assert_text "Agente Alfa"
  end

  test "exportación de datos" do
    sign_in_as(@user)
    visit agentes_url

    # Exportar a CSV
    click_on "Exportar CSV"
    assert_text "Descargando archivo CSV"

    # Exportar a JSON
    click_on "Exportar JSON"
    assert_text "Descargando archivo JSON"
  end

  test "estadísticas de agentes" do
    sign_in_as(@user)

    # Crear agentes con diferentes status
    @user.agentes.create!(name: "Agente 1", status: 1)
    @user.agentes.create!(name: "Agente 2", status: 0)
    @user.agentes.create!(name: "Agente 3", status: 2)

    visit agentes_url

    # Verificar estadísticas
    assert_text "Total: 4"
    assert_text "Activos: 2"
    assert_text "Inactivos: 1"
    assert_text "Ocupados: 1"
  end
end
