require 'spec_helper'

describe LessActiveRecord do
  before do
    class Klass < LessActiveRecord; end
  end

  describe '::file_name' do
    it 'names the content file after the class' do
      expect(Klass.file_name).to be == 'klass_table.yml'
    end
  end

  describe '::load' do
    context 'when the content file exists' do
      before do
        allow(File).to receive(:exists?).and_return true
      end

      it 'loads the file' do
        expect(YAML).to receive(:load_file).with('klass_table.yml')
        Klass.load
      end
    end

    context 'when the content file does not exist' do
      before do
        allow(File).to receive(:exists?).and_return false
      end

      it 'loads an empty array' do
        expect(Klass.load).to eq []
      end
    end
  end

  describe '::dump' do
    let(:items) { %w(item) }

    context 'when the content was loaded before dumping' do
      before do
        allow(File).to receive(:exists?).and_return true
        allow(YAML).to receive(:load_file).and_return items
        Klass.load
      end

      it 'opens a content file for writing' do
        expect(File).to receive(:open).with('klass_table.yml', 'w')
        Klass.dump
      end

      it 'dumps the content to the opened file' do
        file = double('file')
        allow(File).to receive(:open) { |_, _, &block| block.call(file) }
        expect(YAML).to receive(:dump).with(items, file)
        Klass.dump
      end
    end

    context 'when the content was not loaded before dumping' do
    end
  end
end
