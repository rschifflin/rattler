require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Choice do
  include CombinatorParserSpecHelper

  subject { Choice[*nested] }

  describe '#parse' do

    let(:nested) { [Match[/[[:alpha:]]+/], Match[/[[:digit:]]+/]] }

    context 'when any of the parsers match' do
      it 'matches the same as the first parser that matches' do
        parsing('abc123').should result_in('abc').at(3)
        parsing('123abc').should result_in('123').at(3)
      end
    end

    context 'when none of the parsers match' do
      it 'fails' do
        parsing('==').should fail
      end
    end

    context 'with no capturing parsers' do
      let :nested do
        [Skip[Match[/[[:alpha:]]+/]], Skip[Match[/[[:digit:]]+/]]]
      end

      context 'when any of the parsers match' do
        it 'returns true' do
          parsing('abc123').should result_in(true).at(3)
          parsing('123abc').should result_in(true).at(3)
        end
      end
    end
  end

  describe '#capturing?' do

    context 'with any capturing parsers' do

      let(:nested) { [Skip[Match[/[[:space:]]*/]], Match[/[[:alpha:]]+/]] }

      it 'is true' do
        subject.should be_capturing
      end
    end

    context 'with no capturing parsers' do

      let(:nested) { [Skip[Match[/[[:alpha:]]+/]], Skip[Match[/[[:digit:]]+/]]] }

      it 'is false' do
        subject.should_not be_capturing
      end
    end
  end

  describe '#capturing_decidable?' do

    context 'with all decidably capturing parsers' do

      let(:nested) { [Match[/a/], Match[/b/]] }

      it 'is true' do
        subject.should be_capturing_decidable
      end
    end

    context 'with all decidably non-capturing parsers' do

      let(:nested) { [Skip[Match[/a/]], Skip[Match[/b/]]] }

      it 'is true' do
        subject.should be_capturing_decidable
      end
    end

    context 'with any non-capturing_decidable parsers' do

      let(:nested) { [Match[/a/], Apply[:a]] }

      it 'is false' do
        subject.should_not be_capturing_decidable
      end
    end

    context 'with both decidably capturing and decidably non-capturing parsers' do

      let(:nested) { [Match[/a/], Skip[Match[/b/]]] }

      it 'is false' do
        subject.should_not be_capturing_decidable
      end
    end
  end

  describe '#with_ws' do

    let(:ws) { Match[/\s*/] }
    let(:nested) { [Match[/[[:alpha:]]+/], Match[/[[:digit:]]+/]] }

    it 'applies #with_ws to the nested parsers' do
      subject.with_ws(ws).should == Choice[
        Sequence[Skip[ws], nested[0]],
        Sequence[Skip[ws], nested[1]]
      ]
    end
  end

end
