# frozen_string_literal: true

module RegistrationError
  class Base < StandardError; end
  class Unauthorized < Base; end
end