module Resourced
  module ActiveRecord

    module Actions
      def build
        model.new(@body)
      end

      def update
        body = @body.reject { |k,_| k == :id }

        collection = if params[key]
          [model.find(params[key])]
        else
          all
        end

        collection.map do |obj|
          obj.assign_attributes(body)
          obj
        end
      end

      def update!
        body = @body.reject { |k,_| k == :id }

        collection = if params[key]
          [model.find(params[key])]
        else
          all
        end

        collection.map do |obj|
          obj.update_attributes(body)
        end
      end
    end

  end
end