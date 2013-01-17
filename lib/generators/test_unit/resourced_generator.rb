module TestUnit
  class ResourcedGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_test_file
      template 'resource_test.rb', File.join('test/resources', class_path, "#{file_name}_resource_test.rb")
    end
  end
end