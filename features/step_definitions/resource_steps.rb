When(/I have a (\w+) resource defined as/) do |model_name, resource_definition|
  authorize_model model_name, resource_definition
end

When(/I have a confidential (\w+) named "([\w\s]+)"/) do |model_name, resource_name|
  register_resource model_name, resource_name
end

Then(/I should be able to set an ACL on the (\w+)/) do |model_name|
  resource_model = find_model(model_name)
  instance = resource_model.new

  instance.acl = {"foo" => :bar}
  instance.save!

  instance = resource_model.find(instance.id)

  expect(instance.acl).to eq({"foo" => :bar})
  expect(instance.acl).to be_a(resource_model.acl)
end

Then(/(\w+) can see (?:only)? *"(.*?)" in the (\w+) authorized list/) do |actor_name, resource_names, resource_model|
  actor = fetch_actor(actor_name)

  resource_names = resource_names.split(/,\s*/)
  resources = resource_names.map {|name| fetch_resource(resource_model, name)}

  resource_model = find_model(resource_model)
  accessible = resource_model.accessible_by(actor)

  expect(accessible).to match(resources)
end
