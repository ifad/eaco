Given(/I have an (\w+) actor defined as/) do |model_name, actor_definition|
  authorize_model model_name, actor_definition
end

Given(/I have an (\w+) actor named "(.+?)"/) do |model_name, actor_name|
  register_actor model_name, actor_name
end

Given(/I have an admin (\w+) actor named "(.+?)"/) do |model_name, actor_name|
  register_actor model_name, actor_name, admin: true
end

When(/I grant (\w+) access to (\w+) "(.+?)" as a (\w+) in quality of (\w+)/) do |actor_name, resource_model, resource_name, role_name, designator|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  resource.grant role_name, designator, actor
  resource.save!
end

Then(/^(\w+) should be able to (\w+) (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_model, resource_name|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  unless actor.can? permission_name, resource
    raise "Expected #{actor_name} to be able to #{permission_name} #{resource_name}"
  end
end

Then(/^(\w+) should not be able to (\w+) (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_model, resource_name|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  unless actor.cannot? permission_name, resource
    raise "Expected #{actor_name} to not be able to #{permission_name} #{resource_model} #{resource_name}"
  end
end

