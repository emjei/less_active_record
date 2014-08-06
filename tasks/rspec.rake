begin
  require 'rspec'
  require 'rspec/core/rake_task'

  desc 'Run all examples'
  RSpec::Core::RakeTask.new('spec') do |t|
    t.verbose = true
  end
rescue LoadError
  puts <<-EOF
    RSpec, or one of its dependencies, is not available.
    Install it with: sudo gem install rspec
  EOF
end
