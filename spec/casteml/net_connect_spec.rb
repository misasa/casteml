require 'spec_helper'
require 'casteml/acquisition'

module Casteml
	@allow_net_connect = false
	if @allow_net_connect
		describe "with_net_connection" do
			describe Acquisition do
				describe "#save_remote" do
					subject{ acquisition.save_remote }
					let(:session){ 'session-deleteme' }
					let(:description){ 'this is a test' }
					let(:analyst){ 'Yusuke Yachi' }
					let(:attrib){ {:session => session, :description => description, :analyst => analyst } }
					let(:acquisition){ Acquisition.new(attrib) }
					context "without abundances and spot" do
						before do
							acquisition
						end
						it { expect{ subject }.not_to raise_error }
						after do
							acquisition.remote_obj.destroy
						end
					end

					context "with abundances" do
						let(:attrib){ {
							:session => session,
						 	:description => description, 
						 	:analyst => analyst,
						 	:abundances => [
						 		{:nickname => 'SiO2', :data => '12.5', :unit => 'cg/g'},
						 		{:nickname => 'Al2O3', :data => '1.5', :unit => 'cg/g'},
						 	] 
						 	} }
						 before do
						 	acquisition
						 end
						it { expect{ subject }.not_to raise_error }
						it { 
							subject
							expect( acquisition.remote_obj.chemistries.size).to be_eql(2)
						}
						after do
							acquisition.remote_obj.destroy
						end
					end

					context "with spot" do
						let(:session){ 'session-with-spot'}
						let(:image_uid){ '000-001' }
						#let(:image_path){ 'tmp/example.jpg'}
						let(:x_image){ '10.0' }
						let(:y_image){ '10.0' }
						let(:attachment_file){ MedusaRestClient::AttachmentFile.upload(image_path)}
						let(:image_path){ File.join('tmp', imagefile) }			
						let(:imagefile){ 'Dag340B1-Mg.jpg'}

						let(:attrib){ {
							:session => session,
						 	:description => description, 
						 	:analyst => analyst,
						 	:spot => {
						 		:image_uid => attachment_file.global_id,
						 		:x_image => x_image,
						 		:y_image => y_image
						 	}
						 	} }
						 before do
		 					setup_file(image_path)

						 end
						it { expect{ subject }.not_to raise_error }
						 after do
						 	acquisition.remote_obj.destroy
						 	attachment_file.destroy
						 end
					end
				end

			end
		end
	end
end