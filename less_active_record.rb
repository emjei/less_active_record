require 'yaml'

class LessActiveRecord
  # attr_reader :id

  class << self
    # def create(attributes = {})
    #   new(attributes).tap(&:save)
    # end

    # def all
    #   items.map(&:copy)
    # end

    # def find(id)
    #   item = items.detect { |item| item.id == id }
    #   item.nil? ? (raise 'Record not found!') : item.copy
    # end

    # def where(attributes)
    #   raise NotImplementedError
    # end

    def file_name
      "#{ self.to_s.downcase }_table.yml"
    end

    def attribute(name)
      tap do
        symbolized_name = name.to_sym
        unless attribute_names.include? symbolized_name
          attr_accessor symbolized_name
          self.attribute_names <<= symbolized_name
        end
      end
    end

    def attribute_names
      (@attribute_names ||= []).clone
    end

    protected

    attr_writer :attribute_names

    # attr_writer :items

    # def items
    #   @items ||= self.load || []
    # end

    # def load
    #   YAML.load_file(file_name) if File.exists?(file_name)
    # end

    # def dump
    #   File.open(file_name, 'w') do |file|
    #     YAML.dump(items, file)
    #   end
    # end
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  # def save
  #   if valid?
  #     items = self.class.items
  #     if id.nil?
  #       id = (items.map(&:id).max || 0) + 1
  #       items << copy
  #     else
  #       item = items.detect { |item| item.id == id }
  #       item.attributes = attributes
  #     end

  #     self.class.dump
  #     true
  #   else
  #     false
  #   end
  # end

  # def update(attributes = {})
  #   self.attributes = attributes
  #   save
  # end

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

  # def persisted?
  #   raise NotImplementedError
  # end

  # def new_record?
  #   raise NotImplementedError
  # end

  # # TODO rename to clone
  # def copy
  #   self.class.new(attributes).tap { |copy| copy.id = id }
  # end

  # private

  # attr_writer :id
end
