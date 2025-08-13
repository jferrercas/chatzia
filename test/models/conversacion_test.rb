require "test_helper"

class ConversacionTest < ActiveSupport::TestCase
  def setup
    @agente = agentes(:one)
    @conversacion = conversacions(:one)
  end

  test "debe ser válido" do
    assert @conversacion.valid?
  end

  test "debe pertenecer a un agente" do
    assert_respond_to @conversacion, :agente
    assert_equal @agente, @conversacion.agente
  end

  test "debe tener mensajes" do
    assert_respond_to @conversacion, :mensajes
  end

  test "duracion debe ser numérica y mayor que 0" do
    @conversacion.duracion = 30
    assert @conversacion.valid?

    @conversacion.duracion = 0
    assert_not @conversacion.valid?
    assert_includes @conversacion.errors[:duracion], "debe ser mayor que 0"

    @conversacion.duracion = -5
    assert_not @conversacion.valid?
    assert_includes @conversacion.errors[:duracion], "debe ser mayor que 0"
  end

  test "duracion puede ser nil" do
    @conversacion.duracion = nil
    assert @conversacion.valid?
  end

  test "resumen debe tener longitud máxima de 1000 caracteres" do
    @conversacion.resumen = "a" * 1000
    assert @conversacion.valid?

    @conversacion.resumen = "a" * 1001
    assert_not @conversacion.valid?
    assert_includes @conversacion.errors[:resumen], "es demasiado largo (máximo 1000 caracteres)"
  end

  test "resumen puede ser nil" do
    @conversacion.resumen = nil
    assert @conversacion.valid?
  end

  test "resumen puede estar vacío" do
    @conversacion.resumen = ""
    assert @conversacion.valid?
  end

  test "scope recientes debe ordenar por created_at descendente" do
    conversacion_antigua = @agente.conversaciones.create!(created_at: 2.days.ago)
    conversacion_reciente = @agente.conversaciones.create!(created_at: 1.day.ago)

    conversaciones_recientes = Conversacion.recientes
    assert_equal conversacion_reciente, conversaciones_recientes.first
    assert_equal conversacion_antigua, conversaciones_recientes.last
  end

  test "scope por_agente debe devolver conversaciones del agente específico" do
    otro_agente = agentes(:two)
    conversacion_otro_agente = otro_agente.conversaciones.create!

    conversaciones_del_agente = Conversacion.por_agente(@agente.id)
    assert_includes conversaciones_del_agente, @conversacion
    assert_not_includes conversaciones_del_agente, conversacion_otro_agente
  end

  test "duracion_formateada debe devolver duración en minutos" do
    @conversacion.duracion = 45
    assert_equal "45 minutos", @conversacion.duracion_formateada
  end

  test "duracion_formateada debe devolver mensaje cuando duración es nil" do
    @conversacion.duracion = nil
    assert_equal "Sin duración", @conversacion.duracion_formateada
  end

  test "duracion_formateada debe funcionar con duración de 1 minuto" do
    @conversacion.duracion = 1
    assert_equal "1 minutos", @conversacion.duracion_formateada
  end

  test "debe destruir mensajes al eliminar conversación" do
    mensaje_count = @conversacion.mensajes.count
    assert_difference "Mensaje.count", -mensaje_count do
      @conversacion.destroy
    end
  end

  test "debe poder crear conversación sin duración ni resumen" do
    conversacion_minima = @agente.conversaciones.new
    assert conversacion_minima.valid?
  end

  test "debe poder actualizar duración" do
    @conversacion.duracion = 60
    assert @conversacion.save
    assert_equal 60, @conversacion.reload.duracion
  end

  test "debe poder actualizar resumen" do
    nuevo_resumen = "Esta es una conversación muy interesante sobre el tema principal"
    @conversacion.resumen = nuevo_resumen
    assert @conversacion.save
    assert_equal nuevo_resumen, @conversacion.reload.resumen
  end

  test "debe poder crear conversación completa" do
    conversacion_completa = @agente.conversaciones.new(
      duracion: 30,
      resumen: "Conversación sobre el estado del proyecto"
    )
    assert conversacion_completa.valid?
    assert conversacion_completa.save
  end
end
