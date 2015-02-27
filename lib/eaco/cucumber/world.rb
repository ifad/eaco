module Eaco
  module Cucumber

    ##
    # The world in which scenarios are run. This is a story and an example,
    # real-world data model that can be effectively protected by Eaco.
    #
    # But +before { some :art }+
    #
    # == AYANAMI REI
    #                                            __.-"..--,__
    #                                       __..---"  | _|    "-_\
    #                                __.---"          | V|::.-"-._D
    #                           _--"".-.._   ,,::::::'"\/""'-:-:/
    #                      _.-""::_:_:::::'-8b---"            "'
    #                   .-/  ::::<  |\::::::"\
    #                   \/:::/::::'\\ |:::b::\
    #                   /|::/:::/::::-::b:%b:\|
    #                    \/::::d:|8:::b:"%%%%%\
    #                    |\:b:dP:d.:::%%%%%"""-,
    #                     \:\.V-/ _\b%P_   /  .-._
    #                     '|T\   "%j d:::--\.(    "-.
    #                     ::d<   -" d%|:::do%P"-:.   "-,
    #                     |:I _    /%%%o::o8P    "\.    "\
    #                      \8b     d%%%%%%P""-._ _ \::.    \
    #                      \%%8  _./Y%%P/      .::'-oMMo    )
    #                        H"'|V  |  A:::...:odMMMMMM(  ./
    #                        H /_.--"JMMMMbo:d##########b/
    #                     .-'o      dMMMMMMMMMMMMMMP""
    #                   /" /       YMMMMMMMMM|
    #                 /   .   .    "MMMMMMMM/
    #                 :..::..:::..  MMMMMMM:|
    #                  \:/ \::::::::JMMMP":/
    #                   :Ao ':__.-'MMMP:::Y
    #                   dMM"./:::::::::-.Y
    #                  _|b::od8::/:YM::/
    #                  I HMMMP::/:/"Y/"
    #                   \'""'  '':|
    #                    |    -::::\
    #                    |  :-._ '::\
    #                    |,.|    \ _:"o
    #                    | d" /   " \_:\.
    #                    ".Y. \       \::\
    #                     \ \  \      MM\:Y
    #                      Y \  |     MM \:b
    #                      >\ Y      .MM  MM
    #                      .IY L_    MP'  MP
    #                      |  \:|   JM   JP
    #                      |  :\|   MP   MM
    #                      |  :::  JM'  JP|
    #                      |  ':' JP   JM |
    #                      L   : JP    MP |
    #                      0   | Y    JM  |
    #                      0   |     JP"  |
    #                      0   |    JP    |
    #                      m   |   JP     #
    #                      I   |  JM"     Y
    #                      l   |  MP     :"
    #                      |\  :-       :|
    #                      | | '.\      :|
    #                      | | "| \     :|
    #                       \    \ \    :|
    #                       |  |  | \   :|
    #                       |  |  |   \ :|
    #                       |   \ \    | '.
    #                       |    |:\   | :|
    #                       \    |::\..|  :\
    #                        ". /::::::'  :||
    #                          :|::/:::|  /:\
    #                          | \/::|: \' ::|
    #                          |  :::||    ::|
    #                          |   ::||    ::|
    #                          |   ::||    ::|
    #                          |   ::||    ::|
    #                          |   ': |    .:|
    #                          |    : |    :|
    #                          |    : |    :|
    #                          |    :||   .:|
    #                          |   ::\   .:|
    #                         |    :::  .::|
    #                        /     ::|  :::|
    #                     __/     .::|   ':|
    #            ...----""        ::/     ::
    #           /m_  AMm          '/     .:::
    #           ""MmmMMM#mmMMMMMMM"     .:::m
    #              """YMMM""""""P        ':mMI
    #                       _'           _MMMM
    #                   _.-"  mm   mMMMMMMMM"
    #                  /      MMMMMMM""
    #                  mmmmmmMMMM"
    #                                   ch1x0r
    #
    #         http://ascii.co.uk/art/anime
    #
    # = Scenario
    #
    # In this imaginary world we are  N E R V, a Top Secret organization that
    # handles very confidential documents. Some users can read them, some can
    # edit them, and very few bosses can destroy them.
    #
    # The organization employs internal staff and employs consultants.  Staff
    # members have official positions in the organization hierarchy, and they
    # belong to units within departments. They have the big picture.
    #
    # Consultants, on the other hand, come and go, and work on small parts of
    # the documents, for specific purposes. They do not have the big picture.
    #
    # Departments own the documents, not people. Documents are of interest of
    # departments, sometimes they should be accessed by the whole house, some
    # other time only few selected users, some times two specific departments
    # or some units.
    #
    # Either way, most of the time, access is granted to who owns a peculiar
    # authority within the organization and not to a specific person. People
    # may change, authorities and rules change less often.
    #
    # = Mapping Eaco concepts
    #
    # The +Document+ is a {Eaco::Resource}
    #
    # Each instance of a +Document+ has an {Eaco::ACL} +.acl+ attribute.
    #
    # The +:reader+, +:editor+ and +:owner+ are Roles on the Document
    # resource, and each role is granted a Permission.
    #
    # The User is a {Eaco::Actor}.
    #
    # Having an user account is the {Eaco::Designator} of type +:user+.
    # Occupying an official position is the Designator of type +:position+.
    # Belonging to a department is the Designator of type +:department+
    #
    class World

      ##
      # Sets up the World:
      #
      # * Connect to ActiveRecord
      #
      def initialize
        Eaco::Cucumber::ActiveRecord.connect!
      end

      ##
      # Authorizes model with the given {DSL}
      #
      # @param name [String] the model name
      # @param definition [String] the {DSL} code
      # @see {#find_model}
      #
      # @return [void]
      #
      def authorize_model(name, definition)
        model = find_model(name)

        eval_dsl definition, model
      end

      ##
      # Registers and persists an {Actor} instance with the given +name+.
      #
      # @param name [String] the {Actor} name
      # @param admin [Boolean] is this {Actor} an admin?
      #
      # @return [Actor] the newly created {Actor} instance.
      #
      def register_actor(model, name, admin = false)
        actor_model = find_model(model)

        actors[name] = actor_model.new.tap do |actor|
          actor.name  = name
          actor.admin = admin
          actor.save!
        end
      end

      ##
      # Fetches an {Actor} instance by name.
      #
      # @param name [String] the actor name
      # @return [Actor] the registered actor name
      # @raise [RuntimeError] if the actor is not found in the registry
      #
      def fetch_actor(name)
        actors.fetch(name)
      rescue KeyError
        raise "Actor '#{name}' not found in registry"
      end

      ##
      # Registers and persists {Resource} instance with the given name.
      #
      # @param model [String] the {Resource} model name
      # @param resource [String] the {Resource} name
      #
      # @return [Resource] the newly instantiated {Resource}
      #
      def register_resource(model, name)
        resource_model = find_model(model)

        resource = resource_model.new.tap do |resource|
          resource.name = name
          resource.save!
        end

        resources[model] ||= {}
        resources[model][name] = resource
      end

      ##
      # Fetches a {Resource} instance by name.
      #
      # @param model [String] the {Resource} model name
      # @param name [String] the {Resource} name
      #
      def fetch_resource(model, name)
        resources.fetch(model).fetch(name)
      rescue KeyError
        raise "Resource #{model} '#{resource}' not found in registry"
      end

      ##
      # All registered {Actor} instances.
      #
      # @return [Hash] actors keyed by name
      #
      def actors
        @actors ||= {}
      end

      ##
      # All registered {Resource} instances.
      #
      # @return [Hash] resources keyed by model name with +Hash+es
      #                as values keyed by resource name.
      #
      def resources
        @resources ||= {}
      end

      ##
      # Returns a model in the {ActiveRecord} namespace.
      #
      # Example:
      #
      #   World.find_model('Document')
      #
      # @param model_name [String] the model name
      # @return [Class]
      #
      def find_model(model_name)
        Eaco::Cucumber::ActiveRecord.const_get(model_name)
      end

      ##
      # Evaluates the given {Eaco::DSL} code, substituting the
      # +$MODEL+ string with the given model name.
      #
      # @param code [String] the DSL code to eval
      # @param model [Class] the model name to substitute
      #
      # @return [void]
      #
      def eval_dsl(code, model)
        # Sub in place to print final code when running cucumber
        code.sub! '$MODEL', model.name
        Eaco.eval! code, '(feature)'
      end
    end

  end
end
