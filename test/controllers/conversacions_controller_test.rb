require "test_helper"

class ConversacionsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
    @conversacion_params = {
      agente_id: @agente.id,
      duracion: 30,
      resumen: "Conversación sobre el proyecto"
    }
  end

  test "debe obtener index" do
    sign_in_as(@user)
    get conversacions_url
    assert_response :success
  end

  test "debe mostrar conversación" do
    sign_in_as(@user)
    get conversacion_url(@conversacion)
    assert_response :success
  end

  test "debe obtener new" do
    sign_in_as(@user)
    get new_conversacion_url
    assert_response :success
  end

  test "debe crear conversación" do
    sign_in_as(@user)
    assert_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: @conversacion_params }
    end

    assert_redirected_to conversacion_url(Conversacion.last)
    assert_equal "Conversación creada exitosamente.", flash[:notice]
  end

  test "no debe crear conversación con parámetros inválidos" do
    sign_in_as(@user)
    assert_no_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: { agente_id: @agente.id, duracion: -5 } }
    end

    assert_response :unprocessable_entity
  end

  test "no debe crear conversación para agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)

    assert_no_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: { agente_id: otro_agente.id, duracion: 30 } }
    end

    assert_redirected_to conversacions_path
    assert_equal "No puedes crear conversaciones para agentes que no te pertenecen.", flash[:alert]
  end

  test "debe obtener edit" do
    sign_in_as(@user)
    get edit_conversacion_url(@conversacion)
    assert_response :success
  end

  test "debe actualizar conversación" do
    sign_in_as(@user)
    patch conversacion_url(@conversacion), params: { conversacion: { resumen: "Resumen actualizado" } }
    assert_redirected_to conversacion_url(@conversacion)
    assert_equal "Conversacion was successfully updated.", flash[:notice]
  end

  test "no debe actualizar conversación con parámetros inválidos" do
    sign_in_as(@user)
    patch conversacion_url(@conversacion), params: { conversacion: { duracion: -10 } }
    assert_response :unprocessable_entity
  end

  test "debe destruir conversación" do
    sign_in_as(@user)
    assert_difference("Conversacion.count", -1) do
      delete conversacion_url(@conversacion)
    end

    assert_redirected_to conversacions_url
    assert_equal "Conversacion was successfully destroyed.", flash[:notice]
  end

  test "no debe permitir acceso sin autenticación" do
    get conversacions_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a show sin autenticación" do
    get conversacion_url(@conversacion)
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a new sin autenticación" do
    get new_conversacion_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a edit sin autenticación" do
    get edit_conversacion_url(@conversacion)
    assert_redirected_to new_session_path
  end

  test "no debe permitir crear conversación sin autenticación" do
    assert_no_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: @conversacion_params }
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir actualizar conversación sin autenticación" do
    patch conversacion_url(@conversacion), params: { conversacion: { resumen: "Resumen actualizado" } }
    assert_redirected_to new_session_path
  end

  test "no debe permitir destruir conversación sin autenticación" do
    assert_no_difference("Conversacion.count") do
      delete conversacion_url(@conversacion)
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    get conversacion_url(otra_conversacion)
    assert_redirected_to conversacions_path
    assert_equal "No tienes permisos para acceder a esta conversación.", flash[:alert]
  end

  test "no debe permitir editar conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    get edit_conversacion_url(otra_conversacion)
    assert_redirected_to conversacions_path
    assert_equal "No tienes permisos para acceder a esta conversación.", flash[:alert]
  end

  test "no debe permitir actualizar conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    patch conversacion_url(otra_conversacion), params: { conversacion: { resumen: "Resumen actualizado" } }
    assert_redirected_to conversacions_path
    assert_equal "No tienes permisos para acceder a esta conversación.", flash[:alert]
  end

  test "no debe permitir destruir conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    assert_no_difference("Conversacion.count") do
      delete conversacion_url(otra_conversacion)
    end
    assert_redirected_to conversacions_path
    assert_equal "No tienes permisos para acceder a esta conversación.", flash[:alert]
  end

  test "debe responder a JSON para index" do
    sign_in_as(@user)
    get conversacions_url, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para show" do
    sign_in_as(@user)
    get conversacion_url(@conversacion), as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para create" do
    sign_in_as(@user)
    post conversacions_url, params: { conversacion: @conversacion_params }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para update" do
    sign_in_as(@user)
    patch conversacion_url(@conversacion), params: { conversacion: { resumen: "Resumen actualizado" } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para destroy" do
    sign_in_as(@user)
    delete conversacion_url(@conversacion), as: :json
    assert_response :no_content
  end

  test "debe manejar errores JSON en create" do
    sign_in_as(@user)
    post conversacions_url, params: { conversacion: { agente_id: @agente.id, duracion: -5 } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe manejar errores JSON en update" do
    sign_in_as(@user)
    patch conversacion_url(@conversacion), params: { conversacion: { duracion: -10 } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe crear conversación sin duración ni resumen" do
    sign_in_as(@user)
    conversacion_minima = { agente_id: @agente.id }
    assert_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: conversacion_minima }
    end
    assert_redirected_to conversacion_url(Conversacion.last)
  end

  test "debe validar duración positiva" do
    sign_in_as(@user)
    conversacion_duracion_invalida = @conversacion_params.merge(duracion: 0)
    assert_no_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: conversacion_duracion_invalida }
    end
    assert_response :unprocessable_entity
  end

  test "debe validar longitud máxima del resumen" do
    sign_in_as(@user)
    resumen_largo = "a" * 1001
    conversacion_resumen_largo = @conversacion_params.merge(resumen: resumen_largo)
    assert_no_difference("Conversacion.count") do
      post conversacions_url, params: { conversacion: conversacion_resumen_largo }
    end
    assert_response :unprocessable_entity
  end

  test "debe mostrar solo conversaciones del usuario actual" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    get conversacions_url
    assert_response :success
    assert_includes @response.body, @conversacion.id.to_s
    assert_not_includes @response.body, otra_conversacion.id.to_s
  end
end
