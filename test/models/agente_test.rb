require "test_helper"

class AgenteTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @agente = @user.agentes.build(name: "Agente Test")
  end

  test "should be valid" do
    assert @agente.valid?
  end

  test "name should be present" do
    @agente.name = nil
    assert_not @agente.valid?
  end

  test "name should not be too long" do
    @agente.name = "a" * (AppConstants::LIMITES[:nombre_agente_max] + 1)
    assert_not @agente.valid?
  end

  test "status should be valid" do
    AppConstants::AGENTE_ESTADOS.values.each do |status|
      @agente.status = status
      assert @agente.valid?, "#{status} should be a valid status"
    end
  end

  test "status should not be invalid" do
    @agente.status = 999
    assert_not @agente.valid?
  end

  test "should belong to user" do
    @agente.user = nil
    assert_not @agente.valid?
  end

  test "activos scope should return active agents" do
    @agente.status = AppConstants::AGENTE_ESTADOS[:activo]
    @agente.save!
    
    assert_includes Agente.activos, @agente
  end

  test "por_usuario scope should return user agents" do
    @agente.save!
    
    assert_includes Agente.por_usuario(@user.id), @agente
  end

  test "estado_nombre should return correct status name" do
    @agente.status = AppConstants::AGENTE_ESTADOS[:activo]
    assert_equal "Activo", @agente.estado_nombre
    
    @agente.status = AppConstants::AGENTE_ESTADOS[:inactivo]
    assert_equal "Inactivo", @agente.estado_nombre
    
    @agente.status = AppConstants::AGENTE_ESTADOS[:ocupado]
    assert_equal "Ocupado", @agente.estado_nombre
    
    @agente.status = nil
    assert_equal "Desconocido", @agente.estado_nombre
  end

  test "should have many conversacions" do
    assert_respond_to @agente, :conversacions
  end
end
