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

Then(/it should have a label of "(.+?)"/) do |label|
  expect(@designator.label).to eq(label)
end

Then(/it should resolve itself to/) do |table|
  names = table.raw.flatten

  expect(@designator.resolve.map(&:name)).to match_array(names)
end

When(/I have the following designators/) do |table|
  @designators = table.raw.flatten
end

Then(/they should resolve to/) do |table|
  resolved = Eaco::Designator.resolve(@designators)
  names = table.raw.flatten

  expect(resolved.map(&:name)).to match_array(names)
end

When(/I ask the Document the list of roles and labels/) do
  model = find_model('Document')

  @roles_labels = model.roles_with_labels
end

Then(/I should get the following roles and labels/) do |table|
  expected = table.raw.map do |role, label|
    [role.to_sym, label]
  end

  expect(@roles_labels.to_a).to match(expected)
end
