require "resourced/version"
require "resourced/attributes"
require "resourced/finders"
require 'class_methods'
require 'instance_methods'
require "resourced/railtie" if defined?(Rails)

module Resourced
  module Resource
    def self.included(base)
      base.send(:include, Resourced::Attributes)
      base.send(:include, Resourced::Finders)
      base.send(:include, InstanceMethods)
      base.extend ClassMethods
    end
  end
end