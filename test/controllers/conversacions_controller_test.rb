require "test_helper"

class ConversacionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conversacion = conversacions(:one)
  end

  test "should get index" do
    get conversacions_url
    assert_response :success
  end

  test "should get new" do
    get new_conversacion_url
    assert_response :success
  end

  test "should create conversacion" do
    assert_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: { agente_id: @conversacion.agente_id, duracion: @conversacion.duracion, resumen: @conversacion.resumen } }
    end

    assert_redirected_to conversacion_url(Conversacion.last)
  end

  test "should show conversacion" do
    get conversacion_url(@conversacion)
    assert_response :success
  end

  test "should get edit" do
    get edit_conversacion_url(@conversacion)
    assert_response :success
  end

  test "should update conversacion" do
    patch conversacion_url(@conversacion), params: { conversacion: { agente_id: @conversacion.agente_id, duracion: @conversacion.duracion, resumen: @conversacion.resumen } }
    assert_redirected_to conversacion_url(@conversacion)
  end

  test "should destroy conversacion" do
    assert_difference("Conversacion.count", -1) do
      delete conversacion_url(@conversacion)
    end

    assert_redirected_to conversacions_url
  end
end
