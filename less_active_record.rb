require_relative 'yaml_adapter'

class LessActiveRecord
  # TODO: test
  attr_reader :id

  class << self
    # TODO: test
    def create(attributes = {})
      new(attributes).tap(&:save)
    end

    # def all
    #   items.map(&:clone)
    # end

    # def find(id)
    #   item = items.detect { |item| item.id == id }
    #   item.nil? ? (raise 'Record not found!') : item.clone
    # end

    # def where(attributes)
    #   raise NotImplementedError
    # end

    def storage_name
      "#{ self.to_s }Table"
    end

    def attribute(name)
      symbolized_name = name.to_sym
      unless attribute_names.include? symbolized_name
        attr_accessor symbolized_name
        self.attribute_names <<= symbolized_name
      end

      self
    end

    def attribute_names
      (@attribute_names ||= []).clone
    end

    def validate(method_name)
      symbolized_name = method_name.to_sym
      unless validations.include? symbolized_name
        self.validations <<= symbolized_name
      end

      self
    end

    def validations
      (@validations ||= []).clone
    end

    protected

    attr_writer :attribute_names
    attr_writer :validations

    def _adapter
      @_adapter ||= YAMLAdapter.new(storage_name)
    end
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  # TODO: test
  def save
    return false unless valid?

    if new_record?
      @id = _adapter.create(attributes)

      true
    else
      _adapter.update(id, attributes)
    end
  end

  # TODO: test
  def update(attributes = {})
    self.attributes = attributes
    save
  end

  # def destroy
  #   items = self.class.instance_variable_get(:@items)
  #   items.delete_if { |item| item.id == id }
  #   true
  # end

  def attributes
    self.class.attribute_names.each_with_object({}) do |name, attributes|
      attributes[name] = send(name)
    end
  end

  def attributes=(attributes)
    self.class.attribute_names.each do |name|
      send("#{ name }=", attributes[name]) if attributes.key?(name)
    end
  end

  def valid?
    self.class.validations.each do |validation|
      return false unless send(validation)
    end

    true
  rescue
    false
  end

  # TODO: test
  def persisted?
    not new_record?
  end

  # TODO: test
  def new_record?
    id.blank?
  end

  # TODO: test
  def clone
    self.class.new(attributes).tap { |clone| clone.id = id }
  end

  protected

  attr_writer :id
end
