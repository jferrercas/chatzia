require "test_helper"

class MensajesControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
    @mensaje = mensajes(:one)
    @mensaje_params = {
      contenido: "Este es un nuevo mensaje de prueba",
      conversacion_id: @conversacion.id
    }
  end

  test "debe obtener index" do
    sign_in_as(@user)
    get mensajes_url
    assert_response :success
  end

  test "debe mostrar mensaje" do
    sign_in_as(@user)
    get mensaje_url(@mensaje)
    assert_response :success
  end

  test "debe obtener new" do
    sign_in_as(@user)
    get new_mensaje_url
    assert_response :success
  end

  test "debe crear mensaje" do
    sign_in_as(@user)
    assert_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: @mensaje_params }
    end

    assert_redirected_to mensaje_url(Mensaje.last)
    assert_equal "Mensaje creado exitosamente.", flash[:notice]
  end

  test "no debe crear mensaje con parámetros inválidos" do
    sign_in_as(@user)
    assert_no_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: { contenido: "", conversacion_id: @conversacion.id } }
    end

    assert_response :unprocessable_entity
  end

  test "no debe crear mensaje en conversación de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    sign_in_as(@user)

    assert_no_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: { contenido: "Mensaje", conversacion_id: otra_conversacion.id } }
    end

    assert_redirected_to mensajes_path
    assert_equal "No puedes crear mensajes en conversaciones que no te pertenecen.", flash[:alert]
  end

  test "debe obtener edit" do
    sign_in_as(@user)
    get edit_mensaje_url(@mensaje)
    assert_response :success
  end

  test "debe actualizar mensaje" do
    sign_in_as(@user)
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "Contenido actualizado" } }
    assert_redirected_to mensaje_url(@mensaje)
    assert_equal "Mensaje was successfully updated.", flash[:notice]
  end

  test "no debe actualizar mensaje con parámetros inválidos" do
    sign_in_as(@user)
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "" } }
    assert_response :unprocessable_entity
  end

  test "debe destruir mensaje" do
    sign_in_as(@user)
    assert_difference("Mensaje.count", -1) do
      delete mensaje_url(@mensaje)
    end

    assert_redirected_to mensajes_url
    assert_equal "Mensaje was successfully destroyed.", flash[:notice]
  end

  test "no debe permitir acceso sin autenticación" do
    get mensajes_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a show sin autenticación" do
    get mensaje_url(@mensaje)
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a new sin autenticación" do
    get new_mensaje_url
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a edit sin autenticación" do
    get edit_mensaje_url(@mensaje)
    assert_redirected_to new_session_path
  end

  test "no debe permitir crear mensaje sin autenticación" do
    assert_no_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: @mensaje_params }
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir actualizar mensaje sin autenticación" do
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "Contenido actualizado" } }
    assert_redirected_to new_session_path
  end

  test "no debe permitir destruir mensaje sin autenticación" do
    assert_no_difference("Mensaje.count") do
      delete mensaje_url(@mensaje)
    end
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a mensaje de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    get mensaje_url(otro_mensaje)
    assert_redirected_to mensajes_path
    assert_equal "No tienes permisos para acceder a este mensaje.", flash[:alert]
  end

  test "no debe permitir editar mensaje de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    get edit_mensaje_url(otro_mensaje)
    assert_redirected_to mensajes_path
    assert_equal "No tienes permisos para acceder a este mensaje.", flash[:alert]
  end

  test "no debe permitir actualizar mensaje de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    patch mensaje_url(otro_mensaje), params: { mensaje: { contenido: "Contenido actualizado" } }
    assert_redirected_to mensajes_path
    assert_equal "No tienes permisos para acceder a este mensaje.", flash[:alert]
  end

  test "no debe permitir destruir mensaje de otro usuario" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    assert_no_difference("Mensaje.count") do
      delete mensaje_url(otro_mensaje)
    end
    assert_redirected_to mensajes_path
    assert_equal "No tienes permisos para acceder a este mensaje.", flash[:alert]
  end

  test "debe responder a JSON para index" do
    sign_in_as(@user)
    get mensajes_url, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para show" do
    sign_in_as(@user)
    get mensaje_url(@mensaje), as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para create" do
    sign_in_as(@user)
    post mensajes_url, params: { mensaje: @mensaje_params }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para update" do
    sign_in_as(@user)
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "Contenido actualizado" } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para destroy" do
    sign_in_as(@user)
    delete mensaje_url(@mensaje), as: :json
    assert_response :no_content
  end

  test "debe manejar errores JSON en create" do
    sign_in_as(@user)
    post mensajes_url, params: { mensaje: { contenido: "", conversacion_id: @conversacion.id } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe manejar errores JSON en update" do
    sign_in_as(@user)
    patch mensaje_url(@mensaje), params: { mensaje: { contenido: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe crear mensaje con contenido mínimo" do
    sign_in_as(@user)
    mensaje_minimo = { contenido: "a", conversacion_id: @conversacion.id }
    assert_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_minimo }
    end
    assert_redirected_to mensaje_url(Mensaje.last)
  end

  test "debe crear mensaje con contenido largo" do
    sign_in_as(@user)
    contenido_largo = "Este es un mensaje con contenido extenso que describe en detalle todos los aspectos importantes de la conversación. Incluye información relevante sobre el tema principal y proporciona contexto adicional para entender mejor la situación actual."
    mensaje_largo = { contenido: contenido_largo, conversacion_id: @conversacion.id }
    assert_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_largo }
    end
    assert_redirected_to mensaje_url(Mensaje.last)
  end

  test "debe validar longitud máxima del contenido" do
    sign_in_as(@user)
    contenido_muy_largo = "a" * 5001
    mensaje_contenido_largo = { contenido: contenido_muy_largo, conversacion_id: @conversacion.id }
    assert_no_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_contenido_largo }
    end
    assert_response :unprocessable_entity
  end

  test "debe validar contenido no vacío" do
    sign_in_as(@user)
    mensaje_vacio = { contenido: "", conversacion_id: @conversacion.id }
    assert_no_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_vacio }
    end
    assert_response :unprocessable_entity
  end

  test "debe crear mensaje con caracteres especiales" do
    sign_in_as(@user)
    contenido_especial = "¡Hola! ¿Cómo estás? Este mensaje tiene: puntos, comas; y otros símbolos @#$%^&*()"
    mensaje_especial = { contenido: contenido_especial, conversacion_id: @conversacion.id }
    assert_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_especial }
    end
    assert_redirected_to mensaje_url(Mensaje.last)
  end

  test "debe crear mensaje con emojis" do
    sign_in_as(@user)
    contenido_emoji = "¡Hola! 😊 Este mensaje tiene emojis 🎉 y símbolos especiales ✨"
    mensaje_emoji = { contenido: contenido_emoji, conversacion_id: @conversacion.id }
    assert_difference("Mensaje.count") do
      post mensajes_url, params: { mensaje: mensaje_emoji }
    end
    assert_redirected_to mensaje_url(Mensaje.last)
  end

  test "debe mostrar solo mensajes del usuario actual" do
    otro_user = users(:two)
    otro_agente = otro_user.agentes.create!(name: "Agente Otro Usuario")
    otra_conversacion = otro_agente.conversaciones.create!
    otro_mensaje = otra_conversacion.mensajes.create!(contenido: "Mensaje de otro usuario")
    sign_in_as(@user)

    get mensajes_url
    assert_response :success
    assert_includes @response.body, @mensaje.id.to_s
    assert_not_includes @response.body, otro_mensaje.id.to_s
  end
end
