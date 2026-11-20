require 'casteml/command'
require 'casteml'
require 'casteml/formats/xml_format'
class Casteml::Commands::DownloadCommand < Casteml::Command
	def usage
		"#{program_name} [options] ID0 [ID1 ...]"
	end

	def arguments
	<<-EOS
    ID0, ID1, ...   Medusa record IDs
EOS
	end

    def initialize
	  super 'download', '    Download datasets from Medusa' # Summary:

	  add_option('-f', '--format OUTFORMAT',
				 'Output format (pml, csv, tsv, org, isorg, tex, pdf, dataframe)') do |v, options|
		options[:output_format] = v.to_sym
	  end

	  add_option('-r', '--descendant',
				 'Include analyses for the stone and its descendants') do |v|
		options[:recursive] = :self_and_descendants
	  end

	  add_option('-R', '--family',
				 'Include analyses for the entire stone family') do |v|
		options[:recursive] = :families
	  end

	  add_option('-n', '--number-format NUMFORMAT',
				 'Number format for LaTeX-based output (default: %.4g)') do |v, options|
		options[:number_format] = v
	  end
	end

	def description
    <<-EOS
    Download analyses for one or more Medusa records and write the
    combined dataset to standard output. The default format is PML.
    Redirect the output to save it to a file.

    Record IDs can identify stones, boxes, sessions (analyses),
    bibliography records, tables, or images. An image ID selects
    analyses linked through spots, and a bibliography ID selects
    analyses linked directly to that record.

    Use --descendant or --family with stone or box IDs. The server
    handles the recursive request for each ID. Fetching an entire
    family for a box can take a long time.

    To combine datasets you downloaded separately, use casteml join.
EOS
	end

	def example
	<<-EOS
    $ casteml download 20130528105235-594267
    ...
    $ casteml download -r 20130528105235-594267 > download.pml
    $ casteml convert download.pml -f csv > data-from-casteml.csv
    ...
    $ casteml download 20110205103129-336-399 20110203174950-308-353 > c.pml
    ...
    $ casteml download 20110205103129-336-399 > a.pml
    $ casteml download 20110203174950-308-353 > b.pml
    $ casteml join a.pml b.pml > c.pml
    ...
    $ casteml plot c.pml
    ...
    $ casteml download 20160226174711-288407 > mosaic_ok11mc.pml
    $ casteml convert mosaic_ok11mc.pml -f org > mosaic_ok11mc.isorg
EOS
	end

	def see_also
	<<-EOS
    casteml convert
    casteml join
    casteml plot
    https://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/download_command.rb
EOS
	end




    def output(string)
        puts string
    end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify stone-ID or analysis-ID') if args.empty?
		#id = args.shift
		options_download = {}
        paths = []
        jpath = nil
        joined = nil
        strings = []
        castemls = []
        while(id = args.shift) do
		  options_download[:recursive] = options[:recursive] if options[:recursive]
          casteml = Casteml.get(id, options_download)
          castemls << casteml
          # castemls = [casteml]
          # castemls.unshift joined if joined
          # joined = Casteml::Formats::XmlFormat.join_strings(castemls)
        end
        string = Casteml::Formats::XmlFormat.join_strings(castemls)

    	if options[:output_format]
	    	string = Casteml.encode(Casteml::Formats::XmlFormat.decode_string(string), options)
    	end
        output(string)
	end

end
