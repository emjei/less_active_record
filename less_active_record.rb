require 'yaml'

class LessActiveRecord
  attr_reader :id

  class << self
    def load
      if File.exists?(file_name)
        @items = YAML.load_file(file_name)
      else
        @items = []
      end
    end

    def dump
      File.open(file_name, 'w') do |file|
         YAML.dump(@items, file)
      end
    end

    def create(attributes = {})
      new(attributes).tap { |item| item.save }
    end

    def create!(attributes = {})
      new(attributes).tap { |item| item.save! }
    end

    def find(id)
      item = @items.detect { |item| item.id == id }
      item.nil? ? (raise 'Record not found!!!') : item.copy
    end

    def all
      @items.map { |item| item.copy }
    end

    private

    def file_name
      "#{ self.to_s.downcase }_table.yml"
    end
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  def save
    if valid?
      items = self.class.instance_variable_get(:@items)
      if @id.nil?
        @id = (items.map(&:id).max || 0) + 1
        items << copy
      else
        item = items.detect { |item| item.id == id }
        item.attributes = attributes
      end

      true
    else
      false
    end
  end

  def save!
    save ? true : (raise 'Not valid!!!!')
  end

  def update(attributes = {})
    self.attributes = attributes
    save
  end

  def update!(attributes = {})
    self.attributes = attributes
    save!
  end

  def destroy
    items = self.class.instance_variable_get(:@items)
    items.delete_if { |item| item.id == @id }
    true
  end

  def attributes
    attribute_names.each_with_object({}) do |name, attributes|
      attributes[name] = send(name)
    end
  end

  def attributes=(attributes)
    self.attributes.each do |k, _|
      send("#{ k }=", attributes[k]) unless attributes[k].nil?
    end
  end

  def copy
    self.class.new(attributes).tap do |copy|
      copy.instance_variable_set(:@id, id)
    end
  end
end
