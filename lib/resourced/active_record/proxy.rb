module Resourced

  module ActiveRecord

    module Proxy
      include Enumerable

      def first
        apply_finders.chain.first
      end

      def last
        apply_finders.chain.last
      end

      def all
        apply_finders.chain.all
      end

      def each(&block)
        all.each(&block)
      end

      def as_json(*args)
        all.as_json(*args)
      end

      def to_json(*args)
        all.to_json(*args)
      end
    end

  end

end