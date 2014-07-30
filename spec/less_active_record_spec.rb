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

  describe '#valid?' do
    let(:instance) { klass.new }
    let(:klass) do
      Class.new(LessActiveRecord) do
        validate :validation
      end
    end

    it 'runs all specified validations' do
      expect(instance).to receive(:validation).once.with no_args()
      instance.valid?
    end

    context 'when one of the validations return false' do
      before do
        allow(instance).to receive(:validation).and_return false
      end

      it 'returns false' do
        expect(instance.valid?).to be_falsy
      end
    end

    context 'when one of the validations throw an exception' do
      before do
        allow(instance).to receive(:validation) { raise 'Error!' }
      end

      it 'returns false' do
        expect(instance.valid?).to be_falsy
      end
    end

    context 'when all of the validations pass' do
      before do
        allow(instance).to receive(:validation).and_return true
      end

      it 'returns true' do
        expect(instance.valid?).to be_truthy
      end
    end
  end

  describe '#new_record?' do
    context 'when it is persisted' do
      let(:instance) { Class.new(LessActiveRecord).create }

      it 'returns false' do
        expect(instance).not_to be_new_record
      end
    end

    context 'when it is not persisted' do
      let(:instance) { Class.new(LessActiveRecord).new }

      it 'returns true' do
        expect(instance).to be_new_record
      end
    end
  end

  describe '#persisted?' do
    context 'when it is persisted' do
      let(:instance) { Class.new(LessActiveRecord).create }

      it 'returns true' do
        expect(instance).to be_persisted
      end
    end

    context 'when it is not persisted' do
      let(:instance) { Class.new(LessActiveRecord).new }

      it 'returns false' do
        expect(instance).not_to be_persisted
      end
    end
  end

  describe '#update' do
    let(:instance) { klass.create(attr: '1') }
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    it 'sets the attributes' do
      expect {
        instance.update(attr: '2')
      }.to change(instance, :attr).from('1').to '2'
    end

    it 'saves the changes' do
      expect(instance).to receive(:save)
      instance.update(attr: '2')
    end
  end

  describe '#create' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    it 'sets the attributes' do
      instance = klass.create(attr: '1')
      expect(instance.attr).to eq '1'
    end

    it 'persists the object' do
      instance = klass.create
      expect(instance).to be_persisted
    end
  end

  describe '#destroy' do
    let(:klass) do
      Class.new(LessActiveRecord) do
        attribute :attr
      end
    end

    context 'when the object is persisted' do
      let!(:instance) { klass.create }

      it 'destroys the object' do
        expect { instance.destroy }.to change { klass.all.size }.by(-1)
      end
    end

    context 'when the object is a new record' do
      let!(:instance) { klass.new }

      it 'does not change anything' do
        expect { instance.destroy }.not_to change { klass.all.size }
      end
    end
  end

  describe '#save' do
    context 'when an object is valid' do
      let(:klass) do
        Class.new(LessActiveRecord) do
          attribute :attr
        end
      end

      it 'returns true if the object is a new record' do
        instance = klass.new
        expect(instance.save).to be_truthy
      end

      it 'persists the object if the object is a new record' do
        instance = klass.new
        expect { instance.save }.to change(instance, :persisted?).to true
      end

      it 'assigns an id if the object is a new record' do
        instance = klass.new
        expect { instance.save }.to change { instance.id.nil? }.to false
      end

      it 'updates the data if the object is already persisted' do
        instance = klass.create(attr: '1')
        expect {
          instance.attr = '2'
          instance.save
        }.to change { klass.find(instance.id).attr }.from('1').to '2'
      end

      it 'returns true if the object is already persisted' do
        instance = klass.create(attr: '1')
        expect(instance.save).to be_truthy
      end
    end

    context 'when an object is invalid' do
      let(:instance) { klass.new }
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
        expect(instance.save).to be_falsy
      end
    end
  end
end
