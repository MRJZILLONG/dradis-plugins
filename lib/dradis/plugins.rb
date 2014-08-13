require 'dradis/plugins/engine'
require 'dradis/plugins/version'

require 'dradis/plugins/content_service'
require 'dradis/plugins/template_service'

require 'dradis/plugins/export'
require 'dradis/plugins/import'
require 'dradis/plugins/upload'

module Dradis
  module Plugins
    module Base
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          # mattr_accessor :plugin_name

          @features = []
          @name = 'Use plugin_info(args) with :name to provide a name for this plugin.'
          Plugins::register(self)
        end
      end

      module ClassMethods
        def description(new_description)
          @description = new_description
        end

        def plugin_description
          @description ||= "This plugin doesn't provide a :description"
        end

        def plugin_name
          self.name.split('::')[2].underscore.to_sym
        end

        def provides(*list)
          @features = list
        end

        def provides?(feature)
          @features.include?(feature)
        end
      end
    end

    class << self
      @@extensions = []

      # Returns an array of modules representing currently registered Dradis Plugins / engines
      #
      # Example:
      #   Dradis::Core::Plugins.list  =>  [Dradis::Core, Dradis::Frontend]
      def list
        @@extensions
      end

      # Filters the list of plugins and only returns those that provide the
      # requested feature.
      def with_feature(feature)
        @@extensions.select do |plugin|
          # engine = "#{plugin}::Engine".constantize
          plugin.provides?(feature)
        end
      end

      # Register a plugin with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.register(Dradis::Core)
      def register(const)
        return if registered?(const)

        validate_plugin!(const)

        @@extensions << const
      end

      # Unregister a plugin from the framework
      #
      # Example:
      #   Dradis::Core::Plugins.unregister(Dradis::Core)
      def unregister(const)
        @@extensions.delete(const)
      end

      # Returns true if a plugin is currently registered with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.registered?(Dradis::Core)
      def registered?(const)
        @@extensions.include?(const)
      end

      private

      # Use this to ensure the Extension conforms with some expected interface
      def validate_plugin!(const)
        # unless const.respond_to?(:root) && const.root.is_a?(Pathname)
        #   raise InvalidEngineError, "Engine must define a root accessor that returns a pathname to its root"
        # end
      end
    end
  end
end