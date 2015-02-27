Feature: Role-Based authorization
  Access to a Resource by an Actor is determined by the
  ACL set on the Resource and the Designators the Actor
  is eligible.

  Background:
    Given I have a Document resource defined as
     """
     authorize $MODEL, using: :pg_jsonb do
        roles :reader, :writer

        permissions do
          reader :read
          writer reader, :write
        end
      end
     """
    And I have an User actor defined as
     """
     actor $MODEL do
       designators do
         user from: :id
       end
     end
     """
    Given I have an actor named Bob
      And I have an actor named Tom

  Scenario:
     And I have a confidential one named "Supa Dupa Fly"
     And I grant Bob access as a reader in quality of user
    Then Bob should be able to read it
     And Tom should not be able to read it
