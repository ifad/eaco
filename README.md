# Eaco

[![Build Status](https://travis-ci.org/ifad/eaco.svg)](https://travis-ci.org/ifad/eaco)
[![Coverage Status](https://coveralls.io/repos/ifad/eaco/badge.svg)](https://coveralls.io/r/ifad/eaco) (*currently writing specs*)
[![Code Climate](https://codeclimate.com/github/ifad/eaco/badges/gpa.svg)](https://codeclimate.com/github/ifad/eaco)
[![Inline docs](http://inch-ci.org/github/ifad/eaco.svg?branch=master)](http://inch-ci.org/github/ifad/eaco)
[![Gem Version](https://badge.fury.io/rb/eaco.svg)](http://badge.fury.io/rb/eaco)

Eacus, the holder of the keys of Hades, is an ACL-based authorization
framework for Ruby.

![Eaco e Telamone][eaco-e-telamone]

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

## Installation

Add this line to your application's Gemfile:

    gem 'eaco', github: 'ifad/eaco'

And then execute:

    $ bundle

## Usage

Create `config/authorization.rb` [(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/DSL)

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
    user  from: :id
    group from: :groups
    tag   from: :tags
  end
end
```

Given a Resource [(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/Resource)
with an ACL [(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/ACL):

```ruby
# An example ACL
>> document = Document.first
=> #<Document id:42 name:"President's report for loans.docx" [...]>
>> document.acl
=> #<Document::ACL {"user:10" => :owner, "group:reviewers" => :reader}>
```

and an Actor [(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/Actor):

```ruby
# An example Actor
>> user = User.find(10)
=> #<User id:10 name:"Bob Fropp" group_ids:['employees'], tags:['english']>
>> user.designators
=> #<Set{ #<Designator(User) value:10>, #<Designator(Group) value:"employees">, #<Designator(Tag) value:"english"> }
```

you can check if the Actor can perform a specific action on the Resource:

```ruby
>> user.can? :read, document
=> true

>> document.allows? :read, user
=> true
```

and which access level (`role`) the Actor has for this Resource:

```ruby
>> document.role_of user
=> :owner

>> boss = User.find_by_group('reviewer').first
=> #<User id:42 name:"Jake Leister" group_ids:['reviewers', 'bosses']>

>> document.role_of boss
=> :reader

>> boss.can? :read, document
=> true

>> boss.can? :destroy, document
=> false

>> user.can? :destroy, document
=> true
```

Grant reader access to a specific user:

```ruby
>> user
=> #<User id:42 name:"Bob Frop">

>> document.grant :reader, :user, user.id
=> #<Document::ACL "user:42" => :reader>

>> user.can? :read, document
=> true
```

Grant reader access to a group:

```ruby
>> user
=> #<User id:42 groups:['reviewers']>

>> document.grant :reader, :group, 3
=> #<Document::ACL "group:reviewers" => :reader>

>> user.can? :read, document
=> true

>> document.allows? :read, user
=> true
```

Obtain a collection of Resources accessible by a given Actor [(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/Adapters):

```ruby
>> Document.accessible_by(user)
```

Check whether a controller action can be accessed by an user. Your
`ApplicationController` must respond to `current_user` for this to work.
[(rdoc)](http://www.rubydoc.info/github/ifad/eaco/master/Eaco/Controller)

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

## Running specs

You need a running postgresql 9.4 instance.

Create an user and a database:

    $ sudo -u postgres psql

    postgres=# CREATE ROLE eaco LOGIN;
    CREATE ROLE

    postgres=# CREATE DATABASE eaco OWNER eaco ENCODING 'utf8';
    CREATE DATABASE

    postgres=# ^D

Create `features/active_record.yml` with your database configuration,
see `features/active_record.example.yml` for an example.

Run `bundle` once. This will install the base bundle.

Run `appraisal` once. This will install the supported Rails versions and pg.

Run `rake`. This will run the specs and cucumber features.

Specs are run against the supported rails versions in turn. If you want to
focus on a single release, use `appraisal rails-X.Y rake`, where `X.Y` can be
`3.2`, `4.0`, `4.1` or `4.2`.

## Contributing

1. Fork it ( https://github.com/ifad/eaco/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Denominazione d'Origine Controllata

This software is Made in Italy :it: :smile:.

[eaco-e-telamone]: http://upload.wikimedia.org/wikipedia/commons/7/70/Aeacus_telemon.jpg "Aeacus telemon by user Ravenous at en.wikipedia.org - Public domain through Wikimedia Commons - http://commons.wikimedia.org/wiki/File:Aeacus_telemon.jpg#mediaviewer/File:Aeacus_telemon.jpg"
