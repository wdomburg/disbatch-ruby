module Disbatch::Plugins

	@plugins = {}

	# Register a class as a plugin
	def register(plugin)
		name = plugin.to_s

		return false unless plugin.responds_to?(execute)

		@plugins[name] = plugin
		puts "Registered #{name}"
	end

	# Return a plugin by name
	def [](name)
		@plugins[name]
	end

	# Attempt to load a plugin file
	def load(file)
		begin
			load file
			puts "Loaded #{file}"
		rescue
			puts "Error loading #{file}"
		end
	end

	# Attempt to load all plugin files in a directory
	def load_all(path)
		Dir(path).each { |file| load(file) }
	end

	extend self

end
