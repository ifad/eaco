Feature: Authorization rules error handling
  When there's an error in the authorization rules,
  it is reported in detail with a backtrace showing
  where it happened.

  Scenario: Giving rubbish
    When I have a wrong authorization definition such as
     """
     1=1
     """
    Then I should receive a DSL error SyntaxError saying
     """
     \(feature\):1: syntax error, unexpected '=', expecting end-of-input
     """

  Scenario: Referencing a non-existing model
    When I have a wrong authorization definition such as
     """
     authorize ::Nonexistant, using: :pg_jsonb
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     uninitialized constant Nonexistant
     """

  Scenario: Specifying an actor class with no Designators namespace
    When I have a wrong authorization definition such as
    """
    class ::Foo
    end

    actor Foo do
      designators do
        frobber yay: true
      end
    end
    """
    Then I should receive a DSL error Eaco::Error saying
    """
    Please put designators implementations in Foo::Designators
    """

  Scenario: Specifing a non-existing designator implementation
    When I have a wrong authorization definition on model User such as
     """
     actor $MODEL do
       designators do
         fropper from: :sgurtz
       end
     end
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Implementation .+User::Designators::Fropper for Designator fropper not found
     """

  Scenario: Badly specifying the designator options
    When I have a wrong authorization definition on model User such as
     """
     actor $MODEL do
       designators do
         user on_the_rocks: true
       end
     end
     """
    Then I should receive a DSL error Eaco::Error saying
    """
    The designator option :from is required
    """

  Scenario: Badly specifying the permissions options
    When I have a wrong authorization definition on model Document such as
     """
     authorize $MODEL do
       permissions do
         reader "Asdrubbale"
       end
     end
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Invalid reader permission definition: "Asdrubbale"
     """

  Scenario: Authorizing an Object with no known ORM
    When I have a wrong authorization definition such as
     """
     class ::Foo
     end

     authorize Foo
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Don't know how to persist ACLs using <Foo>'s ORM
     """

  Scenario: Authorizing an Resource with no known .accessible_by
    When I have a wrong authorization definition such as
     """
     class ::Bar
       attr_accessor :acl
     end

     authorize Bar
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Don't know how to look up authorized records on <Bar>'s ORM
     """

  Scenario: Authorizing a Resource with a known ORM but without the acl field
    When I have a wrong authorization definition on model Department such as
     """
     authorize $MODEL
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Please define a jsonb column named `acl` on .+Department
     """

  Scenario: Authorizing a Resource with a known ORM but unknown strategy
    When I have a wrong authorization definition on model Document such as
     """
     authorize $MODEL
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     .+Document.+ORM.+ActiveRecord::Base.+ use one of the available strategies: pg_jsonb
     """

  Scenario: Authorizing a Resource with the wrong ACL column type
    When I have a wrong authorization definition such as
     """
     class ::Grabach < ActiveRecord::Base
       connection.create_table 'grabaches' do |t|
         t.string :acl
       end
     end

     authorize ::Grabach
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     The `acl` column on Grabach must be of the jsonb type
     """

  Scenario: Using an unsupported ActiveRecord version
    When I am using ActiveRecord 3.0
     And I have a wrong authorization definition on model Document such as
     """
     authorize $MODEL
     """
    Then I should receive a DSL error Eaco::Error saying
     """
     Unsupported Active Record version: 30
     """
