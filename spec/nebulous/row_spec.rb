require 'spec_helper'

describe Nebulous::Row do
  context 'around reading csv rows' do
    subject { Nebulous::Row }

    let(:col_sep) { ',' }
    let(:row_sep) { "\n" }
    let(:options) do
      { col_sep: col_sep, row_sep: row_sep, quote_char: '"', comment_exp: /^#/ }
    end

    context '::headers' do
      it 'parses and normalizes a csv string as headers' do
        headers = subject.headers("First name, last-name, guests", options)
        expect(headers).to eq(
          {first_name: :first_name, last_name: :last_name, guests: :guests}
        )
      end
    end

    context '::parse' do
      context 'with valid csv' do
        it 'returns expected parsed result' do
          row = subject.parse "raw denim, Austin,selvage,artisan", options
          expect(row).to eq ["raw denim", "Austin", "selvage", "artisan"]
        end
      end

      context 'with valid tsv' do
        let(:col_sep) { "\t" }
        it 'returns expected parsed result' do
          row = subject.parse "raw denim\tAustin\t selvage\tartisan", options
          expect(row).to eq ["raw denim", "Austin", "selvage", "artisan"]
        end
      end

      context 'with empty values' do
        it 'returns expected parsed result' do
          row = subject.parse ",Austin, Artisan ", options
          expect(row).to eq ['', 'Austin', 'Artisan']
        end
      end

      context 'with malformed csv' do
        it 'returns expected parsed result' do
          row = subject.parse 'raw denim, Austin "TX, US", artisan', options
          expect(row).to eq ["raw denim", "Austin \"TX, US\"", "artisan"]
        end
      end

      context 'with malformed tsv' do
        let(:col_sep) { "\t" }
        it 'returns expected parsed result' do
          row = subject.parse "raw denim\t Austin \"TX, US\"\t artisan", options
          expect(row).to eq ["raw denim", "Austin \"TX, US\"", "artisan"]
        end
      end
    end

    context '#to_numeric' do
      it 'converts numeric values to ints/floats' do
        row = subject.new ["1", "two", "3", "4.5"]
        expect(row.to_numeric).to eq [1, "two", 3, 4.5]
      end
    end

    context '#merge' do
      it 'zips a row with provided headers' do
        headers = subject.headers "first name, last name", options
        row = subject.new ["bob", "barker"]
        expect(row.merge(headers)).to eq(
          { first_name: "bob", last_name: "barker" }
        )
      end
    end
  end
end
