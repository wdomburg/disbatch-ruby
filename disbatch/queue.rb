# Represents a Disbatch queue
class Disbatch::Queue

	require 'disbatch/queue/task'

	attr_reader :plugin, :id

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
			Disbatch.db[:queues].find_one({:_id => @id})
		end

		unless doc.nil?
			self.new(doc[:plugin], @id)
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
		
		# Throw exception if plugin doesn't exist?
		
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
			self.new(plugin, id)
		end

	end

	def created
		Disbatch.db[:tasks].find({tid=> @id, :status=> -2}).count
	end

	# Push a new task onto the queue
	def push(parameters)
		Disbatch::Queue::Task.create(self, parameters)
	end
		
	# Pop a task off the queue
	def pop
		Disbatch::Queue::Task.take(self)
	end

	# Check equality with another queue object
	#
	# @param[Disbatch::Queue] queue another queue to compare against
	def ==(queue)
		@id == queue.id
	end

end
