Feature: Rails integration
  The framework should play nice with the most recent major Rails version

  Background:
    When I authorize the Document model

  Scenario:
    Then I should be able to set an ACL on it
