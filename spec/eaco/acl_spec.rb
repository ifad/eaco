# -*- encoding: utf-8 -*-

require 'spec_helper'

RSpec.describe Eaco::ACL do

  describe '#initialize' do
    subject { described_class.new(plain_acl) }

    let(:plain_acl) { Hash['user:42' => 'reader', 'group:fropper' => 'editor'] }

    it { expect(subject).to be_a(described_class) }
    it { expect(subject).to eq({'user:42' => :reader, 'group:fropper' => :editor}) }
  end

  describe '#add' do
    let(:designator) { Eaco::Designator.new 'test' }

    subject { acl.add(:reader, designator) }

    context 'when adding non-existing permissions' do
      let(:acl) { described_class.new }

      it { expect(subject).to be_a(described_class) }
      it { expect(subject).to include({designator => :reader}) }
    end

    context 'when replacing existing permissions' do
      let(:acl) { described_class.new(designator => :editor) }

      it { expect(subject).to be_a(described_class) }
      it { expect(subject).to include({designator => :reader}) }
    end
  end

  describe '#del' do
    let(:designator) { Eaco::Designator.new 'test' }

    subject { acl.del(designator) }

    context 'when removing non-existing permissions' do
      let(:acl) { described_class.new }
      it { expect(subject).to eq({}) }
    end

    context 'when removing existing permissions' do
      let(:acl) { described_class.new(designator => :editor) }
      it { expect(subject).to eq({}) }
    end
  end

  describe '#find_by_role' do
    let(:reader1) { Eaco::Designator.new 'Tom.Fropp' }
    let(:reader2) { Eaco::Designator.new 'Bob.Prutz' }
    let(:editor)  { Eaco::Designator.new 'Jake.Boon' }

    let(:acl) do
      described_class.new({
        reader1 => :reader,
        reader2 => :reader,
        editor  => :editor,
      })
    end

    context 'when looking up valid roles' do
      subject { acl.find_by_role(:reader) }

      it { expect(subject).to eq(Set.new([reader1, reader2])) }
    end

    context 'when looking up nonexisting roles' do
      subject { acl.find_by_role(:froober) }

      it { expect(subject).to eq(Set.new) }
    end
  end

  describe '#all' do
    let(:reader) { Eaco::Designator.new 'John.Loom' }
    let(:editor) { Eaco::Designator.new 'Mark.Poof' }

    let(:acl) do
      described_class.new({
        reader => :reader,
        editor => :editor,
      })
    end

    subject { acl.all }

    it { expect(subject).to eq(Set.new([reader, editor])) }
  end

  describe '#designators_map_for_role' do
    let(:reader)  { Eaco::Designator.new 'Pete.Raid' }
    let(:editor1) { Eaco::Designator.new 'John.Alls' }
    let(:editor2) { Eaco::Designator.new 'Bob.Prutz' }

    let(:acl) do
      described_class.new({
        reader  => :reader,
        editor1 => :editor,
        editor2 => :editor,
      })
    end

    subject { acl.designators_map_for_role(:editor) }

    before do
      expect(editor1).to receive(:resolve) { ['John Alls'] }
      expect(editor2).to receive(:resolve) { ['Robert Prutzon'] }
    end

    example do
      expect(subject).to eq({
        editor1 => Set.new(['John Alls']),
        editor2 => Set.new(['Robert Prutzon'])
      })
    end
  end

  describe '#actors_by_role' do
    let(:reader)  { Eaco::Designator.new 'Pete.Raid' }
    let(:editor1) { Eaco::Designator.new 'John.Alls' }
    let(:editor2) { Eaco::Designator.new 'Bob.Prutz' }

    let(:acl) do
      described_class.new({
        reader  => :reader,
        editor1 => :editor,
        editor2 => :editor,
      })
    end

    subject { acl.actors_by_role(:editor) }

    before do
      expect(editor1).to receive(:resolve) { ['John Alls'] }
      expect(editor2).to receive(:resolve) { ['Robert Prutzon'] }
    end

    example do
      expect(subject).to eq(['John Alls', 'Robert Prutzon'])
    end
  end

end
