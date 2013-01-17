require 'rails/generators/named_base'

module Rails
  module Generators

    class ResourcedGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision :suffix => "Resource"

      argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"

      def create_resourced_file
        template "resource.rb", File.join("app/resources", class_path, "#{file_name}_resource.rb")
      end

      hook_for :test_framework

    protected

      def accessible_attributes
        attributes.reject(&:reference?)
      end

      def type_for(attr)
        type = attr.type
        type = :string if type == :text
        type
      end
    end

  end
end