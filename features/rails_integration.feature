Feature: Rails integration
  The framework should play nice with the most recent major Rails version

  Background:
    Given I am connected to the database
    And I have a schema defined

  Scenario:
    When I authorize the Document model
    Then I should be able to set an ACL on it
