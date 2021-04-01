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
        let(:parser) { subject.new(path, foo: :bar, col_sep: "HI!") }

        it 'accepts options' do
          expect(parser.options.foo).to eq :bar
        end

        it 'merges options' do
          expect(parser.options.col_sep).to eq "HI!"
        end
      end
    end

    context '#headers' do
      context 'around fetching headers' do
        it 'returns expected headers' do
          expect(parser.headers).to eq(
            ["First name", "Last name", "From", "Access", "Qty"]
          )
        end

        context 'around empty lines' do
          let(:path) do
            './spec/support/assets/crlf-comma-delimited-emptyline.csv'
          end

          it 'returns expected headers' do
            expect(parser.headers).to eq(
              ["First name", "Last name", "From", "Access", "Qty"]
            )
          end
        end
      end
    end

    context '#process' do
      context 'around limits' do
        let(:parser) { subject.new(path, limit: limit) }

        context 'with zero limit' do
          let(:limit) { 0 }
          it 'returns empty data set' do
            expect(parser.process).to be_empty
          end
        end

        context 'with in-bounds limit' do
          let(:limit) { 2 }
          it 'returns expected chunk size' do
            expect(parser.process.length).to eq 2
          end
        end

        context 'with out of bounds limit' do
          let(:limit) { 1_000_000 }
          it 'returns expected chunk size' do
            expect(parser.process.length).to eq 20
          end
        end
      end

      context 'around missing headers' do
        let(:path) { './spec/support/assets/no-headers.csv' }
        let(:parser) { subject.new(path, headers: false) }

        it 'returns unmapped data' do
          expect(parser.process.first.to_a).to be_instance_of Array
        end

        it 'returns expected chunk size' do
          expect(parser.process.length).to eq 20
        end
      end

      context 'around user-provided headers' do
        let(:map) do
          { first_name: :test1, last_name: :test2, qty: :test3 }
        end

        let(:parser) { subject.new(path, mapping: map) }
        let(:data) { parser.process }
        let(:headers) { data.first.keys }

        it 'returns expected keys' do
          expect(headers).to eq %i(test1 test2 test3)
        end

        it 'correctly maps keys to values' do
          expect(data.first[:test3]).to eq 2
        end
      end

      context 'around headers_line' do
        let(:path) { './spec/support/assets/headers-on-secondary-line.csv' }

        let(:parser) { subject.new(path, start: 1) }
        let(:data) { parser.process }
        let(:headers) { data.first.keys }

        it 'returns expected keys' do
          expect(headers).to eq %i(first_name last_name from access qty)
        end

        it 'correctly maps keys to values' do
          expect(data.first[:qty]).to eq 2
        end
      end

      context 'around chunking' do
        let(:parser) { subject.new(path, chunk: 6) }

        it 'returns entire dataset when no block passed' do
          expect(parser.process.length).to eq 20
        end

        context 'with block given' do
          it 'yields for each chunk' do
            count = 0
            parser.process { count += 1 }
            expect(count).to eq 4
          end

          it 'returns expected total rows' do
            data = []
            parser.process do |chunk|
              data << chunk
            end
            expect(data.map(&:size).inject(:+)).to eq 20
          end
        end
      end

      context 'around chunk: false' do
        let(:data) { parser.process }
        let(:headers) { data.first.keys }
        let(:values) { data.first.values }

        it 'returns expected length' do
          expect(data.length).to eq 20
        end

        it 'contains expected headers' do
          expect(headers).to eq %i(first_name last_name from access qty)
        end

        it 'contains expected values' do
          expect(values).to eq(
            ["どーもありがとう", "ミスター·ロボット", "VIP", "VIP", 2]
          )
        end
      end

      context 'around limits' do
      end

      context 'around empty values' do
      end

      context 'when no headers are present' do
      end

      context 'around rewinding' do
        it 'parser can process many times' do
          parser.process
          expect(parser.process.length).to eq 20
        end
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
            { col_sep: ",", row_sep: "\r" }
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
          "First name,Last name,From,Access,Qty"
        )
        expect(parser.send(:readline)).to eq(
          "どーもありがとう,ミスター·ロボット,VIP,VIP,2"
        )
        expect(parser.send(:readline)).to eq(
          "Meghan,Koch,VIP,VIP,5"
        )
      end

      context 'around line terminators' do
        context 'with CR-LF terminators' do
          let(:path) { './spec/support/assets/cr-lf-comma-delimited.csv' }
          it 'reads from file input' do
            expect(parser.send(:readline)).to eq(
              "First Name, Last Name"
            )
          end
        end
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
          expect(parser.send(:line_terminator)).to eq "\r"
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
