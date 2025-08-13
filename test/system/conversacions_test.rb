require "application_system_test_case"

class ConversacionsTest < ApplicationSystemTestCase
  setup do
    @conversacion = conversacions(:one)
  end

  test "visiting the index" do
    visit conversacions_url
    assert_selector "h1", text: "Conversacions"
  end

  test "should create conversacion" do
    visit conversacions_url
    click_on "New conversacion"

    fill_in "Agente", with: @conversacion.agente_id
    fill_in "Duracion", with: @conversacion.duracion
    fill_in "Resumen", with: @conversacion.resumen
    click_on "Create Conversacion"

    assert_text "Conversacion was successfully created"
    click_on "Back"
  end

  test "should update Conversacion" do
    visit conversacion_url(@conversacion)
    click_on "Edit this conversacion", match: :first

    fill_in "Agente", with: @conversacion.agente_id
    fill_in "Duracion", with: @conversacion.duracion
    fill_in "Resumen", with: @conversacion.resumen
    click_on "Update Conversacion"

    assert_text "Conversacion was successfully updated"
    click_on "Back"
  end

  test "should destroy Conversacion" do
    visit conversacion_url(@conversacion)
    click_on "Destroy this conversacion", match: :first

    assert_text "Conversacion was successfully destroyed"
  end
end
