module Disbatch::Plugin


	attr_reader :plugins

	@plugins = {}

	# Register a class as a plugin
	def register(plugin)
		name = plugin.to_s

		return false unless plugin.respond_to?(:execute)

		@plugins[name] = plugin
		puts "Registered #{name}"
	end

	# Return a plugin by name
	def [](name)
		@plugins[name]
	end

	# Attempt to load a plugin file
	def init(file)
		begin
			load file
			puts "Loaded #{file}"
		rescue
			puts "Error loading #{file}"
		end
	end

	# Attempt to load all plugin files in a directory
	def init_all(path)
		Dir[path].each { |file| init(file) }
	end

	extend self

end
