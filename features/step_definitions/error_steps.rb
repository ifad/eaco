When(/I have a wrong authorization definition (?:on model (.+?))? *such as/) do |model_name, definition|
  @model_name = model_name
  @definition = definition
end

Then(/I should get an? (.+?) error back saying/) do |error_class, error_contents|
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
