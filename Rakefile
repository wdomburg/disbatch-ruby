require 'rake/gempackagetask'
require 'rake/testtask'
require 'yard'

spec = Gem::Specification.new do |s| 
	s.name = "disbatch"
	s.version = "0.0.6"
	s.author = "Matthew Berg"
	s.email = "mberg@synacor.com"
	s.homepage = "http://disbatch.org/projects/disbatch-ruby"
	s.platform = Gem::Platform::RUBY
	s.summary = "Distributed batch processing package"
	s.description = <<-EOF
		Disbatch is a distributed, multi-language batch processing
		platform.	This package provides both a client library and
		execution node implementation.
	EOF
	s.files = FileList["{bin,lib,doc}/**/*"].to_a
	s.executables << "disbatchd"
	s.require_path = "lib"
	s.add_dependency("bson")
	s.add_dependency("json")
	s.add_dependency("mongo")
	s.add_dependency("trollop")
	s.add_dependency("eventmachine")
#	if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
#		s.add_dependency("jruby-openssl")
#	end
	#s.test_files = FileList["{test}/**/*test.rb"].to_a
	s.has_rdoc = true
	s.extra_rdoc_files = ["README", "LICENSE", "disbatch_specification.txt"]
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
	pkg.need_tar = true 
end 

YARD::Rake::YardocTask.new do |t|
	t.files   = FileList['lib/**/*.rb'].exclude('lib/disbatch/plugin/**/*.rb')
end

desc "Open an irb session preloaded with this library"
task :console do
	require 'irb'
	$LOAD_PATH << 'lib'

	require 'disbatch'

	Disbatch::Plugin.init_all('lib/disbatch/plugin/**/*.rb')

	IRB.setup(__FILE__)
	irb = IRB::Irb.new
	IRB.conf[:MAIN_CONTEXT] = irb.context

	trap('SIGINT') do
		irb.signal_handle
	end

	catch(:IRB_EXIT) do
		irb.eval_input
	end
end
