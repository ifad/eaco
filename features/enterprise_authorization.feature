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

        role :reader, "R/O"
        role :writer, "R/W"

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

  Scenario: Granting access in batches
    When I have a confidential Document named "For BAR and ICT"
     And I grant access to Document "For BAR and ICT" to the following designators as reader
       | department:BAR |
       | department:ICT |
    When I am "Dennis Ritchie"
    Then I can read the Document "For BAR and ICT" being a reader
     But I can not write the Document "For BAR and ICT" being a reader
    When I am "Rob Pike"
    Then I can read the Document "For BAR and ICT" being a reader
     But I can not write the Document "For BAR and ICT" being a reader
    When I am "William Gates"
    Then I can read the Document "For BAR and ICT" being a reader
     But I can not write the Document "For BAR and ICT" being a reader
    When I am "Steve Jobs"
    Then I can not read the Document "For BAR and ICT"
     And I can not write the Document "For BAR and ICT"


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
     And it should have a label of "User"
     And it should serialize to JSON as {"label": "User 'Steve Jobs'", "value": "user:4"}
     And it should resolve itself to
       | Steve Jobs |

  Scenario: Resolving the ICT Director
    When I make a Designator with "position" and "1"
    Then it should describe itself as "Director in ICT"
     And it should have a label of "Position"
     And it should serialize to JSON as {"label": "Director in ICT", "value": "position:1"}
     And it should resolve itself to
      | Dennis Ritchie |

  Scenario: Resolving the ICT Department
    When I parse the Designator "department:ICT"
    Then it should describe itself as "ICT"
     And it should have a label of "Department"
     And it should serialize to JSON as {"label": "ICT", "value": "department:ICT"}
     And it should resolve itself to
      | Dennis Ritchie |
      | Rob Pike       |

  Scenario: Resolving all authenticated users
    When I make a Designator with "authenticated" and "Eaco::Cucumber::ActiveRecord::User"
    Then it should describe itself as "Any authenticated user"
     And it should have a label of "Any user"
     And it should serialize to JSON as {"label": "Any authenticated user", "value": "authenticated:Eaco::Cucumber::ActiveRecord::User"}
     And it should resolve itself to
       | Dennis Ritchie  |
       | Rob Pike        |
       | William Gates   |
       | Steve Jobs      |
       | Tim Berners-Lee |

  Scenario: Resolving different designators
    When I have the following designators
      | department:ICT |
      | position:3     |
      | user:1         |
    Then they should resolve to
      | Dennis Ritchie  |
      | Rob Pike        |
      | William Gates   |

  Scenario: Resolving an invalid designator
    When I parse the invalid Designator "foo:on the rocks"
    Then I should receive a Designator error Eaco::Error saying
    """
    Designator not found: "foo"
    """

  Scenario: Obtaining the role of a valid designator
    When I parse the Designator "department:ICT"
    Then its role on the Document "ICT Status Report" should be reader
     And its role on the Documents "Cafeteria Menu, ICT Budget Report, Tim's Web Project" should be nil
    When I make a Designator with "position" and "1"
    Then its role on the Documents "ICT Status Report, ICT Budget Report" should be writer
     And its role on the Documents "Cafeteria Menu, Tim's Web Project" should be nil

  Scenario: Obtaining the role of an invalid object
    When I have a plain object as a Designator
    Then its role on the Document "ICT Status Report" should give an Eaco::Error error saying
    """
    roles_of expects .+Object.+ to be a Designator or to .+respond_to.+:designators
    """

  Scenario: Obtaining labels for roles
    When I ask the Document the list of roles and labels
    Then I should get the following roles and labels
      | writer | R/W   |
      | reader | R/O   |

  Scenario: Authorizing a controller
    When I have an authorized Controller defined as
    """
      if ActionPack::VERSION::MAJOR >= 5
        before_action :find_document
      else
        before_filter :find_document
      end

      authorize :show, [:document, :read ]
      authorize :edit, [:document, :write]

      def show
        head :ok
      end

      def edit
        head :ok
      end

      private

      def find_document
        @document = Eaco::Cucumber::ActiveRecord::Document.where(name: params[:name]).first
      end
    """
    When I am "Dennis Ritchie"
     And I invoke the Controller "show" action with query string "name=ICT Status Report"
    Then the Controller should not raise an error
     And I invoke the Controller "edit" action with query string "name=ICT Status Report"
    Then the Controller should not raise an error

    When I am "Rob Pike"
     And I invoke the Controller "show" action with query string "name=ICT Status Report"
    Then the Controller should not raise an error
     And I invoke the Controller "edit" action with query string "name=ICT Status Report"
    Then the Controller should raise an Eaco::Forbidden error saying
    """
    User.+not authorized to `edit' on .+Document
    """

    When I am "William Gates"
     And I invoke the Controller "edit" action with query string "name=Cafeteria Menu"
    Then the Controller should not raise an error
     And I invoke the Controller "show" action with query string "name=ICT Status Report"
    Then the Controller should raise an Eaco::Forbidden error saying
    """
    User.+not authorized to `show' on .+Document
    """

    When I am "Steve Jobs"
     And I invoke the Controller "show" action with query string "name=One More Thing"
    Then the Controller should raise an Eaco::Error error saying
    """
    @document is not set, can't authorize .+show
    """
