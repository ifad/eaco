When(/I have a (\w+) resource defined as/) do |model_name, resource_definition|
  @resource_model = find_model(model_name)

  eval_dsl resource_definition, @resource_model
end

When(/I have a confidential \w+ named "([\w\s]+)"/) do |name|
  @resources ||= {}
  @resources[name] = @resource_model.new(name: name)
end

Then(/I should be able to set an ACL on it/) do
  instance = @resource_model.new

  instance.acl = {foo: :bar}
  instance.save!
  instance = @resource_model.find(instance.id)

  instance.acl == {foo: :bar} && instance.acl.class.kind_of?(@resource_model.acl)
end

Then(/(\w+) can see only "(.*?)" in the (\w+) authorized list/) do |actor_name, resource_names, model_name|
  actor = @actors[actor_name]

  resource_names = resource_names.split(',')
  resources = resource_names.map {|name| @resources.fetch(name)}

  model = find_model(model_name)
  (model.accessible_by(actor) & resources) == resources
end
