module Disbatch::Plugin::Hello

	def execute(task)
		return nil unless defined?(task) && task.respond_to?(:params)

		name = task.params['name']
		len  = rand(5)

		task.log("Hello, #{name}!")
		sleep(len)
		task.log("Goodbye, #{name}. It was a pleasure spending #{len} seconds with you.")

		puts("Executed task with params: #{task.params.inspect}")

		task.conclude
	end

	def params
		return [
			{
				'name' => 'name',
				'type' => 'string',
				'default' => 'world',
				'description' => 'some person or thing to greet'
			}
		]
	end

	extend self

	Disbatch::Plugin.register(self)

end
