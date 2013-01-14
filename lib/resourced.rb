require "resourced/version"
require "resourced/params"
require "resourced/finders"

module Resourced
  module Facade
    module InstanceMethods
      def initialize(params, scope)
        @scope = scope
        @model = self.class.instance_variable_get(:@model)
        @key   = self.class.instance_variable_get(:@key)
        @chain = @model
        super
        @body  = @params.keep_if { |k, v| attribute_names.include?(k) }
      end
      attr_accessor :params, :scope
      attr_reader   :model, :chain

      ##
      # Run external code in context of facade
      #
      # Examples:
      #
      #     resource = UserResource.new(params, scope)
      #     subj = "john"
      #     resource.context do
      #       chain.where(name: subj)
      #     end
      #
      def context(&block)
        if block_given?
          @chain = self.instance_eval(&block)
        end

        self
      end
    end

    module ClassMethods
      ##
      # Set or get model class
      #
      def model(model_class=nil)
        model_class ? @model = model_class : @model
      end

      ##
      # Duplicate facade and set another model class
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

    def self.included(base)
      base.send(:include, Resourced::Params)
      base.send(:include, Resourced::Finders)
      base.send(:include, InstanceMethods)
      base.extend ClassMethods
    end
  end
end