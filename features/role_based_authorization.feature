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

  Scenario: Discretionary access to a Resource
    When I have a confidential Document named "Supa Dupa Fly"
     And I grant Bob access to "Supa Dupa Fly" as a reader in quality of user
    Then Bob should be able to read "Supa Dupa Fly"
     And Tom should not be able to read "Supa Dupa Fly"

  Scenario: Extraction of accessible Resources
    When I have a confidential Document named "Strategic Plan"
     And I grant Bob access to "Strategic Plan" as a reader in quality of user
     And I have a confidential Document named "For Tom"
     And I grant Tom access to "For Tom" as a reader in quality of user
     And I have a confidential Document named "For no one"
    Then Bob can see only "Strategic Plan" in the Document authorized list
     And Tom can see only "For Tom" in the Document authorized list
