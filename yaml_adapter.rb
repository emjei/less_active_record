require_relative 'yaml_object_mapper'

class YAMLAdapter
  attr_reader :file_name

  def initialize(storage_name)
    @file_name = "#{ storage_name }.yml"
    @_mapper = YAMLObjectMapper.new(file_name)
  end

  def update(id, attributes)
    item = search(id: id).first
    if item.nil?
      false
    else
      attributes.delete(:id)
      index = _items.index(item)
      _items[index].update(attributes)

      true
    end
  end

  def insert(attributes)
    calculate_id.tap do |id|
      _items << attributes.merge(id: id)
      dump_all_items!
    end
  end

  def destroy(id)
    item = search(id: id).first
    unless item.nil?
      _items.delete(item)
      dump_all_items!

      item
    end
  end

  def search(attributes = {})
    _items.map(&:clone).reject do |item|
      attributes.keys.any? { |key| attributes[key] != item[key] }
    end
  end

  private

  attr_reader :_mapper

  def _items
    @_items ||= load_all_items || []
  end

  def load_all_items
    _mapper.load_file
  end

  def calculate_id
    (_items.map { |item| item[:id] }.max || 0) + 1
  end

  def dump_all_items!
    _mapper.dump_file(_items)
  end
end
