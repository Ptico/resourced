module Resourced
  module ActiveRecord

    module Actions
      def build
        model.new(@attributes)
      end

      def update
        body = @attributes.reject { |k,_| k == :id }

        collection = if attributes[key]
          [model.find(attributes[key])]
        else
          all
        end

        collection.map do |obj|
          obj.assign_attributes(body)
          obj
        end
      end

      def update!
        body = @attributes.reject { |k,_| k == :id }

        collection = if @attributes[key]
          [model.find(@attributes[key])]
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