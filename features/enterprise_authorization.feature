Feature: Role-based, flexible authorization
  In an enterprise, rights might be granted to specific users, to any users,
  or to specific departments or to specific positions in said departments.

  Background:
    Given I have an User actor defined as
      """
      actor $MODEL do
        designators do
          authenticated from: :class
          user          from: :id
          position      from: :position_ids
          department    from: :department_names
        end
      end
      """
    Given I have a Document resource defined as
      """
      authorize $MODEL, using: :pg_jsonb do
        roles :writer, :reader

        permissions do
          reader :read
          writer reader, :write
        end
      end
      """

    Given I have the following User records
      | id | name            |
      |  1 | Dennis Ritchie  |
      |  2 | Rob Pike        |
      |  3 | William Gates   |
      |  4 | Steve Jobs      |
      |  5 | Tim Berners-Lee |

    Given I have the following Department records
      | id | name |
      |  1 | ICT  |
      |  2 | BAR  |
      |  3 | COM  |

    Given I have the following Position records
      | id | name                 | department_id | user_id |
      |  1 | Director             |       1       |    1    |
      |  2 | Systems Analyst      |       1       |    2    |
      |  3 | Bartender            |       2       |    3    |
      |  4 | Director             |       3       |    4    |
      |  5 | Social Media Manager |       3       |    5    |

    Given I have the following Document records
      | name              | acl                                                    |
      | ICT Status Report | {"department:ICT":"reader", "position:1":"writer"}     |
      | ICT Budget Report | {"position:1":"writer"}                                |
      | Cafeteria Menu    | {"position:3":"writer", "authenticated:Eaco::Cucumber::ActiveRecord::User":"reader"} |
      | Tim's Web Project | {"user:5":"writer", "position:2":"reader"}             |

  Scenario: The Director can access confidential document
    When I am "Dennis Ritchie"
    Then I can read the Document "ICT Status Report" being a writer
     And I can write the Document "ICT Budget Report" being a writer
     And I can read the Document "Cafeteria Menu" being a reader
     But I can not read the Document "Tim's Web Project"
    When I ask for Documents I can access, I get
       | ICT Status Report |
       | ICT Budget Report |
       | Cafeteria Menu    |

  Scenario: Rob can see Tim's document
    When I am "Rob Pike"
    Then I can read the Documents "ICT Status Report, Tim's Web Project" being a reader
     But I can not write the Document "Tim's Web Project" being a reader
    When I ask for Documents I can access, I get
       | ICT Status Report |
       | Tim's Web Project |
       | Cafeteria Menu    |

  Scenario: Tim can work on his project
    When I am "Tim Berners-Lee"
    Then I can not read the Document "ICT Status Report, ICT Budget Report"
     And I can read the Document "Tim's Web Project" being a writer
     And I can write the Document "Tim's Web Project" being a writer
    When I ask for Documents I can access, I get
       | Tim's Web Project |
       | Cafeteria Menu    |

  Scenario: Bill is maintaining the Cafeteria Menu
    When I am "William Gates"
    Then I can not read the Documents "ICT Status Report, ICT Budget Report, Tim's Web Project"
     But I can write the Document "Cafeteria Menu" being a writer
    When I ask for Documents I can access, I get
       | Cafeteria Menu    |

  Scenario: Steve can just read the menu
    When I am "Steve Jobs"
    Then I can not read the Documents "ICT Status Report, ICT Budget Report, Tim's Web Project"
     And I can not write the Document "Cafeteria Menu" being a reader
     But I can read the Document "Cafeteria Menu" being a reader
    When I ask for Documents I can access, I get
       | Cafeteria Menu    |

  Scenario: Resolving a specific user
    When I parse the Designator "user:4"
    Then it should describe itself as "User 'Steve Jobs'"
     And it should resolve itself to
       | Steve Jobs |

  Scenario: Resolving the ICT Director
    When I make a Designator with "position" and "1"
    Then it should describe itself as "Director in ICT"
    And it should resolve itself to
      | Dennis Ritchie |

  Scenario: Resolving the ICT Department
    When I parse the Designator "department:ICT"
    Then it should describe itself as "ICT"
    And it should resolve itself to
      | Dennis Ritchie |
      | Rob Pike       |

  Scenario: Resolving all authenticated users
    When I make a Designator with "authenticated" and "Eaco::Cucumber::ActiveRecord::User"
    Then it should describe itself as "Any authenticated user"
     And it should resolve itself to
       | Dennis Ritchie  |
       | Rob Pike        |
       | William Gates   |
       | Steve Jobs      |
       | Tim Berners-Lee |

  Scenario: Resolving an invalid designator
    When I parse the invalid Designator "foo:on the rocks"
    Then I should receive a Designator error Eaco::Error saying
    """
    Designator not found: "foo"
    """
