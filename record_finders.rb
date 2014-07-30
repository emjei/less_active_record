module RecordFinders
  def all
    where({})
  end

  def find(id)
    if record = _adapter.search(id: id).first
      new(record).tap { |item| item.send(:id=, id) }
    else
      raise 'Record not found!'
    end
  end

  def where(attributes)
    _adapter.search(attributes).map do |record|
      new(record).tap { |item| item.send(:id=, record[:id]) }
    end
  end
end
