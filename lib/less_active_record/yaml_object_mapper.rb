class YAMLObjectMapper
  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def load_file
    YAML.load_file(file_name) if File.exists?(file_name)
  end

  def dump_file(object)
    File.open(file_name, 'w') do |file|
      YAML.dump(object, file)
    end
  end
end
