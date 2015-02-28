When(/I have an authorized Controller defined as/) do |controller_code|
  require 'action_controller'
  require 'eaco/controller'

  @controller_class = Class.new(ActionController::Base)
  @controller_class.send(:attr_accessor, :current_user)
  @controller_class.instance_eval { include Eaco::Controller }
  @controller_class.class_eval controller_code
end

When(/I invoke the Controller "(.+?)" action with query string "(.+?)"$/) do |action_name, query|
  @controller  = @controller_class.new
  @action_name = action_name

  @controller.current_user = @current_user

  @controller.request = ActionDispatch::TestRequest.new('QUERY_STRING' => query).tap do |request|
    request.params.update('action' => @action_name)
  end

  @controller.response = ActionDispatch::TestResponse.new
end

Then(/the Controller should not raise an error/) do
  expect { @controller.process @action_name }.to_not raise_error
end

Then(/the Controller should raise an (.+?) error saying/) do |error_class, error_contents|
  error_class = error_class.constantize

  expect { @controller.process @action_name }.to \
    raise_error(error_class).
    with_message(/#{error_contents}/)
end
