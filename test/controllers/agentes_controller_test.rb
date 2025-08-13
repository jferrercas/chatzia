require "test_helper"

class AgentesControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @agente_params = {
      name: "Nuevo Agente",
      channels: "web,email",
      status: 1
    }
  end

  test "debe obtener index" do
    sign_in_as(@user)
    get agentes_url
    assert_response :success
  end

  test "debe mostrar agente" do
    sign_in_as(@user)
    get agente_url(@agente)
    assert_response :success
  end

  test "debe obtener new" do
    sign_in_as(@user)
    get new_agente_url
    assert_response :success
  end

  test "debe crear agente" do
    sign_in_as(@user)
    assert_difference("Agente.count") do
      post agentes_url, params: { agente: @agente_params }
    end

    assert_redirected_to agente_url(Agente.last)
    assert_equal "Agente creado exitosamente.", flash[:notice]
  end

  test "no debe crear agente con parámetros inválidos" do
    sign_in_as(@user)
    assert_no_difference("Agente.count") do
      post agentes_url, params: { agente: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "debe obtener edit" do
    sign_in_as(@user)
    get edit_agente_url(@agente)
    assert_response :success
  end

  test "debe actualizar agente" do
    sign_in_as(@user)
    patch agente_url(@agente), params: { agente: { name: "Agente Actualizado" } }
    assert_redirected_to agente_url(@agente)
    assert_equal "Agente was successfully updated.", flash[:notice]
  end

  test "no debe actualizar agente con parámetros inválidos" do
    sign_in_as(@user)
    patch agente_url(@agente), params: { agente: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "debe destruir agente" do
    sign_in_as(@user)
    assert_difference("Agente.count", -1) do
      delete agente_url(@agente)
    end

    assert_redirected_to agentes_url
    assert_equal "Agente was successfully destroyed.", flash[:notice]
  end

  test "no debe permitir acceso sin autenticación" do
    get agentes_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a show sin autenticación" do
    get agente_url(@agente)
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a new sin autenticación" do
    get new_agente_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a edit sin autenticación" do
    get edit_agente_url(@agente)
    assert_redirected_to new_session_path
  end

  test "no debe permitir crear agente sin autenticación" do
    assert_no_difference("Agente.count") do
      post agentes_url, params: { agente: @agente_params }
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir actualizar agente sin autenticación" do
    patch agente_url(@agente), params: { agente: { name: "Agente Actualizado" } }
    assert_redirected_to new_session_path
  end

  test "no debe permitir destruir agente sin autenticación" do
    assert_no_difference("Agente.count") do
      delete agente_url(@agente)
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)
    
    get agente_url(otro_agente)
    assert_redirected_to agentes_path
    assert_equal "No tienes permisos para acceder a este agente.", flash[:alert]
  end

  test "no debe permitir editar agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)
    
    get edit_agente_url(otro_agente)
    assert_redirected_to agentes_path
    assert_equal "No tienes permisos para acceder a este agente.", flash[:alert]
  end

  test "no debe permitir actualizar agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)
    
    patch agente_url(otro_agente), params: { agente: { name: "Agente Actualizado" } }
    assert_redirected_to agentes_path
    assert_equal "No tienes permisos para acceder a este agente.", flash[:alert]
  end

  test "no debe permitir destruir agente de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)
    
    assert_no_difference("Agente.count") do
      delete agente_url(otro_agente)
    end
    assert_redirected_to agentes_path
    assert_equal "No tienes permisos para acceder a este agente.", flash[:alert]
  end

  test "debe responder a JSON para index" do
    sign_in_as(@user)
    get agentes_url, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para show" do
    sign_in_as(@user)
    get agente_url(@agente), as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para create" do
    sign_in_as(@user)
    post agentes_url, params: { agente: @agente_params }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para update" do
    sign_in_as(@user)
    patch agente_url(@agente), params: { agente: { name: "Agente Actualizado" } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para destroy" do
    sign_in_as(@user)
    delete agente_url(@agente), as: :json
    assert_response :no_content
  end

  test "debe manejar errores JSON en create" do
    sign_in_as(@user)
    post agentes_url, params: { agente: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe manejar errores JSON en update" do
    sign_in_as(@user)
    patch agente_url(@agente), params: { agente: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe crear agente con status válido" do
    sign_in_as(@user)
    agente_activo = @agente_params.merge(status: 1)
    assert_difference("Agente.count") do
      post agentes_url, params: { agente: agente_activo }
    end
    assert_equal 1, Agente.last.status
  end

  test "debe crear agente sin status" do
    sign_in_as(@user)
    agente_sin_status = @agente_params.except(:status)
    assert_difference("Agente.count") do
      post agentes_url, params: { agente: agente_sin_status }
    end
    assert_nil Agente.last.status
  end

  test "debe validar status inválido" do
    sign_in_as(@user)
    agente_status_invalido = @agente_params.merge(status: 3)
    assert_no_difference("Agente.count") do
      post agentes_url, params: { agente: agente_status_invalido }
    end
    assert_response :unprocessable_entity
  end

  test "debe mostrar solo agentes del usuario actual" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    sign_in_as(@user)
    
    get agentes_url
    assert_response :success
    assert_includes @response.body, @agente.name
    assert_not_includes @response.body, otro_agente.name
  end
end
