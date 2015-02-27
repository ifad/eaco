Feature: Rails integration
  The framework should play nice with the most recent major Rails version

  Background:
    Given I have a Document resource defined as
     """
     authorize $MODEL, using: :pg_jsonb
     """

  Scenario:
    Then I should be able to set an ACL on the Document
