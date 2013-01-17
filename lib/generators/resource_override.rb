# Taken from draper gem https://github.com/drapergem/draper/
require "rails/generators"
require "rails/generators/rails/resource/resource_generator"

module Rails
  module Generators
    ResourceGenerator.class_eval do
      def add_resource
        invoke "resourced"
      end
    end
  end
end