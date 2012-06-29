module Disbatch::Plugin

	attr_reader :plugins

	@plugins = {}

	# Register a class as a plugin
	def register(plugin)
		name = plugin.to_s

		raise Disbatch::InvalidPluginError unless plugin.respond_to?(:execute)

		@plugins[name] = plugin
		puts "Registered #{name}"
	end

	# Return a plugin by name
	def [](name)
		raise Disbatch::NoPluginError unless @plugins.has_key?(name)
		@plugins[name]
	end

	# Check for existance of plugin
	def exists?(name)
		@plugins.has_key?(name)
	end

	# Attempt to load a plugin file
	def init(file)
		begin
			load file
		rescue => e
			raise Disbatch::FailedLoadPluginError, file
		end
	end

	# Attempt to load all plugin files matched by a glob
	def init_all(glob)
		Dir[glob].each { |file| init(file) }
	end

	extend self

	init_all('disbatch/plugin/**/*')

end
