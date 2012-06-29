module Disbatch

	# Raised when attempting to open an invalid node
	class NoNodeError < RuntimeError; end

	# Raised when attempting to open an owned node
	class RegisteredNodeError < RuntimeError; end

	# Raised when attempting to open a node twice
	class AlreadyRegisteredNodeError < RuntimeError; end

	# Raised when attempting to release an unregistered node
	class NotRegisteredNodeError < RuntimeError; end

	# Raised when specifying a non-existant plugin
	class NoPluginError < RuntimeError; end

	# Raised when failing to load a plugin
	class FailedLoadPluginError < RuntimeError; end

	# Raised when specifying a non-existant plugin
	class NoQueueError < RuntimeError; end

	# Raised on failure to connect or open mongo
	class NoDatabaseError < RuntimeError; end

end

