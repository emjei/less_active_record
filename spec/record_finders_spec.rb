require 'spec_helper'

describe RecordFinders do
  let(:klass) do
    Class.new(LessActiveRecord) do
      attribute :attr
    end
  end

  after do
    File.delete(*Dir['*Table.yml'])
  end

  describe '#all' do
    it 'returns all records' do
      expect(klass).to receive(:where).with({})
      klass.all
    end
  end

  describe '#find' do
    let!(:record) { klass.create(attr: '1') }

    it 'finds the correct record' do
      result = klass.find(record.id)
      expect(result).to eq record
    end

    it "throws an exception if the record can't be found" do
      expect {
        klass.find("#{ record.id }-UNKNOWN")
      }.to raise_error('Record not found!')
    end
  end

  describe '#where' do
    let!(:record) { klass.create(attr: '1') }

    it 'finds the correct record' do
      records = klass.where(attr: '1')
      expect([record]).to eq records
    end

    it 'returns all records if given an empty hash' do
      records = klass.where({})
      expect([record]).to eq records
    end
  end
end
