require "test_helper"

class MensajeTest < ActiveSupport::TestCase
  def setup
    @conversacion = conversacions(:one)
    @mensaje = mensajes(:one)
  end

  test "debe ser válido" do
    assert @mensaje.valid?
  end

  test "contenido debe estar presente" do
    @mensaje.contenido = nil
    assert_not @mensaje.valid?
    assert_includes @mensaje.errors[:contenido], "no puede estar en blanco"
  end

  test "contenido no puede estar vacío" do
    @mensaje.contenido = ""
    assert_not @mensaje.valid?
    assert_includes @mensaje.errors[:contenido], "no puede estar en blanco"
  end

  test "contenido debe tener longitud mínima de 1" do
    @mensaje.contenido = "a"
    assert @mensaje.valid?
    
    @mensaje.contenido = ""
    assert_not @mensaje.valid?
  end

  test "contenido debe tener longitud máxima de 5000 caracteres" do
    @mensaje.contenido = "a" * 5000
    assert @mensaje.valid?
    
    @mensaje.contenido = "a" * 5001
    assert_not @mensaje.valid?
    assert_includes @mensaje.errors[:contenido], "es demasiado largo (máximo 5000 caracteres)"
  end

  test "debe pertenecer a una conversación" do
    assert_respond_to @mensaje, :conversacion
    assert_equal @conversacion, @mensaje.conversacion
  end

  test "scope recientes debe ordenar por created_at descendente" do
    mensaje_antiguo = @conversacion.mensajes.create!(contenido: "Mensaje antiguo", created_at: 2.days.ago)
    mensaje_reciente = @conversacion.mensajes.create!(contenido: "Mensaje reciente", created_at: 1.day.ago)
    
    mensajes_recientes = Mensaje.recientes
    assert_equal mensaje_reciente, mensajes_recientes.first
    assert_equal mensaje_antiguo, mensajes_recientes.last
  end

  test "scope por_conversacion debe devolver mensajes de la conversación específica" do
    otra_conversacion = conversacions(:two)
    mensaje_otra_conversacion = otra_conversacion.mensajes.create!(contenido: "Mensaje de otra conversación")
    
    mensajes_de_conversacion = Mensaje.por_conversacion(@conversacion.id)
    assert_includes mensajes_de_conversacion, @mensaje
    assert_not_includes mensajes_de_conversacion, mensaje_otra_conversacion
  end

  test "contenido_corto debe devolver contenido completo si es menor a 100 caracteres" do
    @mensaje.contenido = "Este es un mensaje corto"
    assert_equal "Este es un mensaje corto", @mensaje.contenido_corto
  end

  test "contenido_corto debe truncar contenido si es mayor a 100 caracteres" do
    contenido_largo = "Este es un mensaje muy largo que excede los 100 caracteres y por lo tanto debe ser truncado para mostrar solo una vista previa del contenido completo"
    @mensaje.contenido = contenido_largo
    assert_equal "#{contenido_largo[0..97]}...", @mensaje.contenido_corto
  end

  test "contenido_corto debe funcionar con exactamente 100 caracteres" do
    contenido_exacto = "a" * 100
    @mensaje.contenido = contenido_exacto
    assert_equal contenido_exacto, @mensaje.contenido_corto
  end

  test "contenido_corto debe funcionar con 101 caracteres" do
    contenido_101 = "a" * 101
    @mensaje.contenido = contenido_101
    assert_equal "#{contenido_101[0..97]}...", @mensaje.contenido_corto
  end

  test "debe poder crear mensaje con contenido mínimo" do
    mensaje_minimo = @conversacion.mensajes.new(contenido: "a")
    assert mensaje_minimo.valid?
    assert mensaje_minimo.save
  end

  test "debe poder crear mensaje con contenido largo" do
    contenido_largo = "Este es un mensaje con contenido extenso que describe en detalle todos los aspectos importantes de la conversación. Incluye información relevante sobre el tema principal y proporciona contexto adicional para entender mejor la situación actual."
    mensaje_largo = @conversacion.mensajes.new(contenido: contenido_largo)
    assert mensaje_largo.valid?
    assert mensaje_largo.save
  end

  test "debe poder actualizar contenido" do
    nuevo_contenido = "Este es el contenido actualizado del mensaje"
    @mensaje.contenido = nuevo_contenido
    assert @mensaje.save
    assert_equal nuevo_contenido, @mensaje.reload.contenido
  end

  test "debe poder crear mensaje con caracteres especiales" do
    contenido_especial = "¡Hola! ¿Cómo estás? Este mensaje tiene: puntos, comas; y otros símbolos @#$%^&*()"
    mensaje_especial = @conversacion.mensajes.new(contenido: contenido_especial)
    assert mensaje_especial.valid?
    assert mensaje_especial.save
  end

  test "debe poder crear mensaje con emojis" do
    contenido_emoji = "¡Hola! 😊 Este mensaje tiene emojis 🎉 y símbolos especiales ✨"
    mensaje_emoji = @conversacion.mensajes.new(contenido: contenido_emoji)
    assert mensaje_emoji.valid?
    assert mensaje_emoji.save
  end

  test "debe poder crear mensaje con saltos de línea" do
    contenido_multilinea = "Primera línea\nSegunda línea\nTercera línea"
    mensaje_multilinea = @conversacion.mensajes.new(contenido: contenido_multilinea)
    assert mensaje_multilinea.valid?
    assert mensaje_multilinea.save
  end
end
