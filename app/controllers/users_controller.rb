class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update ]
  before_action :authorize_user, only: %i[ show edit update ]

  def index
    # Solo permitir acceso a administradores o usuarios autenticados
    @users = User.all if Current.user&.admin?
    redirect_to root_path, alert: "Acceso denegado" unless Current.user&.admin?
  end

  def show
  end

  # GET /agentes/new
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "Usuario creado exitosamente." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "Usuario actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    unless @user.id == Current.user.id
      redirect_to users_path, alert: "No puedes modificar otros usuarios."
    end
  end

  def user_params
    if action_name == "create"
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    else
      params.require(:user).permit(:email_address)
    end
  end
end
