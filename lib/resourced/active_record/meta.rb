module Resourced

  module ActiveRecord
    module Meta
      def attributes
        @attributes ||= Hash[model.columns.map{ |c| [c.name.to_sym, c.type] }]
      end

      def attribute_names
        attributes.keys
      end
    end
  end

end