When(/I authorize the (\w+) model/) do |model_name|
  @model = Eaco::Cucumber::ActiveRecord.const_get(model_name)

  Eaco::DSL.authorize @model, using: :pg_jsonb
end

Then(/I should be able to set an ACL on it/) do
  instance = @model.new

  instance.acl = {foo: :bar}
  instance.save!
  instance = @model.find(instance.id)

  instance.acl == {foo: :bar} && instance.acl.class.kind_of?(@model.acl)
end
