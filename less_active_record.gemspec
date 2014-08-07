Gem::Specification.new do |s|
  s.name        = 'less_active_record'
  s.version     = '0.1.1'
  s.date        = '2014-07-31'
  s.summary     = 'Simplified active record implementation.'
  s.license     = 'AFL-3.0'
  s.homepage    = 'https://github.com/emjei/less_active_record'

  s.description = <<-EOF
    A simple active record mock working with text file (right now YAML)
    databases. It is in no way meant to be used in production code. This
    is just for active record basics learning purposes.
  EOF

  s.author      = 'Marius Jašinskas'
  s.email       = 'marius.jasinskas@necolt.com'
  s.files       = %w(lib/less_active_record.rb
                     lib/less_active_record/yaml_adapter.rb
                     lib/less_active_record/record_finders.rb
                     lib/less_active_record/yaml_object_mapper.rb)

  # Tests
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'
end
