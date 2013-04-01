module Resourced
  module Resource
    module InstanceMethods
      def initialize(params, scope=nil)
        @scope = scope
        @model = self.class.instance_variable_get(:@model)
        @key   = self.class.instance_variable_get(:@key)
        @chain = @model
        super
      end
      attr_accessor :scope
      attr_reader   :model, :chain, :key

      ##
      # Run external code in context of resource
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

      ##
      # Set additional params
      #
      # Params:
      # - params {Hash} List of params to be assigned
      #
      # Examples:
      #
      #     resource = UserResource.new(params, scope)
      #     resource.set(role: "guest")
      #
      def set(params={})
        return if params.nil?
        debugger
        sanitized_attributes = self.class._attributes_obj.sanitize_params(self, params)

        if @attributes
          @attributes.merge!(sanitized_attributes)
        else
          @attributes = sanitized_attributes
        end

        sanitized_finders = self.class._finders_obj.sanitize_params(self, params)

        if @finders
          @finders.merge!(sanitized_finders)
        else
          @finders = sanitized_finders
        end

        self
      end

      ##
      # Erase existing params
      #
      # Params:
      # - params {Hash} List of param keys to be erased
      #
      # Examples:
      #
      #     resource = UserResource.new(params, scope)
      #     resource.erase(:password, :auth_token)
      #
      def erase(*keys)
        keys.each do |key|
          @attributes.delete(key.to_sym)
          @finders.delete(key.to_sym)
        end

        self
      end
    end
  end
end