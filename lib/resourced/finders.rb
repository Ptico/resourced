require "resourced/attributes"

module Resourced
  module Finders
    class Finders < Resourced::Attributes::RuleSet
      def initialize
        super
        @finders = {}
      end
      attr_reader :finders

      ##
      # Add finder
      #
      # Params:
      # - name    {Symbol} Finder key
      # - options {Hash}   Finder options (optional, default: {})
      #   - default               Default value
      #   - if      {Proc|Symbol} Condition for finder, should return Boolean
      #
      # Examples:
      #
      #     finder :limit, default: 20 do |val|
      #       chain.limit(val)
      #     end
      #
      # Yields: Block with finder/filtration logic with a given parameter value
      #
      def finder(name, options={}, &block)
        name = name.to_sym

        allow(name, options)
        @finders[name] = block

        self
      end
    end

    module InstanceMethods
      def initialize(params, scope)
        super
        @finders_obj = self.class.instance_variable_get(:@_finders_obj)
        @finders = @finders_obj.sanitize_params(self, params)
      end
      attr_reader :finders

      def apply_finders
        defaults = self.class.instance_variable_get(:@_default_finders)
        defaults.each do |finder|
          @chain = self.instance_eval(&finder)
        end

        @finders.each_pair do |key, value|
          @chain = self.instance_exec(value, &@finders_obj.finders[key.to_sym])
        end

        return self
      end
    end

    module ClassMethods
      def finders(&block)
        @_finders_obj ||= Finders.new
        @_finders_obj.instance_eval(&block) if block_given?
      end
      attr_reader :_finders_obj

      def default_finder(&block)
        finders
        @_default_finders << block if block_given?
      end
    end

    def self.included(base)
      base.instance_variable_set(:@_default_finders, [])
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
    end
  end
end