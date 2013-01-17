require "rails/railtie"
require "resourced/active_record"

module ActiveModel
  class Railtie < Rails::Railtie
    generators do |app|
      app ||= Rails.application # Rails 3.0.x does not yield `app`

      Rails::Generators.configure! app.config.generators
      require "generators/resource_override"
    end
  end
end

module Resourced
  class Railtie < Rails::Railtie
    config.after_initialize do |app|
      app.config.paths.add "app/resources", eager_load: true
    end
  end
end