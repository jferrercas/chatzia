ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthenticationTestHelper
  def sign_in_as(user)
    # Crear una sesión directamente para el usuario
    session = user.sessions.create!(
      user_agent: "Rails Testing",
      ip_address: "127.0.0.1"
    )

    # Establecer la cookie de sesión
    cookies.signed[:session_id] = session.id

    # Establecer la sesión actual
    Current.session = session
  end
end
