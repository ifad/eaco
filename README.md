# Eaco

Eacus, the holder of the keys of Hades, is an ACL-based authorization framework for Ruby.

## Design

TODO

## Installation

Add this line to your application's Gemfile:

    gem 'eaco'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eaco

## Usage

`config/authorization.rb`:

```ruby

    # Defines `Document` to be an authorized resource.
    #
    # Adds Document.accessible_by and Document#allows
    #
    authorize Document, using: :lucene do
      roles :owner, :editor, :reader

      permissions do
        reader   :read
        editor   reader, :edit
        assignee editor
        owner    editor, :destroy
      end
    end


    # Defines an actor and the sources from which the
    # designators are harvested.
    #
    # Adds User#designators
    #
    actor User do
      admin do |user|
        user.admin?
      end

      designators do
        user       from: :id
        group      from: :group_ids
        department from: :department_ids
      end
    end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/eaco/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
