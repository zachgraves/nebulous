require 'spec_helper'

describe Nebulous::DelimiterDetector do
  context 'around detecting csv delimiters' do
    subject { Nebulous::DelimiterDetector }
    let(:path) { './spec/support/assets/crlf-comma-delimited.csv' }
    let(:detector) { subject.new(path) }

    context '#initialize' do
      it 'can be initialized' do
        expect(detector).to be_instance_of subject
      end

      it 'assigns specified file path' do
        expect(detector.path).to eq path
      end
    end

    context '#detect' do
      context 'with CRLF and comma delimiters' do
        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: ",", row_delimiter: "\n" }
          )
        end
      end

      context 'with CRLF and tab delimiters' do
        let(:path) { './spec/support/assets/crlf-tab-delimited.tsv' }
        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: "\t", row_delimiter: "\n" }
          )
        end
      end

      context 'with CR and comma delimiters' do
        let(:path) { './spec/support/assets/cr-comma-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: ",", row_delimiter: "\r" }
          )
        end
      end

      context 'with semicolon delimiters' do
        let(:path) { './spec/support/assets/crlf-semicolon-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: ";", row_delimiter: "\n" }
          )
        end
      end

      context 'with pipe delimiters' do
        let(:path) { './spec/support/assets/crlf-pipe-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: "|", row_delimiter: "\n" }
          )
        end
      end

      context 'with custom delimiters' do
        let(:detector) { subject.new(path, options) }
        let(:path) { './spec/support/assets/crlf-dolla-delimited.csv' }
        let(:options) do
          { column_delimiters: ["\n", '$', "\t"] }
        end

        it 'detects expected delimiters' do
          expect(detector.detect).to eq(
            { column_delimiter: "$", row_delimiter: "\n" }
          )
        end
      end
    end

    context '#detect_column_delimiter' do
      context 'with comma delimiters' do
        it 'detects expected delimiters' do
          expect(detector.detect_column_delimiter).to eq ','
        end
      end

      context 'with tab delimiters' do
        let(:path) { './spec/support/assets/crlf-tab-delimited.tsv' }
        it 'detects expected delimiters' do
          expect(detector.detect_column_delimiter).to eq "\t"
        end
      end

      context 'with semicolon delimiters' do
        let(:path) { './spec/support/assets/crlf-semicolon-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect_column_delimiter).to eq ';'
        end
      end

      context 'with pipe delimiters' do
        let(:path) { './spec/support/assets/crlf-pipe-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect_column_delimiter).to eq '|'
        end
      end

      context 'with custom delimiters' do
        let(:detector) { subject.new(path, options) }
        let(:path) { './spec/support/assets/crlf-dolla-delimited.csv' }
        let(:options) do
          { column_delimiters: ["\n", '$', "\t"] }
        end

        it 'detects expected delimiters' do
          expect(detector.detect_column_delimiter).to eq '$'
        end
      end
    end

    context '#detect_line_delimiter' do
      context 'with CRLF terminators' do
        it 'detects expected delimiters' do
          expect(detector.detect_line_delimiter).to eq "\n"
        end
      end

      context 'with CR terminators' do
        let(:path) { './spec/support/assets/cr-comma-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect_line_delimiter).to eq "\r"
        end
      end

      context 'with CR, LF terminators' do
        let(:path) { './spec/support/assets/cr-lf-comma-delimited.csv' }
        it 'detects expected delimiters' do
          expect(detector.detect_line_delimiter).to eq "\r\n"
        end
      end
    end

    context '#line_delimiters' do
    end

    context '#column_delimiters' do
    end

    context '#encoding' do
    end

    context '#counts' do
    end

    context '#max_count' do
    end

    context '#readline' do
      it 'returns first line from provided file' do
        ln = detector.send(:readline)
        expect(ln).to eq "First name,Last name,From,Access,Qty\n"
      end
    end
  end
end
