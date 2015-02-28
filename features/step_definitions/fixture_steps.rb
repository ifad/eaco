Given(/I have the following (\w+) records/) do |model_name, table|
  model = find_model(model_name)

  table.hashes.each do |attributes|
    instance = model.new

    if attributes.key?('acl')
      attributes['acl'] = MultiJson.load(attributes['acl'])
    end

    instance.attributes = attributes
    instance.save!
  end
end
