require 'spec_helper'

describe YAMLAdapter do
  let(:adapter) { YAMLAdapter.new('File') }

  before do
    allow(adapter).to receive(:dump_all_items!)
  end

  describe '#insert' do
    let(:id) { 1 }

    before do
      allow(adapter).to receive(:calculate_id).and_return(id)
    end

    it 'saves the data' do
      adapter.insert(data: 'data')
      expect(adapter.search(data: 'data')).to eq [{ data: 'data', id: 1 }]
    end

    it 'returns the record id' do
      expect(adapter.insert(data: 'data')).to eq 1
    end

    it 'dumps the records to a file' do
      expect(adapter).to receive(:dump_all_items!)
      adapter.insert(data: 'data')
    end

    it 'loads the records only after the first use' do
      expect(adapter).to receive(:load_all_items).once
      adapter.insert(data: 'data')
      adapter.insert(data: 'some more data')
    end
  end

  describe '#destroy' do
    context 'when the record is found' do
      let!(:id) { adapter.insert(data: 'data') }

      it 'removes the record' do
        expect {
          adapter.destroy(id)
        }.to change { adapter.search(id: id).size }.by(-1)
      end

      it 'returns the removed record' do
        expect(adapter.destroy(id)).to eq(data: 'data', id: id)
      end

      it 'dumps the records to a file' do
        expect(adapter).to receive(:dump_all_items!)
        adapter.destroy(id)
      end
    end

    context 'when the record is not found' do
      it 'returns nil' do
        expect(adapter.destroy('any')).to be_nil
      end
    end
  end

  describe '#update' do
    context 'when the updated record was found' do
      let!(:id) { adapter.insert(attr: 'value') }

      it 'updates the record' do
        adapter.update(id, attr: 'other')
        records = adapter.search(id: id)
        expect(records).to eq [{ attr: 'other', id: id }]
      end

      it 'returns true' do
        expect(adapter.update(id, {})).to be_truthy
      end

      it 'does not let to update the id' do
        adapter.update(id, id: 'NEW-ID')
        expect(adapter.search(id: 'NEW-ID')).to be_empty
      end
    end

    context 'when the updated record was not found' do
      it 'returns false' do
        expect(adapter.update(100, {})).to be_falsy
      end
    end
  end

  describe '#search' do
    let!(:id_1) { adapter.insert(attr_1: 'val_1') }
    let!(:id_2) { adapter.insert(attr_2: 'val_2') }

    context 'with a query' do
      it 'returns the matching records' do
        records = adapter.search(attr_1: 'val_1')
        expect(records).to eq [{ attr_1: 'val_1', id: id_1 }]
      end
    end

    context 'without a query' do
      it 'returns all the records' do
        records = [
          { attr_1: 'val_1', id: id_1 },
          { attr_2: 'val_2', id: id_2 }
        ]

        expect(adapter.search).to match_array records
      end
    end
  end

  describe '#file_name' do
    it 'returns the content file name' do
      expect(adapter.file_name).to eq 'File.yml'
    end
  end
end
