require 'spec_helper'

describe YAMLObjectMapper do
  let(:mapper) { YAMLObjectMapper.new('File.yml') }

  describe '#load_file' do
    context 'when the content file exists' do
      before do
        allow(File).to receive(:exists?).and_return true
      end

      it 'loads the file contents' do
        expect(YAML).to receive(:load_file)
          .with('File.yml').and_return('content')
        expect(mapper.load_file).to eq 'content'
      end
    end

    context 'when the content file does not exist' do
      before do
        allow(File).to receive(:exists?).and_return false
      end

      it 'returns nil' do
        expect(mapper.load_file).to be_nil
      end
    end
  end

  describe '#dump_file' do
    let(:object) { double('some object') }

    it 'opens a file for writing' do
      expect(File).to receive(:open).with('File.yml', 'w')
      mapper.dump_file(object)
    end

    it 'dumps the object to the opened file' do
      file = double('file')
      allow(File).to receive(:open) { |_, _, &block| block.call(file) }
      expect(YAML).to receive(:dump).with(object, file)
      mapper.dump_file(object)
    end
  end
end
