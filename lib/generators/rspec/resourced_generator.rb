module Rspec
  class ResourcedGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_spec_file
      template 'resource_spec.rb', File.join('spec/resources', class_path, "#{file_name}_resource_spec.rb")
    end
  end
end