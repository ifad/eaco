RSpec::Matchers.define :be_able_to do |*args|
  match do |actor|
    actor.can?(*args)
  end

  failure_message do |actor|
    "expected to be able to #{args.map(&:inspect).join(" ")}"
  end

  failure_message_when_negated do |actor|
    "expected not to be able to #{args.map(&:inspect).join(" ")}"
  end
end
