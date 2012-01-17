# Represesents a Disbatch node
class Disbatch::Node

	attr_accessor :id

	private_class_method :new

	# Create a node object
	#
	# @param [String] id 
	def initialize(id)
		@registered = false
		@id   = id
	end

	# Get an existing node
	#
	# @param [String] id
	def self.get(id = Disbatch.node_id)
		Mongo.try do
			raise Disbatch::NoNodeError unless Disbatch.db[:nodes].find_one({:_id => id})
			new(id)
		end
	end

	# Get all existing nodes
	def self.get_all
		Mongo.try do
			Disbatch.db[:nodes].find.map { |doc| new(doc['_id']) }
		end
	end

	# Create a new node
	#
	# @param [String] id
	def self.create(id = Disbatch.node_id)
		Mongo.try do
			Disbatch.db[:nodes].insert({
				:_id => id,
				:ctime => Time.now
			})
		end

		new(id)
	end

	# Register node
	def register(force = false)
		raise Disbatch::AlreadyRegisteredNodeError if @registered

		begin
			doc = Mongo.try do
				Disbatch.db[:nodes].find_and_modify({
					:query  => force ? { :_id => @id } : { :_id => @id, :pid => nil },
					:update => { :$set => {
						:pid          => Process.pid,
						:version      => Disbatch::VERSION,
						:spec_version => Disbatch::SPEC_VERSION
					} }
				})
			end
		rescue
			doc = Mongo.try do
				Disbatch.db[:nodes].find({ :_id => @id })
			end

			if doc.count == 0
				raise Disbatch::NoNodeError
			else
				raise Disbatch::RegisteredNodeError
			end
		end

		@registered = true
		self
	end

	# Release ownership of node
	def release
		raise Disbatch::NotRegisteredNodeError unless @registered

		doc = Mongo.try do
			Disbatch.db[:nodes].find_and_modify({
				:query  => { :_id => @id, :pid => Process.pid },
				:update => { :$set => {
					:pid   => nil,
					:mtime => Time.now,
					:atime => Time.now
				} }
			})
		end

		if doc.nil? 
			false
		else
			@registered = false
			true
		end
	end

	# Check if process is registered as this node.
	def registered?
		@registered
	end

	# Check equality with another node object
	#
	# @param [Disbatch::Node] node another node to compare against
	def ==(node)
		@id == node.id
	end

	# Deprecated.
	alias :open? :registered?

end
