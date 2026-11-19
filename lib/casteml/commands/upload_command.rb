require 'casteml/command'
class Casteml::Commands::UploadCommand < Casteml::Command
	def initialize
		super 'upload', '    Upload a dataset to Medusa' # Summary:
	end

	def usage
		"#{program_name} PMLFILE"
	end

	def arguments
	<<-EOS
    PMLFILE    PML file containing the acquisitions to upload
EOS
	end

	def description
	<<-EOF
    Save the analyses and their measurements to Medusa. See
    casteml convert --help for supported input formats. Specify the
    associated stone in the input dataset.

    If an analysis includes a spot, describe its reference image in
    the input file. The image center is the origin, and coordinates
    are normalized so the longest side spans -50 to 50. The MATLAB
    script spots.m can create input files with spot coordinates.

    An image can be referenced by its Medusa ID or by a local path.
    A matching .geo file can supply the affine transformation to
    stage coordinates when the client uploads the image.

    $ cat my-spots-picture.geo
    affine_xy2vs:
    - [1.2, 0.0,  4.2]
    - [0.0, 1.2, -1.3]
    - [  0,   0,  1.0]
EOF
	end

	def example
	<<-EOS
    $ casteml join JB1.pml stone2.pml JB3.pml > session.pml
    $ casteml upload session.pml

    matlab>> spots
    ...
    $ ls
    my-spots-picture.jpg  my-spots-picture.pml
    $ casteml upload my-spots-picture.pml
EOS
	end

	def see_also
	<<-EOS
    orochi-upload
    casteml convert --help
    casteml join
    spots.m
    https://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/upload_command.rb
EOS
	end

	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify PMLFILE') if args.empty?

    	pml_path = args.shift
    	data = Casteml.decode_file(pml_path)
    	Casteml.save_remote(data)
	end
end
