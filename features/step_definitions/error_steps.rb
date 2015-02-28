When(/I have a wrong authorization definition (?:on model (.+?))? *such as/) do |model_name, definition|
  @model_name = model_name
  @definition = definition
end

Then(/I should receive a DSL error (.+?) saying/) do |error_class, error_contents|
  error_class = error_class.constantize

  model = find_model(@model_name) if @model_name

  error_contents += '.+(feature)' unless error_contents.include?('\(feature\)')

  expect { eval_dsl(@definition, model) }.to \
    raise_error(error_class).
    with_message(/#{error_contents}/m)
end

When(/I am using ActiveRecord (.+?)$/) do |version|
  version = version.sub(/\D/, '') # FIXME

  allow_any_instance_of(Eaco::Adapters::ActiveRecord::Compatibility).to \
    receive(:active_record_version).and_return(version)
end

When(/I parse the invalid Designator "(.+?)"/) do |text|
  @designator_text = text
end

Then(/I should receive a Designator error (.+?) saying/) do |error_class, error_contents|
  error_class = error_class.constantize

  expect { Eaco::Designator.parse(@designator_text) }.to \
    raise_error(error_class).
    with_message(/#{error_contents}/)
end

When(/I grant (\w+) access to (\w+) "(.+?)" as an invalid role (\w+) in quality of (\w+)/) do |actor_name, resource_model, resource_name, role_name, designator|
  @actor = fetch_actor(actor_name)
  @resource = fetch_resource(resource_model, resource_name)
  @role_name, @designator = role_name, designator
end

Then(/I should receive a Resource error (.+?) saying/) do |error_class, error_contents|
  error_class = error_class.constantize

  expect { @resource.grant @role_name, @designator, @actor }.to \
    raise_error(error_class).
    with_message(/#{error_contents}/)
end
