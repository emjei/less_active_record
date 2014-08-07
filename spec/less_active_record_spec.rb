require 'spec_helper'

describe LessActiveRecord do
  after do
    File.delete(*Dir['*Table.yml'])
  end

  describe '::storage_name' do
    let(:klass) { Class.new(LessActiveRecord) }

    before do
      allow(klass).to receive(:to_s).and_return('Klass')
    end

    it 'names the content file after the class' do
      expect(klass.storage_name).to be == 'KlassTable'
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

    it 'adds accessor methods to records' do
      record = klass.new
      expect(record).to respond_to(:new_attribute)
      expect(record).to respond_to(:new_attribute=)
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

  describe '#validate' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        validate :validation
        validate 'validation'
      end
    end

    it 'adds a new attribute without duplicates' do
      expect(klass.validations).to match_array %i(validation)
    end

    it 'returns self' do
      expect(klass.validate(:any)).to eq klass
    end
  end

  describe '::validations' do
    it 'returns a copy of the validation names array' do
      klass = Class.new(LessActiveRecord)
      expect {
        klass.validations << 'anything'
      }.not_to change { klass.validations }
    end

    context 'when validations are present' do
      let(:klass) do
        Class.new(LessActiveRecord) do
          validate :validation
        end
      end

      it 'returns the attribute names' do
        expect(klass.validations).to match_array %i(validation)
      end
    end

    context 'when validations are not present' do
      let(:klass) { Class.new(LessActiveRecord) }

      it 'returns an empty array' do
        expect(klass.validations).to be_empty
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
    let(:record) { klass.new(attr_2: 'value') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'sets the specified attributes' do
      expect {
        record.attributes = { attr_1: 'value', attr_2: nil }
      }.to change { record.attributes }
       .from(attr_1: nil, attr_2: 'value')
       .to(attr_1: 'value', attr_2: nil)
    end

    it 'does not set the unspecified ones' do
      expect {
        record.attributes = { attr_1: 'other_value' }
      }.not_to change { record.attr_2 }
    end
  end

  describe '#attributes' do
    let(:record) { klass.new(attr_2: 'value') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'returns the attributes hash' do
      expect(record.attributes).to eq(attr_1: nil, attr_2: 'value')
    end
  end

  describe '#valid?' do
    let(:record) { klass.new }
    let(:klass) do
      Class.new(LessActiveRecord) do
        validate :validation
      end
    end

    it 'runs all specified validations' do
      expect(record).to receive(:validation).once.with no_args()
      record.valid?
    end

    context 'when one of the validations return false' do
      before do
        allow(record).to receive(:validation).and_return false
      end

      it 'returns false' do
        expect(record.valid?).to be_falsy
      end
    end

    context 'when one of the validations throw an exception' do
      before do
        allow(record).to receive(:validation) { raise 'Error!' }
      end

      it 'returns false' do
        expect(record.valid?).to be_falsy
      end
    end

    context 'when all of the validations pass' do
      before do
        allow(record).to receive(:validation).and_return true
      end

      it 'returns true' do
        expect(record.valid?).to be_truthy
      end
    end
  end

  describe '#new_record?' do
    context 'when it is persisted' do
      let(:record) { Class.new(LessActiveRecord).create }

      it 'returns false' do
        expect(record).not_to be_new_record
      end
    end

    context 'when it is not persisted' do
      let(:record) { Class.new(LessActiveRecord).new }

      it 'returns true' do
        expect(record).to be_new_record
      end
    end
  end

  describe '#persisted?' do
    context 'when it is persisted' do
      let(:record) { Class.new(LessActiveRecord).create }

      it 'returns true' do
        expect(record).to be_persisted
      end
    end

    context 'when it is not persisted' do
      let(:record) { Class.new(LessActiveRecord).new }

      it 'returns false' do
        expect(record).not_to be_persisted
      end
    end
  end

  describe '#update' do
    let(:record) { klass.create(attr: '1') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    it 'sets the attributes' do
      expect {
        record.update(attr: '2')
      }.to change(record, :attr).from('1').to '2'
    end

    it 'saves the changes' do
      expect(record).to receive(:save)
      record.update(attr: '2')
    end
  end

  describe '#create' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    it 'sets the attributes' do
      record = klass.create(attr: '1')
      expect(record.attr).to eq '1'
    end

    it 'persists the record' do
      record = klass.create
      expect(record).to be_persisted
    end
  end

  describe '#destroy' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    context 'when the record is persisted' do
      let!(:record) { klass.create }

      it 'destroys the record' do
        expect { record.destroy }.to change { klass.all.size }.by(-1)
      end
    end

    context 'when the record is a new' do
      let!(:record) { klass.new }

      it 'does not change anything' do
        expect { record.destroy }.not_to change { klass.all.size }
      end
    end
  end

  describe '#save' do
    context 'when a record is valid' do
      let(:klass) do
        Class.new(LessActiveRecord) do
          attribute :attr
        end
      end

      it 'returns true if the record is a new' do
        record = klass.new
        expect(record.save).to be_truthy
      end

      it 'persists the record if the it is new' do
        record = klass.new
        expect { record.save }.to change(record, :persisted?).to true
      end

      it 'assigns an id if the record is new' do
        record = klass.new
        expect { record.save }.to change { record.id.nil? }.to false
      end

      it 'updates the data if the record is already persisted' do
        record = klass.create(attr: '1')
        expect {
          record.attr = '2'
          record.save
        }.to change { klass.find(record.id).attr }.from('1').to '2'
      end

      it 'returns true if the record is already persisted' do
        record = klass.create(attr: '1')
        expect(record.save).to be_truthy
      end
    end

    context 'when a record is invalid' do
      let(:record) { klass.new }
      let(:klass) do
        Class.new(LessActiveRecord) do
          validate :validation

          private

          def validation
            false
          end
        end
      end

      it 'returns false' do
        expect(record.save).to be_falsy
      end
    end
  end

  describe '#==' do
    let(:record) { klass.create }
    let(:klass) { Class.new(LessActiveRecord) }

    it 'returns true if records have the same id' do
      same_record = klass.find(record.id)
      expect(record).to eq same_record
    end

    it 'returns false if records have different ids' do
      other_record = klass.create
      expect(record).not_to eq other_record
    end
  end
end
