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
       admin do |user|
         user.admin?
       end

       designators do
         user from: :id
       end
     end
     """
    Given I have an User actor named "Bob"
      And I have an User actor named "Tom"

  Scenario: Discretionary access to a Resource
    When I have a confidential Document named "Supa Dupa Fly"
     And I grant Bob access to Document "Supa Dupa Fly" as a reader in quality of user
    Then Bob should be able to read Document "Supa Dupa Fly"
     And Tom should not be able to read Document "Supa Dupa Fly"

  Scenario: Extraction of accessible Resources
    When I have a confidential Document named "Strategic Plan"
     And I grant Bob access to Document "Strategic Plan" as a reader in quality of user
     And I have a confidential Document named "For Tom"
     And I grant Tom access to Document "For Tom" as a reader in quality of user
     And I have a confidential Document named "For no one"
    Then Bob can see only "Strategic Plan" in the Document authorized list
     And Tom can see only "For Tom" in the Document authorized list

  Scenario: Admin can see everything
    When I have an admin User actor named "Boss"
     And I have a confidential Document named "For Bob"
     And I grant Bob access to Document "For Bob" as a reader in quality of user
     And I have a confidential Document named "For no one"
     Then Bob can see only "For Bob" in the Document authorized list
      But Boss can see "For Bob, For no one" in the Document authorized list
