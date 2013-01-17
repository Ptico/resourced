class <%= class_name %>Resource
  include Resourced::ActiveRecord

  model <%= class_name %>
  body :<%= table_name %>
  key  :id

  attributes do
  <% accessible_attributes.each do |attr| -%>
  allow :<%= attr.name %>, as: :<%= type_for(attr) %>
  <% end -%>
end

  finders do
    
  end
end