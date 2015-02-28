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

When(/I grant access to (\w+) "(.+?)" to the following designators as (\w+)/) do |resource_model, resource_name, role, table|
  resource = fetch_resource(resource_model, resource_name)
  designators = table.raw.flatten.map {|d| Eaco::Designator.parse(d) }

  resource.batch_grant role, designators
  resource.save!
end

When(/I revoke (\w+) access to (\w+) "(.+?)" in quality of (\w+)/) do |actor_name, resource_model, resource_name, designator|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  resource.revoke designator, actor
  resource.save!
end

Then(/^(\w+) should be able to (\w+) (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_model, resource_name|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  expect(actor.can?(permission_name, resource)).to be(true)
end

Then(/^(\w+) should not be able to (\w+) (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_model, resource_name|
  actor = fetch_actor(actor_name)
  resource = fetch_resource(resource_model, resource_name)

  expect(actor.cannot?(permission_name, resource)).to be(true)
end
