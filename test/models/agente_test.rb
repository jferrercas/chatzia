require "test_helper"

class AgenteTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @agente = agentes(:one)
  end

  test "debe ser válido" do
    assert @agente.valid?
  end

  test "name debe estar presente" do
    @agente.name = nil
    assert_not @agente.valid?
    assert_includes @agente.errors[:name], "no puede estar en blanco"
  end

  test "name no puede estar vacío" do
    @agente.name = ""
    assert_not @agente.valid?
    assert_includes @agente.errors[:name], "no puede estar en blanco"
  end

  test "debe pertenecer a un usuario" do
    assert_respond_to @agente, :user
    assert_equal @user, @agente.user
  end

  test "debe tener conversaciones" do
    assert_respond_to @agente, :conversaciones
  end

  test "status debe ser válido" do
    valid_statuses = [0, 1, 2, nil]
    valid_statuses.each do |status|
      @agente.status = status
      assert @agente.valid?, "Status #{status} debería ser válido"
    end
  end

  test "status inválido debe ser rechazado" do
    invalid_statuses = [3, -1, "activo", "inactivo"]
    invalid_statuses.each do |status|
      @agente.status = status
      assert_not @agente.valid?, "Status #{status} debería ser inválido"
    end
  end

  test "scope activos debe devolver solo agentes con status 1" do
    # Crear agentes con diferentes status
    agente_activo = @user.agentes.create!(name: "Agente Activo", status: 1)
    agente_inactivo = @user.agentes.create!(name: "Agente Inactivo", status: 0)
    agente_ocupado = @user.agentes.create!(name: "Agente Ocupado", status: 2)
    
    agentes_activos = Agente.activos
    assert_includes agentes_activos, agente_activo
    assert_not_includes agentes_activos, agente_inactivo
    assert_not_includes agentes_activos, agente_ocupado
  end

  test "scope por_usuario debe devolver agentes del usuario específico" do
    otro_user = User.create!(email_address: "otro@example.com", password: "password123")
    agente_otro_user = otro_user.agentes.create!(name: "Agente Otro Usuario")
    
    agentes_del_user = Agente.por_usuario(@user.id)
    assert_includes agentes_del_user, @agente
    assert_not_includes agentes_del_user, agente_otro_user
  end

  test "debe destruir conversaciones al eliminar agente" do
    conversacion_count = @agente.conversaciones.count
    assert_difference 'Conversacion.count', -conversacion_count do
      @agente.destroy
    end
  end

  test "debe poder crear agente sin status" do
    agente_sin_status = @user.agentes.new(name: "Agente Sin Status")
    assert agente_sin_status.valid?
  end

  test "debe poder actualizar status" do
    @agente.status = 1
    assert @agente.save
    assert_equal 1, @agente.reload.status
  end

  test "debe poder cambiar status de activo a ocupado" do
    @agente.status = 1
    @agente.save!
    
    @agente.status = 2
    assert @agente.save
    assert_equal 2, @agente.reload.status
  end
end
