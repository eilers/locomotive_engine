
Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', '*.rb')) do |f|
  require f
end

module Locomotive
  module Plugins

    extend Registration

    def self.init_plugins
      initialize! unless @initialized

      if block_given?
        _in_init_block do
          yield
        end
      end
    end

    def self.bundler_require
      init_plugins do
        Bundler.require(:locomotive_plugins)
      end
    end

    protected

    def self.initialize!
      # Set up plugin class tracker
      Locomotive::Plugin.add_plugin_class_tracker do |plugin_class|
        _added_plugin_class(plugin_class)
      end

      # Log a warning for all plugins loaded before initialization
      Locomotive::Plugin.plugin_classes.each do |plugin_class|
        log_load_warning(plugin_class)
      end

      @initialized = true
    end

    def self.in_init_block?
      !!@in_init_block
    end

    def self.log_load_warning(plugin_class)
      Locomotive::Logger.warn("Plugin #{plugin_class} was loaded outside " +
        "the init_plugins block. It will not registered")
    end

    def self.handle_added_plugin_class(plugin_class)
      register_plugin!(plugin_class)
    end

    def self._added_plugin_class(plugin_class)
      if in_init_block?
        handle_added_plugin_class(plugin_class)
      else
        log_load_warning(plugin_class)
      end
    end

    def self._in_init_block
      begin
        @in_init_block = true
        yield
      ensure
        @in_init_block = false
      end
    end

  end
end
