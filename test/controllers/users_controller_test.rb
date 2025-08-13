require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    @user = users(:one)
    @user_params = {
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  test "debe obtener index" do
    get users_url
    assert_response :success
  end

  test "debe mostrar usuario" do
    sign_in_as(@user)
    get user_url(@user)
    assert_response :success
  end

  test "debe obtener new" do
    get new_user_url
    assert_response :success
  end

  test "debe crear usuario" do
    assert_difference("User.count") do
      post users_url, params: { user: @user_params }
    end

    assert_redirected_to user_url(User.last)
    assert_equal "Usuario creado exitosamente.", flash[:notice]
  end

  test "no debe crear usuario con parámetros inválidos" do
    assert_no_difference("User.count") do
      post users_url, params: { user: { email_address: "", password: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "debe obtener edit" do
    sign_in_as(@user)
    get edit_user_url(@user)
    assert_response :success
  end

  test "debe actualizar usuario" do
    sign_in_as(@user)
    patch user_url(@user), params: { user: { email_address: "nuevo@example.com" } }
    assert_redirected_to user_url(@user)
    assert_equal "Usuario actualizado exitosamente.", flash[:notice]
  end

  test "no debe actualizar usuario con parámetros inválidos" do
    sign_in_as(@user)
    patch user_url(@user), params: { user: { email_address: "" } }
    assert_response :unprocessable_entity
  end

  test "no debe permitir acceso a show sin autenticación" do
    get user_url(@user)
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a edit sin autenticación" do
    get edit_user_url(@user)
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a update sin autenticación" do
    patch user_url(@user), params: { user: { email_address: "nuevo@example.com" } }
    assert_redirected_to new_session_path
  end

  test "no debe permitir acceso a show de otro usuario" do
    otro_user = users(:two)
    sign_in_as(@user)
    get user_url(otro_user)
    assert_redirected_to users_path
    assert_equal "No puedes modificar otros usuarios.", flash[:alert]
  end

  test "no debe permitir acceso a edit de otro usuario" do
    otro_user = users(:two)
    sign_in_as(@user)
    get edit_user_url(otro_user)
    assert_redirected_to users_path
    assert_equal "No puedes modificar otros usuarios.", flash[:alert]
  end

  test "no debe permitir acceso a update de otro usuario" do
    otro_user = users(:two)
    sign_in_as(@user)
    patch user_url(otro_user), params: { user: { email_address: "nuevo@example.com" } }
    assert_redirected_to users_path
    assert_equal "No puedes modificar otros usuarios.", flash[:alert]
  end

  test "debe responder a JSON para show" do
    sign_in_as(@user)
    get user_url(@user), as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para create" do
    post users_url, params: { user: @user_params }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body
  end

  test "debe responder a JSON para update" do
    sign_in_as(@user)
    patch user_url(@user), params: { user: { email_address: "nuevo@example.com" } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body
  end

  test "debe manejar errores JSON en create" do
    post users_url, params: { user: { email_address: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe manejar errores JSON en update" do
    sign_in_as(@user)
    patch user_url(@user), params: { user: { email_address: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body
  end

  test "debe normalizar email_address en create" do
    post users_url, params: { user: { 
      email_address: "  TEST@EXAMPLE.COM  ",
      password: "password123",
      password_confirmation: "password123"
    }}
    assert_redirected_to user_url(User.last)
    assert_equal "test@example.com", User.last.email_address
  end

  test "debe validar formato de email" do
    assert_no_difference("User.count") do
      post users_url, params: { user: { 
        email_address: "invalid-email",
        password: "password123",
        password_confirmation: "password123"
      }}
    end
    assert_response :unprocessable_entity
  end

  test "debe validar unicidad de email" do
    # Crear primer usuario
    post users_url, params: { user: @user_params }
    
    # Intentar crear segundo usuario con mismo email
    assert_no_difference("User.count") do
      post users_url, params: { user: @user_params }
    end
    assert_response :unprocessable_entity
  end
end
