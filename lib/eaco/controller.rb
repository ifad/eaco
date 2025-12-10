begin
  require 'active_support/concern'
rescue LoadError
  # :nocov: This is falsely true during specs ran by Guard. FIXME.
  abort 'Eaco::Controller requires actioncontroller. Please add it to Gemfile.'
  # :nocov:
end

module Eaco

  ##
  # An ActionController extension to verify authorization in Rails applications.
  #
  # Tested on Rails 3.2 and up on Ruby 2.0 and up.
  #
  module Controller
    extend ActiveSupport::Concern

    ##
    # Controller authorization DSL.
    #
    module ClassMethods

      ##
      # Defines the ability required to access a given controller action.
      #
      # Example:
      #
      #   class DocumentsController < ApplicationController
      #     authorize :index,           [:folder, :index]
      #     authorize :show,            [:folder, :read]
      #     authorize :create, :update, [:folder, :write]
      #   end
      #
      # Here +@folder+ is expected to be an authorized +Resource+, and for the
      # +index+ action the +current_user+ is checked to +can?(:index, @folder)+
      # while for +show+, +can?(:read, @folder)+ and for +create+ and +update+
      # checks that it +can?(:write, @folder)+.
      #
      # The special +:all+ action name requires the given ability on the given
      # Resource for all actions.
      #
      # If an action has no authorization defined, access is granted.
      #
      # Adds {Controller#confront_eaco} as a +before_filter+.
      #
      # @param actions [Variadic] see above.
      #
      # @return void
      #
      def authorize(*actions)
        target = actions.pop

        actions.each {|action| authorization_permissions.update(action => target)}

        @_eaco_filter_installed ||= begin
          if ActionPack::VERSION::MAJOR >= 5
            before_action :confront_eaco
          else
            before_filter :confront_eaco
          end

          true
        end
      end

      ##
      # Gets the permission required to access the given +action+, falling
      # back on the default +:all+ action, or +nil+ if no permission is
      # defined.
      #
      # @return [Symbol] the required permission or nil
      #
      # @see Eaco::Resource
      # @see Eaco::DSL::Resource
      #
      def permission_for(action)
        authorization_permissions[action] || authorization_permissions[:all]
      end

      protected
        ##
        # Permission requirements configured on this controller, keyed by
        # permission symbol and with role symbols as values.
        #
        # @return [Hash]
        #
        # @see Eaco::DSL::Resource
        #
        def authorization_permissions
          @_authorization_permissions ||= {}
        end
    end

    protected

    ##
    # Asks Eaco whether thou shalt pass or not.
    #
    # The implementation is left in this method's body, despite a bit long for
    # many's taste, as it is pretty imperative and simple code. Moreover, the
    # less we pollute ActionController's namespace, the better.
    #
    # @return [void]
    #
    # @raise [Error] if the instance variable configured in {.authorize} is not found
    # @raise [Forbidden] if the +current_user+ is not granted access.
    #
    #
    # == La Guardiana
    #                                            /\
    #                           .-_-.           /  \
    #                  ||   .-.(    .' .-.   // \  /
    #                   \\\/ (((\   /)))  \ / // )(
    #                    ) '._  ,-.   ___. )/ //(__)
    #                    \_((( (  :)  \)))/ ,  / ||
    #                     \_  \ '-' /_   /| ),// ||
    #                       \ (_._.'_ \ (o__//  _||_
    #                        \ )\  .(/ /  __)   \   \
    #                        ( \ '_  .'  /(      |-. \
    #                         \_'._'.\__/))))    (__)'.'.
    #                        _._   |  |    _.-._ ||   \ '.
    #                       / //--'  / '--//'-'/\||____\  '.
    #                       \---.\ .----.//  //  ||//  '\   \
    #                      /   ' \/    ' \\__\\ ,||\\_______.'
    #                      \\___//\\____//\____\ ||
    #           _.-'''---. /\___/  \____/  \\/   ||
    #        ..'_.''''---.|   /.  \        /     ||
    #      .'.-'O    __  /  _/  )_.--.____(      ||
    #     / / /  \__/  /'  /\ \(__.--._____)     ||
    #     | |    /\ \  \_.' | |   \      |       ||
    #     \  '.__\,_.'.__/./ /     ) .   |\      ||
    #      '..__ O --' ___..'     /\     /|'.    ||
    #           ''----'           | \/\.' / /'.  ||
    #                             |\(()).' /   \ ||
    #                           _/ \ \/   /     \||
    #                   __..--''    '.   |      |||
    #               .-''            / '._|/     |||
    #              /                __.- /      /||
    #              \   ____..-----''    /      | ||
    #               '.     )).         |       / ||
    #                 ''._//  \        .-----./  ||
    #                     '.   \      (.-----.)  ||
    #                       '.  \      |    /    ||
    #                         )_ \     |   |     ||
    #                        /__'O\    ( ) (     ||
    #          _______mrf,-'____/|/__   |\  \    ||
    #                                   |    |   ||
    #                                   |____)  (__)
    #                                   '-----'  ||
    #                                    \   |   ||
    #                                     \  |   ||
    #                                      \ |   ||
    #                                       | \  ||
    #                                       |_ \ ||
    #                                       /_'O\||
    #                                    .-'___/(__)
    #
    #                                    https://ascii.co.uk/art/guardiana
    #
    def confront_eaco
      action = params[:action].intern
      resource_ivar, permission = self.class.permission_for(action)

      if resource_ivar && permission
        resource = instance_variable_get(['@', resource_ivar].join.intern)

        if resource.nil?
          raise Error, <<-EOF
            @#{resource_ivar} is not set, can't authorize #{self}##{action}
          EOF
        end

        unless current_user.can? permission, resource
          raise Forbidden, <<-EOF
            `#{current_user}' not authorized to `#{action}' on `#{resource}'
          EOF
        end
      end
    end
  end

end
