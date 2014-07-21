require 'spec_helper'

describe LessActiveRecord do
  describe '::file_name' do
    let(:klass) { Class.new(LessActiveRecord) }

    before do
      allow(klass).to receive(:to_s).and_return('Klass')
    end

    it 'names the content file after the class' do
      expect(klass.file_name).to be == 'klass_table.yml'
    end
  end

  describe '::attribute' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :new_attribute
        attribute 'new_attribute'
        attribute :new_attribute
        attribute 'new_attribute'
      end
    end

    it 'adds accessor methods to instances' do
      instance = klass.new
      expect(instance).to respond_to(:new_attribute)
      expect(instance).to respond_to(:new_attribute=)
    end

    it 'adds a new attribute without duplicates' do
      expect(klass.attribute_names).to match_array %i(new_attribute)
    end

    it 'returns self' do
      expect(klass.attribute(:any)).to eq klass
    end
  end

  describe '::attribute_names' do
    it 'returns a copy of the attribute names array' do
      klass = Class.new(LessActiveRecord)
      expect {
        klass.attribute_names << 'anything'
      }.not_to change { klass.attribute_names }
    end

    context 'when attributes are present' do
      let(:klass) do
        Class.new(LessActiveRecord) do
          attribute :new_attribute
        end
      end

      it 'returns the attribute names' do
        expect(klass.attribute_names).to match_array %i(new_attribute)
      end
    end

    context 'when attributes are not present' do
      let(:klass) { Class.new(LessActiveRecord) }

      it 'returns an empty array' do
        expect(klass.attribute_names).to be_empty
      end
    end
  end

  describe '::new' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    it 'sets the specified attributes' do
      expect_any_instance_of(klass).to receive(:attributes=)
      klass.new(attr: 'value')
    end
  end

  describe '#attributes=' do
    let(:instance) { klass.new(attr_2: 'value') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'sets the specified attributes' do
      expect {
        instance.attributes = { attr_1: 'value', attr_2: nil }
      }.to change { instance.attributes }
       .from(attr_1: nil, attr_2: 'value')
       .to(attr_1: 'value', attr_2: nil)
    end

    it 'does not set the unspecified ones' do
      expect {
        instance.attributes = { attr_1: 'other_value' }
      }.not_to change { instance.attr_2 }
    end
  end

  describe '#attributes' do
    let(:instance) { klass.new(attr_2: 'value') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'returns the attributes hash' do
      expect(instance.attributes).to eq(attr_1: nil, attr_2: 'value')
    end
  end

  # describe '::load' do
  #   context 'when the content file exists' do
  #     before do
  #       allow(File).to receive(:exists?).and_return true
  #     end

  #     it 'loads the file' do
  #       expect(YAML).to receive(:load_file).with('klass_table.yml')
  #       Klass.load
  #     end
  #   end

  #   context 'when the content file does not exist' do
  #     before do
  #       allow(File).to receive(:exists?).and_return false
  #     end

  #     it 'returns nil' do
  #       expect(Klass.load).to be_nil
  #     end
  #   end
  # end

  # describe '::dump' do
  #   let(:items) { %w(item) }

  #   context 'when the content was loaded before dumping' do
  #     before do
  #       allow(File).to receive(:exists?).and_return true
  #       allow(YAML).to receive(:load_file).and_return items
  #       Klass.load
  #     end

  #     it 'opens a content file for writing' do
  #       expect(File).to receive(:open).with('klass_table.yml', 'w')
  #       Klass.dump
  #     end

  #     it 'dumps the content to the opened file' do
  #       file = double('file')
  #       allow(File).to receive(:open) { |_, _, &block| block.call(file) }
  #       expect(YAML).to receive(:dump).with(items, file)
  #       Klass.dump
  #     end

  #     it 'dumps the content' do
  #       File.open('h.yml', 'w') do |file|
  #         YAML.dump(nil, file)
  #       end
  #       p YAML.load_file('h.yml')
  #     end
  #   end
  # end
end