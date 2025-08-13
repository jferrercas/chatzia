module Validatable
  extend ActiveSupport::Concern

  included do
    # Validaciones comunes de seguridad
    validates :created_at, presence: true
    validates :updated_at, presence: true
  end

  class_methods do
    def validates_presence_of_required_fields(*fields)
      fields.each do |field|
        validates field, presence: true
      end
    end
  end
end
