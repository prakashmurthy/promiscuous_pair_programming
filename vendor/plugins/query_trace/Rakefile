require 'rubygems'
require 'rake/gempackagetask'

GEM_NAME = "query_trace"
GEM_VERSION = "0.0.1"
AUTHOR = "Nathaniel Talbott"
EMAIL = "nathaniel@terralien.com"
HOMEPAGE = "http://github.com/ntalbott/query_trace/tree/master"
SUMMARY = "Adds query origin tracing to your logs."

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'query_trace'
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('activerecord')
  s.require_path = 'lib'
  s.files = %w(MIT-LICENSE README Rakefile) + Dir.glob("{lib}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end