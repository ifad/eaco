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
      # Set up the World:
      #
      # * Connect to ActiveRecord
      #
      def initialize
        Eaco::Cucumber::ActiveRecord.connect!
      end

      ##
      # @return [Class] a model in the {ActiveRecord} namespace.
      #
      def find_model(model_name)
        Eaco::Cucumber::ActiveRecord.const_get(model_name)
      end
    end

  end
end
