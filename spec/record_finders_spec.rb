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
    it 'returns all objects' do
      expect(klass).to receive(:where).with({})
      klass.all
    end
  end

  describe '#find' do
    let!(:instance) { klass.create(attr: '1') }

    it 'finds the correct object' do
      result = klass.find(instance.id)
      expect(result.id).to eq instance.id
    end

    it "throws an exception if the object can't be found" do
      expect {
        klass.find("#{ instance.id }-UNKNOWN")
      }.to raise_error('Record not found!')
    end
  end

  describe '#where' do
    let!(:instance) { klass.create(attr: '1') }

    it 'finds the correct object' do
      result = klass.where(attr: '1')
      expect([ instance.id ]).to eq result.map(&:id)
    end

    it 'returns all objects if given an empty hash' do
      result = klass.where({})
      expect([ instance.id ]).to eq result.map(&:id)
    end
  end
end
