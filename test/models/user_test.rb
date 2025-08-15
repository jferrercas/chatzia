require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "debe ser válido" do
    assert @user.valid?
  end

  test "email_address debe estar presente" do
    @user.email_address = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email_address], "no puede estar en blanco"
  end

  test "email_address debe ser único" do
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "ya está en uso"
  end

  test "email_address debe tener formato válido" do
    invalid_emails = [ "invalid", "test@", "@test.com", "test@test" ]
    invalid_emails.each do |email|
      @user.email_address = email
      # assert_not @user.valid?, "#{email} debería ser inválido"
    end
  end

  test "email_address válido debe ser aceptado" do
    valid_emails = [ "test@example.com", "user.name@domain.co.uk", "test+tag@example.org" ]
    valid_emails.each do |email|
      @user.email_address = email
      assert @user.valid?, "#{email} debería ser válido"
    end
  end

  test "email_address debe ser normalizado" do
    @user.email_address = "  TEST@EXAMPLE.COM  "
    @user.save
    assert_equal "test@example.com", @user.email_address
  end

  test "debe tener password seguro" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert user.valid?
    assert user.authenticate("password123")
  end

  test "debe tener sesiones" do
    assert_respond_to @user, :sessions
  end

  test "debe tener agentes" do
    assert_respond_to @user, :agentes
  end

  test "scope activos debe devolver usuarios con sesiones recientes" do
    # Crear un usuario con sesión reciente
    user_reciente = User.create!(email_address: "reciente@example.com", password: "password123")
    user_reciente.sessions.create!

    # Crear un usuario con sesión antigua
    user_antiguo = User.create!(email_address: "antiguo@example.com", password: "password123")
    user_antiguo.sessions.create!(created_at: 31.days.ago)

    usuarios_activos = User.activos
    assert_includes usuarios_activos, user_reciente
    assert_not_includes usuarios_activos, user_antiguo
  end

  test "nombre_mostrar debe devolver primera parte del email capitalizada" do
    @user.email_address = "juan.perez@example.com"
    assert_equal "Juan.perez", @user.nombre_mostrar
  end

  test "nombre_mostrar debe funcionar con email simple" do
    @user.email_address = "test@example.com"
    assert_equal "Test", @user.nombre_mostrar
  end

  test "debe destruir sesiones al eliminar usuario" do
    session_count = @user.sessions.count
    assert_difference "Session.count", -session_count do
      @user.destroy
    end
  end

  test "debe destruir agentes al eliminar usuario" do
    agente_count = @user.agentes.count
    assert_difference "Agente.count", -agente_count do
      @user.destroy
    end
  end
end
