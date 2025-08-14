class AgentesController < ApplicationController
  before_action :set_agente, only: %i[ show edit update destroy ]
  before_action :authorize_agente, only: %i[ show edit update destroy ]

  # GET /agentes or /agentes.json
  def index
    @agentes = Current.user.agentes
  end

  # GET /agentes/1 or /agentes/1.json
  def show
  end

  # GET /agentes/new
  def new
    @agente = Agente.new
  end

  # GET /agentes/1/edit
  def edit
  end

  # POST /agentes or /agentes.json
  def create
    @agente = Current.user.agentes.build(agente_params)

    respond_to do |format|
      if @agente.save
        format.html { redirect_to @agente, notice: "Agente creado exitosamente." }
        format.json { render :show, status: :created, location: @agente }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agente.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agentes/1 or /agentes/1.json
  def update
    respond_to do |format|
      if @agente.update(agente_params)
        format.html { redirect_to @agente, notice: "Agente actualizado exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @agente }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agente.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agentes/1 or /agentes/1.json
  def destroy
    respond_to do |format|
      if @agente.destroy
        format.html { redirect_to agentes_path, notice: "Agente eliminado exitosamente.", status: :see_other }
        format.json { head :no_content }
      else
        format.html { redirect_to agentes_path, alert: "No se pudo eliminar el agente." }
        format.json { render json: { error: "No se pudo eliminar el agente" }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agente
      @agente = Agente.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def agente_params
      params.require(:agente).permit(:name, :channels, :status)
    end

    def authorize_agente
      unless @agente.user_id == Current.user.id
        redirect_to agentes_path, alert: "No tienes permisos para acceder a este agente."
      end
    end
end
