# Represents a Disbatch task
class Disbatch::Queue::Task

	require 'pp'

	attr_reader :queue, :parameters, :id

	private_class_method :new

	# Create a task object
	#
	# @param [Disbatch::Queue] queue
	# @param [Hash] parameters
	# @param [String] id
	def initialize(queue, parameters, id)
		@queue  = queue
		@parameters = parameters
		@id     = id
	end

	# Take a task
	#
	# @param [Disbatch::Queue] queue
	def self.take(queue)
		doc = Mongo.try do
			Disbatch.db[:tasks].find_and_modify({
				:query => { :queue => queue.id, :status => -2 },
				:update => { :$set => { :node => Disbatch.node.id, :status => -1, } }
			})
		end

		unless doc.nil?
			new(queue, doc['parameters'], doc['_id'])
		end
	end

	# Create a new task
	#
	# @param [Disbatch::Queue queue
	# @param [Hash] parameters
	def self.create(queue, parameters)
		id = Mongo.try do
			Disbatch.db[:tasks].insert({
			:queue => queue.id,
			:parameters => parameters,
			:ctime => Time.now,
			:mtime => Time.now,
			:node => -1,
			:status => -2,
			:stdout => '',
			:stderr => '',
			:log => []
			})
		end

		unless id.nil?
			new(queue, parameters, id)
		end
	end

	# Log a message 
	#
	# @param [String] message
	def log(message)
		Disbatch.db[:tasks].update({:_id => @id}, {'$push' => {'log'=>message} })
	end

	# Query a task attribute
	#
	# @param [String] attribute
	def query(attribute)
		doc = Mongo.try { Disbatch.db[:tasks].find_one({:_id => @id}, { :fields => { attribute => 1 } }) }
		doc.nil? ? nil : doc[attribute]
	end

	# Update a task attribute
	#
	# @param [Symbol] attribute
	# @param [Object] value
	def update(attribute, value)
		Disbatch.db[:tasks].update({:_id => @id}, {:$set => { attribute => value } })
	end

	# Query task status
	def status
		query('status')
	end

	# Set task status
	#
	# @param [Integer] status
	def status=(status)
		update(:status,status)
	end

	# Query stdout
	def stdout 
		query('stdout')
	end

	# Set stdout
	#
	# @param [String] message
	def stdout=(message)
		update(:stdout,message)
	end

	# Query stderr
	def stderr 
		query('stderr')
	end

	# Set stdout
	#
	# @param [String] message
	def stderr=(message)
		update(:stdout,message)
	end

	# Fail task
	def fail
		self.status=-3
	end

	# Release task
	def release
		self.status=-2
	end

	# Conclude task
	def conclude
		self.status=1
	end

	# Execute the task
	def execute!
		Disbatch::Plugin[queue.plugin].execute(self)
	end

	alias :params :parameters

end
