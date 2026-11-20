require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def usage
		"#{program_name} INFILE"
	end

	def arguments
	<<-EOS
    INFILE    Input file (.pml, .csv, .tsv, .org, or .isorg)
EOS
	end
    def initialize
		super 'convert', '    Convert a CASTEML dataset to another format' # Summary:

		add_option('-f', '--format OUTFORMAT',
				   'Output format (pml, csv, tsv, org, isorg, dataframe, tex, or pdf)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('--medusa9',
				   'Write PML in Medusa 9 format') do |v, options|
			options[:version] = '9'
		end

		add_option('--[no-]unit [UNIT]',
				   'Use the specified unit, or write values in parts with --no-unit') do |v, options|
			options[:with_unit] = v
		end

		add_option('-n', '--number-format FORMAT',
				   'Number format for TeX output (default: %.4g)') do |v, options|
			options[:number_format] = v
		end

		# MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.record_pool.map{|category| "'" + category.name + "'"}

		add_option('-c', '--category CATEGORY',
				   "Filter measurements by category (#{category_names.join(', ')})") do |v, options|
			options[:with_category] = v
		end

		add_option('-t', '--transpose',
				   'Swap rows and columns in CSV, TSV, Org, ISORG, or TeX output') do |v, options|
			options[:transpose] = v
		end

		add_option('-a', '--average',
				   'Append an average acquisition') do |v, options|
			options[:with_average] = v
		end

		add_option('-s', '--smash',
				   'Output only the average acquisition') do |v, options|
			options[:smash] = v
		end

        add_option('-p', '--place',
                   'Include location fields in tabular export') do |v, options|
          options[:with_place] = v
        end

        # add_option('-e', '--error',
        #            'Output with error') do |v, options|
        #   options[:with_error] = v
        # end

		# add_option('-d', '--debug', 'Show debug information') do |v|
		#   options[:debug] = v
		# end
	end

	def description
		<<-EOF
    Convert PML, CSV, TSV, Org, or ISORG input. The default output is
    CSV for PML input and PML for other inputs. Redirect standard output
    to save the converted dataset.

    Inspect a PML file containing an analysis.
    $ casteml download 20081202172326.hkitagawa > 20081202172326.pml
    $ casteml convert 20081202172326.pml | head
    $ open http://database.misasa.okayama-u.ac.jp/stone/bibs/8.pml

    Inspect a PML file containing an analysis and a spot.
    $ casteml download 20160923194512-900008 > 20160923194512-900008.pml
    $ casteml convert 20160923194512-900008.pml | head
    $ open http://database.misasa.okayama-u.ac.jp/stone/attachment_files/48326.pml

    Unit conversion uses the alchemist gem. Use % or cg/g to specify
    a mass percentage.

Format:
    pml:       The standard CASTEML file.
    csv:       Comma-separated values. Each row is an acquisition, and
               each measurement has its own column. An error column adds
               _error to the measurement name, for example SiO2_error.
               Write units in parentheses after the measurement name,
               such as SiO2 (cg/g), or put them in a separate second
               row with an empty first cell. Rows and columns can be
               transposed.
    tsv:       Tab-separated values.
    org:       An Org-mode table delimited by vertical bars.
    isorg:     An Org-mode table in the ISORG format.
    dataframe: A CSV table for R, also available as dflame. The first
               two columns are element and unit, followed by acquisitions.
   tex:        A LaTeX table. Measurement labels come from Medusa.
               Run casteml --refresh after changing them on the server.
   pdf:        Compile the LaTeX table with pdflatex and the pmlatex package.
EOF
	end

	def example
	<<-EOS
    $ casteml download 20081202172326.hkitagawa > 20081202172326.pml
    $ casteml convert 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f csv --no-unit 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f csv --unit 'cg/g' 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f tex -n %.5g 20081202172326.pml > 20081202172326.tex
    $ casteml convert -f dflame 20081202172326.pml > 20081202172326-dflame0.csv

    R> file    <- '20081202172326-dflame0.csv'
    R> pmlame0 <- read.csv(file,row.names=1,header=T,stringsAsFactors=F)
EOS
	end

	def see_also
	<<-EOS
    casteml join
    casteml split
    casteml/spec/casteml/formats/
    https://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/convert_command.rb
EOS
	end




	def output(string)
		puts string
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift

    	string = Casteml.convert_file(path, options)
    	output(string)
    	# puts string
    	# xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
