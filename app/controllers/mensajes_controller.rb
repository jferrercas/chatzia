class MensajesController < ApplicationController
  before_action :set_mensaje, only: %i[ show edit update destroy ]
  before_action :authorize_mensaje, only: %i[ show edit update destroy ]

  # GET /mensajes or /mensajes.json
  def index
    @mensajes = Mensaje.includes(conversacion: :agente)
                      .joins(conversacion: :agente)
                      .where(agentes: { user_id: Current.user.id })
  end

  # GET /mensajes/1 or /mensajes/1.json
  def show
  end

  # GET /mensajes/new
  def new
    @mensaje = Mensaje.new
  end

  # GET /mensajes/1/edit
  def edit
  end

  # POST /mensajes or /mensajes.json
  def create
    @mensaje = Mensaje.new(mensaje_params)

    # Verificar que la conversación pertenece a un agente del usuario actual
    unless Current.user.agentes.joins(:conversacions).exists?(conversacions: { id: @mensaje.conversacion_id })
      redirect_to mensajes_path, alert: "No puedes crear mensajes en conversaciones que no te pertenecen."
      return
    end

    respond_to do |format|
      if @mensaje.save
        format.html { redirect_to @mensaje, notice: "Mensaje creado exitosamente." }
        format.json { render :show, status: :created, location: @mensaje }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mensaje.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mensajes/1 or /mensajes/1.json
  def update
    respond_to do |format|
      if @mensaje.update(mensaje_params)
        format.html { redirect_to @mensaje, notice: "Mensaje actualizado exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @mensaje }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mensaje.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mensajes/1 or /mensajes/1.json
  def destroy
    respond_to do |format|
      if @mensaje.destroy
        format.html { redirect_to mensajes_path, notice: "Mensaje eliminado exitosamente.", status: :see_other }
        format.json { head :no_content }
      else
        format.html { redirect_to mensajes_path, alert: "No se pudo eliminar el mensaje." }
        format.json { render json: { error: "No se pudo eliminar el mensaje" }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mensaje
      @mensaje = Mensaje.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mensaje_params
      params.require(:mensaje).permit(:contenido, :conversacion_id)
    end

    def authorize_mensaje
      unless @mensaje.conversacion.agente.user_id == Current.user.id
        redirect_to mensajes_path, alert: "No tienes permisos para acceder a este mensaje."
      end
    end
end
