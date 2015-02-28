When(/I am "(.+?)"$/) do |user_name|
  model = find_model('User')

  @current_user = model.where(name: user_name).first!
end

Then(/I can (\w+) the Documents? "(.+?)" being a (\w+)$/) do |permission, document_names, role|
  model = find_model('Document')
  names = document_names.split(/,\s*/)
  documents = model.where(name: names)

  documents.each do |document|
    expect(@current_user.can?(permission, document)).to eq(true)
    expect(document.role_of(@current_user)).to eq(role.intern)
  end
end

Then(/I can not (\w+) the Documents? "(.+?)" *(?:being a (\w+))?$/) do |permission, document_names, role|
  model = find_model('Document')
  names = document_names.split(/,\s*/)
  documents = model.where(name: names)

  documents.each do |document|
    expect(@current_user.cannot?(permission, document)).to eq(true)
    expect(document.role_of(@current_user)).to eq(role ? role.intern : nil)
  end
end

When(/I ask for Documents I can access, I get/) do |table|
  model = find_model('Document')
  names = table.raw.flatten

  expect(model.accessible_by(@current_user).map(&:name)).to match_array(names)
end

When(/I make a Designator with "(\w+)" and "(.+?)"/) do |type, value|
  @designator = Eaco::Designator.make(type, value)
end

When(/I parse the Designator "(.+?)"/) do |text|
  @designator = Eaco::Designator.parse(text)
end

Then(/it should describe itself as "(.+?)"/) do |description|
  expect(@designator.describe).to eq(description)
end

Then(/it should resolve itself to/) do |table|
  names = table.raw.flatten

  expect(@designator.resolve.map(&:name)).to match_array(names)
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
