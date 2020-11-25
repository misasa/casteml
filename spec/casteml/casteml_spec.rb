require 'spec_helper'
require 'casteml'
module Casteml
	describe ".convert_file" do

		describe "to pml" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/medusa9-test.csv'}
			let(:opts){ {:output_format => :pml } }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				puts subject
			end
			it {
				expect(subject).to match(/acquisitions/)
				expect(subject).to match(/<session>/)
				expect(subject).to match(/abundances/)
				expect(subject).to match(/abundance/)
			}
			context "with version 9" do
				let(:opts){ {:output_format => :pml, :version => '9' } }
				before do
#					puts subject
				end
				it {
					expect(subject).to match(/acquisitions/)
					expect(subject).to match(/<name>/)
					expect(subject).to match(/chemistries/)
					expect(subject).to match(/analysis/)
				}				
			end
		end

		describe "with with_unit" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/20130528105345-976071-in.csv'}
			let(:opts){ {:output_format => :csv, :with_unit => unit } }
			let(:data){ double('data').as_null_object }
			before do
				allow(Casteml).to receive(:decode_file).with(path).and_return(data)
			end
			context "specify %" do
				let(:unit){ '%' }
				it {
					expect(Casteml).to receive(:encode).with(data, {:output_format => :csv, :with_unit => '%', :without_error => false})
					subject
				}
			end
			context "specify false" do
				let(:unit){ false }
				it {
					expect(Casteml).to receive(:encode).with(data, {:output_format => :csv, :with_unit => 'parts', :without_error => false})
					subject
				}
			end

		end

		context "with average and output csv" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/20130528105345-976071-in.csv'}
			let(:opts){ {:output_format => :csv, :with_average => true } }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).to match(/CBK/)				
			}
			it {
				expect(subject).to match(/average/)
			}
		end

		context "with smash and output csv" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/20130528105345-976071-in.csv'}
			let(:opts){ {:output_format => :csv, :smash => true } }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).not_to match(/CBK/)
			}
			it {
				expect(subject).to match(/average/)
			}
		end

        context "with smash and output csv" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/20100310092554376.stokeshi.pml'}
			let(:opts){ {:output_format => :csv, :smash => true } }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).not_to match(/CBK/)
			}
			it {
				expect(subject).to match(/average/)
			}
		end

		context "with place and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/place.pml' }
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:with_place => true, :output_format => :dataframe } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).to match(/longitude/)
			}			
		end

		context "without place and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/place.pml' }
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:output_format => :dataframe } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).not_to match(/longitude/)
			}			
		end

		context "output dflame", :current => true do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/place.pml' }
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			#let(:path){ 'tmp/chunk_cbk1b.pml' }
			let(:opts){ {:output_format => :dflame } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).to match(/_error/)
			}			
		end

		context "without error and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/place.pml' }
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:without_error => true, :output_format => :dataframe } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).not_to match(/_error/)
			}			
		end


		context "with category and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
			let(:path){ 'tmp/20110518194205-602-801.pml' }
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:with_category => category, :output_format => :dataframe } }
			let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).to match(/d18O/)
				expect(subject).to match(/d18O_error/)				
			}
			#expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => 'isotope (delta)'})
		end


		context "with vs_coordinate and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
			#let(:path){ 'tmp/20160820170853-707954.pml' }
			let(:path){ 'tmp/20160819165624-372633.pml'}
#			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:with_category => category, :output_format => :dataframe } }
			let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				#puts subject
			end
			it {
				expect(subject).to match(/^x_vs/)
				expect(subject).to match(/^y_vs/)
				expect(subject).to match(/^sample_id/)
				#expect(subject).to match(/^analysis_id/)
				expect(subject).to match(/^image_id/)
				expect(subject).to match(/^image_path/)
				expect(subject).not_to match(/^spot_attachment_file_path/)				
				expect(subject).to match(/d18O/)
			}
			#expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => 'isotope (delta)'})
		end
		context "without category and output dataframe" do
			subject { Casteml.convert_file(path, opts)}
#			let(:path){ 'tmp/20110203165130-611-312.pml' }
			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:output_format => :dataframe } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				#puts subject
			end
			it {
				expect(subject).to match(/element,unit/)
				expect(subject).to match(/Ni,ppm/)
			}
			#expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => 'isotope (delta)'})
		end


		context "with unit_separate and output csv" do
			subject { Casteml.convert_file(path, opts)}
#			let(:path){ 'tmp/20110203165130-611-312.pml' }
			let(:path){ 'tmp/20100310092554376.stokeshi.pml' }
			let(:opts){ {:output_format => :csv, :unit_separate => true } }
			#let(:category){ "oxygen" }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			#	puts subject
			end
			it {
				expect(subject).to match(/ppm\,""/)
			}
			#expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => 'isotope (delta)'})
		end
		context "with csvfile" do
			let(:path){'tmp/mytable.csv'}
			let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }

			it {
				expect(Casteml::Formats::CsvFormat).to receive(:decode_file).with(path).and_return(data)
				Casteml.convert_file(path)
			}
		end


        context "with bug-1217.pml" do
          subject { Casteml.convert_file(path, {:output_format => format}) }
		  let(:path){'tmp/bug-1217.pml'}
		  before do
			setup_empty_dir('tmp')
			setup_file(path)
		  end
          
          context "to csv" do
            let(:format){ :csv }
		    it {
			  expect(subject).to match(/\"Run#1908\, 1.93mg\, Leached with 0.6M HCl for 2 min.\"/)
		    }
          end
          context "to tsv" do
            let(:format){ :tsv }
		    it {
			  expect(subject).to match(/\tRun#1908\, 1.93mg\, Leached with 0.6M HCl for 2 min.\t/)
		    }
          end
          
        end
		context "with isorgfile" do
			subject { Casteml.convert_file(path) }
			let(:path){'tmp/template.isorg'}
			#let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				subject
			}
		end

		context "with real org" do
			subject { Casteml.convert_file(path, :output_format => output_format)}
			let(:output_path){ File.join(File.dirname(path), File.basename(path, ".*") + ".#{output_format}") }
			let(:output_format){ :csv }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				File.open(output_path, "w") do |out|
					out.puts subject
				end
			end
			context "mydata@1.org" do
				let(:path){'tmp/ys_pl_bytownite_c.org'}
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end
			context "mydata@1.isorg" do
				let(:path){'tmp/ys_pl_bytownite_c.isorg'}
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end

		end

		context "with to_int_ok10cb@1.pml" do
			subject { Casteml.convert_file(path) }
			let(:path) { 'spec/fixtures/files/to_int_ok10cb@1.pml'}
			it {
				expect(File.exist?(path)).to be_truthy
				expect(subject).to be_an_instance_of(String)
			}
		end

		context "with cbk1.pml" do
			subject { Casteml.convert_file(path) }
			let(:path) { 'spec/fixtures/files/cbk1.pml'}
			it {
				expect(File.exist?(path)).to be_truthy
				expect(subject).to be_an_instance_of(String)
			}
		end

		context "with reald file to output_format isorg" do
			subject { Casteml.convert_file(path, :output_format => output_format)}
			let(:path){'tmp/20130528105235-594267-R.pml'}
			let(:output_format){ :isorg }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end

			it {
				expect(subject).to match(/^#\+TBLNAME/)
			}
		end

		context "with real file to output_format dataframe" do
			subject { Casteml.convert_file(path, :output_format => output_format, :with_category => category)}
			let(:output_path){ File.join(File.dirname(path), File.basename(path, ".*") + ".#{output_format}") }
			let(:output_format){ :dataframe }
            let(:category){'trace'}
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				File.open(output_path, "w") do |out|
					out.puts subject
				end
			end
			context "data-from-casteml.csv" do
			  let(:path){'tmp/20130528105235-594267-R.pml'}
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end
            context "bug-1217.pml" do
              let(:path){'tmp/bug-1217.pml'}
              let(:category){'oxygen'}
		      it {
                expect(subject).to match(/d17O\,permil\,1.805/)
			  }
            end
            context "bug-1217.org" do
              let(:path){'tmp/bug-1217.org'}
              let(:category){'oxygen'}
		      it {
                expect(subject).to match(/d17O\,permil\,1.805/)
			  }
            end
            context "bug-1217.tsv" do
              let(:path){'tmp/bug-1217.tsv'}
              let(:category){'oxygen'}
		      it {
                expect(subject).to match(/d17O\,permil\,1.805/)
			  }
            end
            context "bug-1217.csv" do
              let(:path){'tmp/bug-1217.csv'}
              let(:category){'oxygen'}
		      it {
                expect(subject).to match(/d17O\,permil\,1.805/)
			  }
            end

			context "image.pml" do
				let(:path){'tmp/image.pml'}
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end

		end

		context "with real file to output_format csv" do
			subject { Casteml.convert_file(path, :output_format => output_format)}
			let(:output_path){ File.join(File.dirname(path), File.basename(path, ".*") + ".#{output_format}") }
			let(:output_format){ :csv }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
				File.open(output_path, "w") do |out|
					out.puts subject
				end
			end
			context "mydata@1.pml" do
				let(:path){'tmp/mydata@1.pml'}
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end
			context "20110518194205-602-801.pml" do
				let(:path){'tmp/20110518194205-602-801.pml'}
				let(:from_original){ Casteml.decode_file(path).map{|attrib| Casteml::Acquisition.new(attrib) } }
				let(:from_converted){ Casteml.decode_file(output_path).map{|attrib| Casteml::Acquisition.new(attrib) } }
				it {
					expect(subject).to be_an_instance_of(String)
				}
				it {
					expect(from_original[0].name).to be_eql(from_converted[0].name)
				}
				it {
					expect(from_original[0].abundances[0].data_in_parts).to be_eql(from_converted[0].abundances[0].data_in_parts)
				}

				it {
					expect(from_converted).to all(be_an_instance_of(Casteml::Acquisition))
				}
				it {
					from_original.each_with_index do |original, idx|
						expect(original.name).to be_eql(from_converted[idx].name)
						original.abundances.each do |ab|
							nickname = ab.nickname
							expect(ab.data_in_parts).to be_eql(from_converted[idx].abundance_of(nickname).data_in_parts)
							expect(ab.error_in_parts).to be_eql(from_converted[idx].abundance_of(nickname).error_in_parts)							
						end
					end
					#expect(from_original.map{|acq| acq.abundances })
				}
				it {
					expect(from_original[0].abundance_of("MgO").data_in_parts).to be_eql(from_converted[0].abundance_of("MgO").data_in_parts)
				}
				it {
					expect(from_original[0].abundance_of("MgO").error_in_parts).to be_eql(from_converted[0].abundance_of("MgO").error_in_parts)
				}

			end

		end


	end

	describe ".is_file_type?" do
		subject{ Casteml.is_file_type?(path, type)}
		let(:path){ 'tmp/example.pml' }
		context "with same ext" do
			let(:type){ :pml }
			it { expect(subject).to be_truthy }
		end

	end

	describe ".is_pml?" do
		context "with pml" do
			subject{ Casteml.is_pml?(path) }
			let(:path){ 'tmp/example.pml' }
			it {
				expect(subject).to be_truthy
			}
		end

		context "with csv" do
			subject{ Casteml.is_pml?(path) }
			let(:path){ 'tmp/example.csv' }
			it {
				expect(subject).to be_falsey
			}
		end

	end

	describe ".average" do
		subject { Casteml.average(data, opts) }
		let(:opts) { {} }
		let(:data){
			[
				{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '12.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '1.345', :unit => 'ug/g'}]},
				{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '14.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '0.00000001245', :unit => 'cg/g'}]},						
				{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.15345'},{:nickname => 'Li', :data => '1.145', :unit => 'ug/g'}]},
			]
		}
		it {
			expect(subject).to include(:session => "average")
			expect(subject[:abundances][0]).to include(:nickname => "SiO2")
			expect(subject[:abundances][1]).to include(:nickname => "Li")
		}
		context "with real data" do
			let(:path){ 'tmp/20130528105345-976071-in.csv'}
			let(:data){ Casteml.decode_file(path)}
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end
			it {
				expect(subject).to include(:session => "average")
				expect(subject[:abundances][0]).to include(:nickname => "SiO2")
				expect(subject[:abundances][1]).to include(:nickname => "Li")
			}
		end

        context "with single data" do
			let(:path){ 'tmp/20130528105345-976071-in.csv'}
            let(:data){
			[
				{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '12.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '1.345', :unit => 'ug/g'}]},
				{:session => 1, :abundances => [{:nickname => 'Li', :data => '0.00000001245', :unit => 'cg/g'}]},						
			]
		    }

			it {
				expect(subject).to include(:session => "average")
				expect(subject[:abundances][0]).to include(:nickname => "SiO2")
				expect(subject[:abundances][1]).to include(:nickname => "Li")
			}
		end


    end

	describe ".encode" do
		subject { Casteml.encode(data, opts) }
		let(:opts){ {} }
		let(:data){ [{:session => 'session-1',:sample_name => 'stone-1'},{:session => 'session-2',:sample_name => 'stone-2'}] }
		context "without opts" do
			it {
				expect(Formats::XmlFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data)
			}
		end

		context "with -t" do
			let(:opts){ {:output_format => format, :transpose => false }}
			let(:format){ :csv }
			it {
				expect(Formats::CsvFormat).to receive(:to_string).with(data, opts)
				subject
			}
		end

		context "with average" do
			let(:opts){ {:output_format => format, :with_average => true }}			
			let(:format){ :csv }
			it {
				expect(Casteml).to receive(:average).with(data).and_return({:session => 'average'})
				expect(Formats::CsvFormat).to receive(:to_string).with(data, opts)
				subject
			}
		end

		context "with smash" do
			let(:opts){ {:output_format => format, :smash => true }}			
			let(:format){ :csv }
			it {
				expect(Casteml).to receive(:average).with(data).and_return({:session => 'average'})
				expect(Formats::CsvFormat).to receive(:to_string).with([{:session => 'average'}], opts)
				subject
			}
		end

		context "with output_format = :csv" do
			let(:opts){ {:output_format => format }}
			let(:format){ :csv }
			it {
				expect(Formats::CsvFormat).to receive(:to_string).with(data, {})
				subject
			}
		end

		context "with output_format = :tex" do
			let(:opts){ {:output_format => :tex}}
			it {
				expect(Formats::TexFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data, opts)
			}
		end

		context "with output_format = :org" do
			let(:opts){ {:output_format => :org}}
			it {
				#expect(Formats::CsvFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data, opts)
			}
		end

		context "with output_format = :isorg" do
			let(:opts){ {:output_format => :isorg}}
			it {
				#expect(Formats::CsvFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data, opts)
			}
		end

		context "with output_format = :pdf" do
			let(:opts){ {:output_format => :pdf}}
			before do
				allow(Casteml).to receive(:compile_tex)
			end
			it {
				expect(Formats::TexFormat).to receive(:to_string).with(data, {}).and_return("Hello World")
				Casteml.encode(data, opts)
			}
		end


	end

	describe ".decode_file" do

		context "with realfile" do
			subject { Casteml.decode_file(path) }
			let(:path){ 'tmp/mydata@1.pml' }
			before do
				setup_empty_dir('tmp')
				setup_file(path)
			end

			it {
				expect(subject).to be_an_instance_of(Array)
			}
		end
		context "with pmlfile" do
			let(:path){'tmp/my-great.pml'}
			it {
				expect(Casteml::Formats::XmlFormat).to receive(:decode_file).with(path)
				Casteml.decode_file(path)
			}
		end

		context "with csvfile" do
			let(:path){'tmp/my-great.csv'}
			it {
				expect(Casteml::Formats::CsvFormat).to receive(:decode_file).with(path)
				Casteml.decode_file(path)
			}
		end

	end

	describe ".get" do
		subject { Casteml.get(id, opts) }
		let(:id) { '0000-001' }
		let(:pml) { File.read("spec/fixtures/files/my-great.pml") }
		let(:opts){ {} }
		before do

			allow(MedusaRestClient::Record).to receive(:download_one).and_return(pml)
		end
		it {
			expect(MedusaRestClient::Record).to receive(:download_one).with({:from => "#{MedusaRestClient::Record.prefix}records/#{id}.pml", :params => {}}).and_return(pml)
			subject
		}
		it {
			expect(subject).to be_eql(pml)
		}
		context "with options {:recursive => :descendants}" do
			let(:opts) { {:recursive => :descendants} }
			it {
				expect(MedusaRestClient::Record).to receive(:download_one).with({:from => "#{MedusaRestClient::Record.prefix}records/#{id}/descendants.pml", :params => {}}).and_return(pml)
				subject
			}

		end
		context "with options {:recursive => :families}" do
			let(:opts) { {:recursive => :families} }
			it {
				expect(MedusaRestClient::Record).to receive(:download_one).with({:from => "#{MedusaRestClient::Record.prefix}records/#{id}/families.pml", :params => {}}).and_return(pml)
				subject
			}
		end

	end

	describe ".download" do
		subject { Casteml.download(id, opts) }
		let(:id) { '0000-001' }
		let(:pml) { File.read("spec/fixtures/files/my-great.pml") }
		let(:opts){ {} }
		before do
			allow(Casteml).to receive(:get).with(id, opts).and_return(pml)
		end
		it {
			expect(Casteml).to receive(:get).with(id, opts).and_return(pml)
			subject
		}
		it {
			expect(File.exists?(subject)).to be_truthy
		}
		it {
			expect(File.read(subject)).to be_eql(pml)
		}
	end

	describe ".save_remote" do
		let(:hash_1){ {:session => 'deleteme-1'} }
		let(:hash_2){ {:session => 'deleteme-2'} }
		let(:instance_1){ double('instance-1').as_null_object }
		let(:instance_2){ double('instance-2').as_null_object }

		before do
			allow(Acquisition).to receive(:new).with(hash_1).and_return(instance_1)
			allow(Acquisition).to receive(:new).with(hash_2).and_return(instance_2)	
		end

		context "with array_of_hash" do
			let(:data){ [hash_1, hash_2] }	

			it {
				expect(Acquisition).to receive(:new).twice
				expect(instance_1).to receive(:save_remote)
				expect(instance_2).to receive(:save_remote)				
				Casteml.save_remote(data)
			}


		end

		context "with hash" do
			let(:data){ hash_1 }	

			it {
				expect(Acquisition).to receive(:new).once
				expect(instance_1).to receive(:save_remote)
				Casteml.save_remote(data)
			}
		end

	end
end
