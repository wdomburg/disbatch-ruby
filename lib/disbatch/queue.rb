# Represents a Disbatch queue
class Disbatch::Queue

	require 'disbatch/task'

	attr_reader :plugin, :id

	private_class_method :new

	# Create a queue object 
	# 
	# @param [String] plugin
	# @param [String] id
	def initialize(plugin, id)
		@id = id
		@plugin = plugin
	end

	# Get an existing queue
	#
	# @param [String] id
	def self.get(id)
		doc = Mongo.try do
			Disbatch.db[:queues].find_one({:_id => id})
		end

		raise Disbatch::NoQueueError if doc.nil?
	end

	# Get all existing queues
	def self.get_all
		Mongo.try do
			Disbatch.db[:queues].find.map { |doc| new(doc['class'], doc['_id']) } 
		end
	end

	# Create a new queue
	#
	# @param [String] plugin
	# @param [Hash] opts
	# @option opts [String] id
	# @option opts [Integer] maxthreads
	# @option opts [String] description
	# @option opts [Array] nodes_pin
	# @option opts [Array] nodes_ignore
	def self.create(plugin, opts={})
		raise Disbatch::NoPluginError unless Disbatch::Plugin[plugin]
		
		id           = opts[:id]           || BSON::ObjectId.new.to_s
		maxthreads   = opts[:maxthreads]   || 10
		description  = opts[:description]  || ''
		nodes_pin    = opts[:nodes_pin]    || []
		nodes_ignore = opts[:nodes_ignore] || []
	
		doc = Mongo.try do
			Disbatch.db[:queues].insert({
				:_id             => id,
				:class           => plugin,
				:maxthreads      => maxthreads,
				:description     => description,
				:nodes_pin       => nodes_pin,
				:nodes_ignore    => nodes_ignore,
				:ctime           => Time.now
			})
		end

		unless doc.nil?
			new(plugin, id)
		end
	end

	# Number of pending tasks
	def length
		Disbatch.db[:tasks].find({:queue => @id, :status=> -2}).count
	end

	# Push a new task onto the queue
	def push(parameters)
		Disbatch::Task.create(self, parameters)
		self
	end
		
	# Pop a task off the queue
	def pop
		Disbatch::Task.take(self)
	end

	def nodes_pin
		doc = Disbatch.db[:queues].find_one({:_id => self.id}, {:fields=> [ :nodes_pin ] })

		return doc['nodes_pin'] || []
	end

	def nodes_ignore
		doc = Disbatch.db[:queues].find_one({:_id => self.id}, {:fields=> [ :nodes_ignore ] })

		return doc['nodes_ignore'] || []
	end

	# Check equality with another queue object
	#
	# @param[Disbatch::Queue] queue another queue to compare against
	def ==(queue)
		@id == queue.id
	end

	alias :size :length

end
