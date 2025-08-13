require "application_system_test_case"

class AgentesTest < ApplicationSystemTestCase
  setup do
    @agente = agentes(:one)
  end

  test "visiting the index" do
    visit agentes_url
    assert_selector "h1", text: "Agentes"
  end

  test "should create agente" do
    visit agentes_url
    click_on "New agente"

    fill_in "Channels", with: @agente.channels
    fill_in "Name", with: @agente.name
    fill_in "Status", with: @agente.status
    fill_in "User", with: @agente.user_id
    click_on "Create Agente"

    assert_text "Agente was successfully created"
    click_on "Back"
  end

  test "should update Agente" do
    visit agente_url(@agente)
    click_on "Edit this agente", match: :first

    fill_in "Channels", with: @agente.channels
    fill_in "Name", with: @agente.name
    fill_in "Status", with: @agente.status
    fill_in "User", with: @agente.user_id
    click_on "Update Agente"

    assert_text "Agente was successfully updated"
    click_on "Back"
  end

  test "should destroy Agente" do
    visit agente_url(@agente)
    click_on "Destroy this agente", match: :first

    assert_text "Agente was successfully destroyed"
  end
end
