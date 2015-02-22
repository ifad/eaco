# -*- encoding: utf-8 -*-

require 'spec_helper'

RSpec.describe Eaco do

  describe '.parse_default_rules_file!' do
    subject { Eaco.parse_default_rules_file! }

    before { expect(Eaco).to receive(:parse_rules!).with(Eaco::DEFAULT_RULES) }

    it { expect(subject).to be(nil) }
  end


  describe '.parse_rules!' do
    subject { Eaco.parse_rules! file }

    context 'when the file does exist' do
      let(:file) { double() }

      before do
        expect(file).to receive(:exist?).and_return(true)
        expect(file).to receive(:read).and_return('')
        expect(file).to receive(:realpath).and_return('test')
      end

      it { expect(subject).to be(true) }
    end

    context 'when the file does not exist' do
      let(:file) { Pathname('/nonexistant') }

      it { expect { subject }.to raise_error(Eaco::Malformed, /Please create \/nonexistant/) }
    end
  end

  describe '.eval!' do
    let(:source) { '' }
    let(:path)   { '' }

    subject { Eaco.eval! source, path }

    before { expect(Eaco::DSL).to receive(:eval).with(source, nil, path, 1) }

    it { expect(subject).to be(true) }
  end

end
