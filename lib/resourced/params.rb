require "active_support/core_ext/array"

module Resourced
  module Params

    module InstanceMethods
      def initialize(params, scope)
        set(params)
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
        sanitized = self.class._params_obj.sanitize_params(self, params)

        if @params
          @params.merge(sanitized)
        else
          @params = sanitized
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
          @params.delete(key.to_sym)
        end

        self
      end

    protected

      def params
        @params
      end
    end

    class RuleSet
      def initialize
        @defaults                = {}
        @conditional_allows      = []
        @unconditional_allows    = []
        @conditional_restricts   = []
        @unconditional_restricts = []
      end
      attr_reader :defaults

      ##
      # Allow field(s) to be assigned
      #
      # Options:
      # - default        Default value
      # - if      {Proc} Condition for allowing, should return Boolean
      #
      # Examples:
      #
      #     allow :name, :email, if: -> { scope == :admin }
      #     allow :role, default: "guest"
      #
      def allow(*fields)
        opts = fields.extract_options! # AS

        if opts[:if]
          @conditional_allows << ConditionalGroup.new(opts[:if], fields)
        else
          @unconditional_allows += fields
        end

        if opts[:default]
          fields.each do |field|
            @defaults[field] = opts[:default]
          end
        end

        self
      end

      ##
      # Restrict allowed fields
      #
      # Options:
      # - if {Proc} Condition for restriction, should return Boolean
      #
      # Examples:
      #
      #     restrict :role, if: -> { scope !== :admin }
      #
      def restrict(*fields)
        opts = fields.extract_options! # AS

        if opts[:if]
          @conditional_restricts << ConditionalGroup.new(opts[:if], fields)
        else
          @unconditional_restricts += fields
        end

        self
      end

      def sanitize_params(context, params)
        allowed_params = @unconditional_allows

        @conditional_allows.each do |cond|
          if cond.test(context)
            allowed_params += cond.fields
          end
        end

        allowed_params.uniq!

        allowed_params -= @unconditional_restricts

        @conditional_restricts.each do |cond|
          if cond.test(context)
            allowed_params -= cond.fields
          end
        end

        @defaults.merge(params).symbolize_keys.keep_if { |k, v| allowed_params.include?(k) } # AS
      end
    end

    class ConditionalGroup
      def initialize(condition, fields)
        @condition = case condition
          when Symbol, String
            lambda { send(condition.to_sym) }
          when Proc
            condition
        end

        @fields = fields
      end

      attr_reader :fields

      def test(context)
        !!context.instance_exec(&@condition)
      end
    end

    module ClassMethods
      def params(&block)
        @_params_obj ||= RuleSet.new
        @_params_obj.instance_eval(&block)
      end

      attr_reader :_params_obj
    end

    include InstanceMethods

    def self.included(base)
      base.extend  ClassMethods
    end
  end
end