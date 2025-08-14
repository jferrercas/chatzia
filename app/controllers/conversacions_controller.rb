class ConversacionsController < ApplicationController
  before_action :set_conversacion, only: %i[ show edit update destroy ]
  before_action :authorize_conversacion, only: %i[ show edit update destroy ]

  # GET /conversacions or /conversacions.json
  def index
    @conversacions = Conversacion.includes(:agente)
                                .joins(:agente)
                                .where(agentes: { user_id: Current.user.id })
  end

  # GET /conversacions/1 or /conversacions/1.json
  def show
  end

  # GET /conversacions/new
  def new
    @conversacion = Conversacion.new
  end

  # GET /conversacions/1/edit
  def edit
  end

  # POST /conversacions or /conversacions.json
  def create
    @conversacion = Conversacion.new(conversacion_params)

    # Verificar que el agente pertenece al usuario actual
    unless Current.user.agentes.exists?(@conversacion.agente_id)
      redirect_to conversacions_path, alert: "No puedes crear conversaciones para agentes que no te pertenecen."
      return
    end

    respond_to do |format|
      if @conversacion.save
        format.html { redirect_to @conversacion, notice: "Conversación creada exitosamente." }
        format.json { render :show, status: :created, location: @conversacion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @conversacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conversacions/1 or /conversacions/1.json
  def update
    respond_to do |format|
      if @conversacion.update(conversacion_params)
        format.html { redirect_to @conversacion, notice: "Conversación actualizada exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @conversacion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @conversacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conversacions/1 or /conversacions/1.json
  def destroy
    respond_to do |format|
      if @conversacion.destroy
        format.html { redirect_to conversacions_path, notice: "Conversación eliminada exitosamente.", status: :see_other }
        format.json { head :no_content }
      else
        format.html { redirect_to conversacions_path, alert: "No se pudo eliminar la conversación." }
        format.json { render json: { error: "No se pudo eliminar la conversación" }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conversacion
      @conversacion = Conversacion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def conversacion_params
      params.require(:conversacion).permit(:agente_id, :duracion, :resumen)
    end

    def authorize_conversacion
      unless @conversacion.agente.user_id == Current.user.id
        redirect_to conversacions_path, alert: "No tienes permisos para acceder a esta conversación."
      end
    end
end
