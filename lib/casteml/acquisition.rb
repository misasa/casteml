
require 'medusa_rest_client'
require 'casteml/stone'
require 'casteml/technique'
require 'casteml/device'
require 'casteml/abundance'
module Casteml
	class Acquisition
		extend Casteml::RemoteInteraction
		set_remote_class MedusaRestClient::Analysis
		attr_remote :name, :description, :operator, :stone_id, :device_id, :technique_id

		attr_accessor :uid, :session, :instrument, :analyst, :analysed_at, :sample_uid, :sample_name, :bibliography_uid, :description
		attr_accessor :technique
		attr_accessor :device

		alias_attribute :name, :session
		alias_attribute :operator, :analyst
		alias_attribute :global_id, :uid

		def spot
			@spot
		end

		def spot=(hash_or_obj)
			unless hash_or_obj.instance_of?(Spot)
				@spot = Spot.new(hash_or_object)
			else
				@spot = hash_or_object
			end
		end

		def abundances
			@abundances || []
		end

		def abundances=(array)
			@abundances = []
			array.each do |obj|
				unless obj.instance_of?(Abundance)
					obj = Abundance.new(obj)
				end
				@abundances << obj
			end
		end

		def stone_id
			if sample_uid
				obj = Stone.find_by_global_id(sample_uid)
				return obj.id if obj
			elsif sample_name
				obj = Stone.find_or_create_by_name(sample_name)
				return obj.id if obj
			end
			nil
		end

		def device_id
			return unless device
			obj = Device.find_or_create_by_name(device)
			return obj.id if obj
		end

		def technique_id
			return unless technique
			obj = Technique.find_or_create_by_name(technique)
			return obj.id if obj
		end

		# def to_remote_hash
		# 	hash = Hash.new
		# 	@@remote_attributes.each do |attrib|
		# 		hash[attrib] = self.send(attrib)
		# 	end
		# 	hash
		# end

		# def remote_obj
		# 	@remote_obj ||= get_remote_obj
		# end

		# def get_remote_obj
		# 	MedusaRestClient::Record.find(self.uid)
		# end



		def save_remote
			unless remote_obj.new?
				remote_obj.attributes.update(to_remote_hash)
			end
			#robj = self.class.remote_class.new(to_remote_hash)
       		if remote_obj.save
          		#self.uid = robj.global_id
          		save_abundances unless abundances.empty?
          		save_spot if spot
        	end

		end

		def save_spot
			return unless remote_obj
			spot.target_uid = remote_obj.global_id
			spot.save_remote
		end

		def save_abundances
			return unless remote_obj
			#return if remote_obj.new?
			existings = remote_obj.chemistries
			abundances.each do |ab|

				ab.analysis_id = remote_obj.id
				verbose "saving record for <#{ab.nickname}>..."
				if el = existings.find{|e| e.measurement_item_id == ab.measurement_item_id }
		#          begin
					el.update_attributes(ab.to_remote_hash)
				else
		  			el = ab.remote_obj
		  			el.save
		  		end
		#          rescue => ex
		#            p "saving record for <" + ab["nickname"]  + ">. "+ ex.to_s 
		#          end
			end
		end


	end
end
 