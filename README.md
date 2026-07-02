# Eaco

[![CI](https://github.com/iamaestimo/eaco/actions/workflows/ci.yml/badge.svg)](https://github.com/iamaestimo/eaco/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/eaco-abac.svg)](https://rubygems.org/gems/eaco-abac)

Eacus, the holder of the keys of Hades, is an Attribute-Based Access Control ([ABAC](https://en.wikipedia.org/wiki/Attribute-based_access_control)) authorization
framework for Ruby.

Supports **Ruby 3.2–4.0** and **Rails 7.2–8.1**.

> **Note:** the gem is published as [`eaco-abac`](https://rubygems.org/gems/eaco-abac) —
> a maintained continuation of the original [`eaco`](https://github.com/ifad/eaco)
> by [ifad](https://github.com/ifad), whose last release (1.1.1, 2017) supported
> Rails up to 5. Same library, same `require "eaco"`, same DSL — modernized and
> actively developed here.

![Eaco e Telamone][eaco-e-telamone]

*"Aeacus telemon by user Ravenous at en.wikipedia.org - Public domain through Wikimedia Commons - https://commons.wikimedia.org/wiki/File:Aeacus_telemon.jpg"*

## Authentication vs. Authorization

Eaco is an **authorization** library — it decides *what a user is allowed to do*.
It does **not** handle **authentication** (*who the user is*: logins, passwords,
sessions, 2FA). Eaco is designed to sit **on top of** your authentication layer,
whatever it is:

- Rails 8's built-in authentication generator
- [Devise](https://github.com/heartcombo/devise), [Sorcery](https://github.com/Sorcery/sorcery), OmniAuth, etc.
- Your own OIDC/JWT/SSO setup

Once you have a logged-in user, Eaco answers the next question: *what can this
user see and do?*

## Why Eaco? (and when not to)

Eaco's peers are authorization libraries like [Pundit](https://github.com/varvet/pundit),
[CanCanCan](https://github.com/CanCanCommunity/cancancan), and
[Action Policy](https://github.com/palkan/action_policy). The difference is the model:

| | Pundit / CanCanCan / Action Policy | **Eaco** |
|---|---|---|
| Authorization model | **RBAC** — rules defined in code | **ABAC** — ACLs stored as data, per record |
| Where "who can access" lives | Ruby policy classes | The **database** (jsonb / JSON ACL on the row) |
| Per-record, end-user-editable sharing | bolt-on / hand-rolled | **native** — `document.grant :reader, :user, 42` |
| "List everything this user can see" | N+1 or custom scopes | **one indexed lookup** — `Document.accessible_by(user)` |

**Reach for Eaco when** your permissions are *dynamic and per-record* — e.g.
Google-Docs-style sharing ("share this document with Bob and the reviewers
group"), team/folder collaboration, or multi-tenant SaaS with an organization
hierarchy — and when you need to efficiently fetch the set of records a user can
access.

**Reach for Pundit / Action Policy instead when** your rules are simple and
role-based ("admins can do everything, users can edit their own posts"). For that,
a lightweight RBAC gem is the better fit.

For very large, cross-service authorization needs you may also consider
externalized authorization systems (Zanzibar-style services such as OpenFGA, or
policy engines like OSO/Cedar). Eaco's trade-off versus those: it lives inside
your existing database with no extra service to run, and stays idiomatic Ruby.

## Design

Eaco provides your application's Resources discretionary access based on attributes.
Access to a Resource by an Actor is determined by checking whether the Actor owns
the security attributes (Designators) required by the Resource.

Each Resource protected by Eaco has an ACL attached. ACLs define which security
attribute grant access to the Resource, and at which level. The level of access
is expressed in terms of roles. Roles are scoped per Resource types.

Each Role then describes a set of abilities that it can perform. In your code,
you check directly whether an Actor has a specific ability on a Resource, and
all the indirection is then evaluated by Eaco.

## Designators

Security attributes are extracted out of Actors through the Designators framework,
a pluggable mechanism whose details are up to your application.

An Actor can have many designators,  that describe its identity or its belonging
to a group or occupying a position in a department.

Designators are Ruby classes that can embed any sort of custom behaviour that
your application requires.

## ACLS

ACLs are hashes with designators as keys and roles as values. Extracting
authorized collections requires only an hash key lookup mechanism in your
database. Adapters are provided for PG's +jsonb+ and for CouchDB-Lucene.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "eaco-abac", require: "eaco"
```

And then execute:

    $ bundle install

Each authorized model needs a `jsonb` column named `acl` (PostgreSQL):

```ruby
class AddAclToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :acl, :jsonb
  end
end
```

## Usage

Create `config/authorization.rb` [(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/DSL).
It is parsed when your app boots and re-parsed on each code reload in
development. Reference your models with top-level constants (`::Document`) —
the file is evaluated inside Eaco's DSL context, so a bare `Document` would
be looked up under the `Eaco::` namespace.

```ruby
# Defines `Document` to be an authorized resource.
#
# Adds Document.accessible_by and Document#allows?
#
authorize ::Document, using: :pg_jsonb do
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
actor ::User do
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

Given a Resource [(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/Resource)
with an ACL [(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/ACL):

```ruby
# An example ACL
>> document = Document.first
=> #<Document id:42 name:"President's report for loans.docx" [...]>

>> document.acl
=> #<Document::ACL {"user:10" => :owner, "group:reviewers" => :reader}>
```

and an Actor [(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/Actor):

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
>> document.roles_of user
=> [:owner]

>> boss = User.find_by_group('reviewer').first
=> #<User id:42 name:"Jake Leister" group_ids:['reviewers', 'bosses']>

>> document.roles_of boss
=> [:reader]

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

Obtain a collection of Resources accessible by a given Actor
[(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/Adapters):

```ruby
>> Document.accessible_by(user)
```

Check whether a controller action can be accessed by an user. Your
Controller must respond to `current_user` for this to work.
[(rdoc)](https://www.rubydoc.info/github/iamaestimo/eaco/main/Eaco/Controller)

```ruby
class DocumentsController < ApplicationController
  before_action :find_document

  authorize :show, [:document, :read]
  authorize :edit, [:document, :edit]

  private
    def find_document
      @document = Document.find(params[:id])
    end
end
```

## Running specs

You need a running PostgreSQL instance.

Create an user and a database:

    $ sudo -u postgres psql

    postgres=# CREATE ROLE eaco LOGIN PASSWORD 'yourpassword';
    CREATE ROLE

    postgres=# CREATE DATABASE eaco OWNER eaco ENCODING 'utf8';
    CREATE DATABASE

    postgres=# ^D

Create `features/active_record.yml` with your database configuration,
see `features/active_record.example.yml` for an example.

Run `bundle` once. This will install the base bundle.

Run `appraisal` once. This will install the supported Rails versions and +pg+.

Run `rake`. This will run the specs and cucumber features and report coverage.

Specs are run against the supported rails versions in turn. If you want to
focus on a single release, use `appraisal rails-X.Y rake`, where `X.Y` can be
`7.2`, `8.0`, and `8.1`.

## Contributing

1. Fork it ( https://github.com/iamaestimo/eaco/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Denominazione d'Origine Controllata

This software is Made in Italy :it: :smile:.

[eaco-e-telamone]: https://upload.wikimedia.org/wikipedia/commons/7/70/Aeacus_telemon.jpg
