require 'spec_helper'

describe Nebulous::Parser do
  context 'around parsing CSVs' do
    subject { Nebulous::Parser }
    let(:path) { './spec/support/assets/crlf-comma-delimited.csv' }
    let(:parser) { subject.new(path) }

    context '#initialize' do
      it 'can be initialized' do
        expect(parser).to be_instance_of subject
      end

      context 'around options' do
        let(:parser) { subject.new(path, foo: :bar) }
        it 'accepts options' do
          expect(parser.options.foo).to eq :bar
        end
      end
    end

    context '#process' do
      context 'around batches' do
      end

      context 'around batches: false' do
      end
    end

    context '#delimiters' do
      context 'with CRLF and comma delimiters' do
        let(:path) { './spec/support/assets/crlf-comma-delimited.csv' }
        it 'returns the expected delimiters' do
          expect(parser.delimiters).to eq(
            { col_sep: ",", row_sep: "\n" }
          )
        end
      end

      context 'with CRLF and tab delimiters' do
        let(:path) { './spec/support/assets/crlf-tab-delimited.tsv' }
        it 'returns the expected delimiters' do
          expect(parser.delimiters).to eq(
            { col_sep: "\t", row_sep: "\n" }
          )
        end
      end

      context 'with CR, LF and comma delimiters' do
        let(:path) { './spec/support/assets/cr-lf-comma-delimited.csv' }
        it 'returns the expected delimiters' do
          expect(parser.delimiters).to eq(
            { col_sep: ",", row_sep: "\r\n" }
          )
        end
      end

      context 'with CR and comma delimiters' do
        let(:path) { './spec/support/assets/cr-comma-delimited.csv' }
        it 'returns the expected delimiters' do
          expect(parser.delimiters).to eq(
            { col_sep: ",", row_sep: "\r" }
          )
        end
      end
    end

    context '#read_input' do
      context 'with a path string input' do
        it 'returns expected instance of File' do
          expect(parser.file).to be_instance_of File
        end
      end

      context 'with a file input' do
        let(:file) { File.new(path) }
        let(:parser) { subject.new(file) }
        it 'returns expected instance of File' do
          expect(parser.file).to be_instance_of File
        end
      end
    end

    context '#readline' do
      it 'reads from file input' do
        expect(parser.send(:readline)).to eq(
          "First name,Last name,From,Access,Qty\n"
        )
        expect(parser.send(:readline)).to eq(
          "どーもありがとう,ミスター·ロボット,VIP,VIP,2\n"
        )
        expect(parser.send(:readline)).to eq(
          "Meghan,Koch,VIP,VIP,5\n"
        )
      end

      context 'around encoding', pending: true do
        let(:path) { './spec/support/assets/fucky-encoding.csv' }
        # it 'properly reads and encodes data' do
        #   expect(parser.send(:readline)).to eq nil
        # end
      end
    end

    context '#encoding' do
      context 'with provided encoding' do
        let(:parser) { subject.new(path, encoding: Encoding::ISO_8859_1.to_s) }
        it 'returns expected encoding' do
          expect(parser.send(:encoding)).to eq Encoding::ISO_8859_1.to_s
        end
      end

      context 'with default encoding' do
        it 'returns UTF-8 encoding' do
          expect(parser.send(:encoding)).to eq Encoding::UTF_8.to_s
        end
      end
    end

    context '#merge_delimiters' do
      context 'with provided delimeters' do
        let(:parser) { subject.new(path, col_sep: "\cA", row_sep: "\cB\n") }
        it 'returns the expected delimiters' do
          expect(parser.options.col_sep).to eq "\cA"
          expect(parser.options.row_sep).to eq "\cB\n"
        end
      end

      context 'with auto-detected delimiters' do
        it 'returns the expected delimiters' do
          expect(parser.options.col_sep).to eq ","
          expect(parser.options.row_sep).to eq "\n"
        end
      end
    end

    context '#line_terminator' do
      context 'with CRLF terminators' do
        let(:path) { './spec/support/assets/crlf-comma-delimited.csv' }
        it 'sets the expected line terminator' do
          expect(parser.send(:line_terminator)).to eq "\n"
        end
      end

      context 'with CR, LF terminators' do
        let(:path) { './spec/support/assets/cr-lf-comma-delimited.csv' }
        it 'sets the expected line terminator' do
          expect(parser.send(:line_terminator)).to eq "\r\n"
        end
      end

      context 'with CR terminators' do
        let(:path) { './spec/support/assets/cr-comma-delimited.csv' }
        it 'sets the expected line terminator' do
          expect(parser.send(:line_terminator)).to eq "\r"
        end
      end
    end
  end
end
