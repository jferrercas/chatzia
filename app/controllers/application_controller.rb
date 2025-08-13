class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  before_action :log_request
  after_action :log_response
  
  private
  
  def log_request
    Rails.logger.info "Request: #{request.method} #{request.path} from #{request.remote_ip}"
  end
  
  def log_response
    Rails.logger.info "Response: #{response.status} for #{request.path}"
  end
  
  def not_found
    Rails.logger.warn "404 Not Found: #{request.path}"
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
      format.json { render json: { error: "Recurso no encontrado" }, status: :not_found }
    end
  end
  
  def bad_request
    Rails.logger.warn "400 Bad Request: #{request.path} - #{request.params}"
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Parámetros inválidos" }
      format.json { render json: { error: "Parámetros inválidos" }, status: :bad_request }
    end
  end
  
  def unprocessable_entity(exception)
    Rails.logger.error "422 Unprocessable Entity: #{exception.message}"
    respond_to do |format|
      format.html { redirect_to :back, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :unprocessable_entity }
    end
  end
end
