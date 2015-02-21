# Eaco

Eacus, the holder of the keys of Hades, is an ACL-based authorization
framework for Ruby.

## Design

Eaco provides your context's Resources discretionary access by an Actor.
Access to the Resource is determined using an ACL.

Different Actors can have different levels of access to the same Resource,
depending on their role as determined by the ACL.

To each role are granted a set of possible abilities, and access is verified
by checking whether a given actor can perform a specific ability.

Actors are described by their Designators, a pluggable mechanism to be
implemented in your application.

Each Actor has many designators that describe either its identity or its
belonging to a group or occupying a position in a department.

Designators are Ruby classes that can embed any sort of custom behaviour that
your application requires.

ACLs are hashes with designators as keys and roles as values. Extracting
authorized collections requires only an hash key lookup mechanism in your
database. Adapters are provided for PG's jsonb and for CouchDB-Lucene.

## Installation within Rails

Add this line to your application's Gemfile:

    gem 'eaco'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eaco

## Usage

Create `config/authorization.rb`:

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

Grant reader access to a specific user:

```ruby
    >> user
    => #<User id:42 name:"Bob Frop">

    >> document.grant :reader, :user, user.id
    => #<Document::ACL "user:42" => :reader>

    >> user.can? :read, d
    => true
```

Grant reader access to a group:

```ruby
    >> user
    => #<User id:42 group_ids:[3,7,1]>

    >> document.grant :reader, :group, 3
    => #<Document::ACL "group:3" => :reader>

    >> user.can? :read, d
    => true

    >> document.allows? :read, user
    => true
```

Obtain a collection of Resources accessible by a given Actor:

```ruby
    >> Document.accessible_by(user)
```

Check whether a controller action can be accessed by an user. Your
`ApplicationController` must respond to `current_user` for this to work.

```ruby
    class DocumentsController < ApplicationController
      before_filter :find_document

      authorize :edit, :update, [:document, :read]

      private
        def find_document
          @document = Document.find(:id)
        end
    end
```

## Contributing

1. Fork it ( https://github.com/ifad/eaco/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
