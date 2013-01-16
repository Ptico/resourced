require "resourced"
require "resourced/active_record/proxy"
require "resourced/active_record/actions"

module Resourced
  module ActiveRecord

    module Helpers
      def t
        @table ||= model.arel_table
      end
    end

    module ClassMethods
      def key(key_name=nil)
        super
        key_name = key_name.to_sym
        finders do
          finder key_name do |v|
            chain.where(key_name => v)
          end
        end
      end
    end

    def self.included(base)
      base.send(:include, Resourced::Resource)
      base.send(:include, Proxy)
      base.send(:include, Actions)
      base.extend ClassMethods
    end

  end
end