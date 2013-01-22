require "coercible"

module Resourced
  module Attributes

    module InstanceMethods
      def initialize(params, scope)
        @attr_body = self.class.body
        set(@attr_body ? params[@attr_body] : params)
      end
      attr_reader :attributes, :attr_body

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
        sanitized = self.class._attributes_obj.sanitize_params(self, params)

        if @attributes
          @attributes.merge(sanitized)
        else
          @attributes = sanitized
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
        end

        self
      end
    end

    class RuleSet
      def initialize
        @types                   = {}
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
        opts = extract_options(fields)

        if opts[:if]
          @conditional_allows << ConditionalGroup.new(opts[:if], fields)
        else
          @unconditional_allows += fields
        end

        if as = opts[:as]
          fields.each do |field|
            @types[field] = :"to_#{as}"
          end
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
        opts = extract_options(fields)

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

        result = {}
        coercer = Coercible::Coercer.new unless @types.empty?

        @defaults.merge(params).each do |k, v|
          k = k.to_sym

          if allowed_params.include?(k)
            result[k] = @types[k] ? coercer[v.class].public_send(@types[k], v) : v
          end
        end

        result
      end

    private
      def extract_options(args)
        if args.last.is_a?(Hash)
          args.pop
        else
          {}
        end
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
      def attributes(&block)
        @_attributes_obj ||= RuleSet.new
        @_attributes_obj.instance_eval(&block)
      end

      def body(name=nil)
        name ? @attr_body = name : @attr_body
      end

      attr_reader :_attributes_obj
    end

    include InstanceMethods

    def self.included(base)
      base.extend ClassMethods
    end
  end
end