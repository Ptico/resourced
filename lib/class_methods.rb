module Resourced
  module Resource
    module ClassMethods
      ##
      # Set or get model class
      #
      def model(model_class=nil)
        model_class ? @model = model_class : @model
      end

      ##
      # Duplicate resource and set another model class
      #
      def [](model_class)
        klass = self.dup
        klass.instance_variable_set(:@model, model_class)
        klass
      end

      ##
      # Set primary key
      #
      def key(key_name=nil)
        key_name ? @key = key_name.to_sym : @key
      end
    end
  end
end