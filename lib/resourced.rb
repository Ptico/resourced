require "resourced/version"
require "resourced/attributes"
require "resourced/finders"
require 'resourced/class_methods'
require 'resourced/instance_methods'
require "resourced/railtie" if defined?(Rails)

module Resourced
  module Resource
    def self.included(base)
      base.send(:include, Resourced::Attributes)
      base.send(:include, Resourced::Finders)
      base.send(:include, Resourced::InstanceMethods)
      base.extend Resourced::ClassMethods
    end
  end
end