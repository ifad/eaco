Given(/I have an (\w+) actor defined as/) do |model_name, author_definition|
  @actor_model = find_model(model_name)

  eval_dsl author_definition, @actor_model
end

Given(/I have an actor named (\w+)/) do |actor_name|
  actor = @actor_model.new
  actor.name = actor_name

  @actors ||= {}
  @actors[actor_name] = actor
end

When(/I grant (\w+) access to "(.+?)" as a (\w+) in quality of (\w+)/) do |actor_name, resource_name, role_name, designator|
  actor = @actors.fetch(actor_name)
  @resources[resource_name].grant role_name, designator, actor
  @resources[resource_name].save!
end

Then(/^(\w+) should be able to (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_name|
  actor = @actors.fetch(actor_name)
  actor.can? permission_name, @resources.fetch(resource_name)
end

Then(/^(\w+) should not be able to (\w+) "(.+?)"$/) do |actor_name, permission_name, resource_name|
  actor = @actors.fetch(actor_name)
  actor.cannot? permission_name, @resources.fetch(resource_name)
end

