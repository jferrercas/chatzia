require "application_system_test_case"

class MensajesTest < ApplicationSystemTestCase
  setup do
    @mensaje = mensajes(:one)
  end

  test "visiting the index" do
    visit mensajes_url
    assert_selector "h1", text: "Mensajes"
  end

  test "should create mensaje" do
    visit mensajes_url
    click_on "New mensaje"

    fill_in "Contenido", with: @mensaje.contenido
    fill_in "Conversacion", with: @mensaje.conversacion_id
    click_on "Create Mensaje"

    assert_text "Mensaje was successfully created"
    click_on "Back"
  end

  test "should update Mensaje" do
    visit mensaje_url(@mensaje)
    click_on "Edit this mensaje", match: :first

    fill_in "Contenido", with: @mensaje.contenido
    fill_in "Conversacion", with: @mensaje.conversacion_id
    click_on "Update Mensaje"

    assert_text "Mensaje was successfully updated"
    click_on "Back"
  end

  test "should destroy Mensaje" do
    visit mensaje_url(@mensaje)
    click_on "Destroy this mensaje", match: :first

    assert_text "Mensaje was successfully destroyed"
  end
end
