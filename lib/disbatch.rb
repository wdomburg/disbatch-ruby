module Disbatch

	# engine version
	VERSION = 'rdisbatch 0.0.9'
	# specification version
	SPEC_VERSION   = '1.9'

	attr_accessor :mongo_host
	attr_accessor :mongo_port
	attr_accessor :mongo_db
	attr_accessor :mongo_opts

	attr_accessor :node_id

	require 'bson'
	require 'json'
	require 'mongo'
	require 'socket'

	require 'disbatch/error'
	require 'disbatch/node'
	require 'disbatch/queue'
	require 'disbatch/plugin'
	
	@node_id = Socket.gethostname
	@mongo_host = 'localhost'
	@mongo_port = 27017
	@mongo_db   = 'disbatch'
	@mongo_opts = { :pool_size => 50, :safe => 1 }

	# Return and cache the MongoDB connection pool
	def db
		begin
			@db ||= Mongo::Connection.new(@mongo_host, @mongo_port).db(@mongo_db)
		rescue
			raise Disbatch::NoDatabaseError
		end

		@db
	end

	# Return and cache the local node object
	def node
		begin
			@node ||= Disbatch::Node.get(@node_id)
		rescue Disbatch::NoNodeError
			Disbatch::Node.create(@node_id)
		end
	end

	extend self

end

module Mongo

	# Wrap a MongoDB operation for retry
	# 
	# @param [Integer] max_retries maximum number of times to attempt to connect
	# @param [Float] interval frequency of retry attempts
	def self.try(max_retries=4,interval=0.5)
		retries = 0
		begin
			yield
		rescue Mongo::ConnectionFailure => ex
			retries +=1
			raise ex if retries > max_retries
			sleep(interval)
			retry
		end
	end

end
