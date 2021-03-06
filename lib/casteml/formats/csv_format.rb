require 'csv'
require 'stringio'
require 'tempfile'
require 'casteml/acquisition'
require 'casteml/number_helper'
class CSV::Row
	alias to_hash_org to_hash
	def to_hash
		hash = to_hash_org
		hash_new = Hash.new
		hash.each do |key, value|
			next unless key

			setter = (key.gsub(/-/,"_") + "=").to_sym
			if Casteml::Acquisition.instance_methods.include?(setter)
				hash_new[key] = value
				next
			end

			if key =~ /spot_(.*)/
				method_name = $1
				hash_new[:spot] = Hash.new unless hash_new[:spot]
				hash_new[:spot][method_name.to_sym] = value
				next
			end

			if key =~ /(.*)\_error/
				nickname = $1
				abundance = hash_new[:abundances].find{|abundance| abundance[:nickname] == nickname } if hash_new[:abundances]
				abundance[:error] = value if abundance
				next
			end

			abundance = Hash.new
			if key =~ /(.*) \((.*)\)/
				abundance[:nickname] = $1
				abundance[:unit] = $2
			else
				abundance[:nickname] = key.strip
			end
			abundance[:data] = value
			hash_new[:abundances] ||= []
			hash_new[:abundances] << abundance
		end
		hash_new
	end

	def valid?
		flag = !self["session"].nil? || !self["name"].nil?
		flag
	end

	def unit_row?
		self[0] =~ /unit/i || ( self["session"].nil? && self["name"].nil? )
	end
end

module Casteml::Formats
	class CsvFormat
		extend Casteml::NumberHelper

		def self.default_units
			{:unit => 'parts', :centi => '%', :mili => 'permil', :micro => 'ppm', :nano => 'ppb'}			
		end

		def self.unit_from_numbers(numbers)
			number = numbers.compact.min
			unit = number_to_unit(number, :units => default_units ) if number
		end

		def self.nicknames_from_array_of_abundances(array_of_abundances)
			array_of_nicknames = array_of_abundances.compact.map{|abundances| abundances.map{|abundance| abundance.nickname }}
			nicknames = array_of_nicknames.flatten.uniq			
		end

		def self.to_string(hashs, opts = {})
			array_of_abundances = []
			array_of_spot = []
			array_of_place = []

			hashs.each do |h|
				spot_attrib = h.delete(:spot)
				place_attrib = h.delete(:place)
				abundances = h.delete(:abundances)
				array_of_spot << ( spot_attrib ? spot_attrib : nil )
				array_of_place << ( place_attrib ? place_attrib : nil )
				array_of_abundances << ( abundances ? abundances.map{|ab| Casteml::Abundance.new(ab) } : nil )
			end

			csv_opts = {}
			csv_opts[:col_sep] = opts.delete(:col_sep) || ","

			#with_error = opts.delete(:with_error)
			without_error = opts.delete(:without_error)
			with_unit = opts.delete(:with_unit)
			unit_separate = opts.delete(:unit_separate)
			without_spot = opts.delete(:without_spot)
			with_place = opts.delete(:with_place) || false
			without_place = with_place ? false : true
			with_nicknames = opts.delete(:with_nicknames)
			omit_null = opts.delete(:omit_null)
			omit_description = opts.delete(:omit_description)

			if omit_description
				hashs.each do |hash|
					hash.delete(:description)
				end
			end
			#array_of_spot.compact!
			#array_of_abundances.compact!
			if with_nicknames
				nicknames = with_nicknames
			else
				nicknames = nicknames_from_array_of_abundances(array_of_abundances)
				# array_of_nicknames = array_of_abundances.compact.map{|abundances| abundances.map{|abundance| abundance.nickname }}
				# nicknames = array_of_nicknames.flatten.uniq
			end

			array_of_numbers = []
			array_of_error_numbers = []
			array_of_abundances.each do |abundances|
				numbers = Array.new(nicknames.size, nil)
				error_numbers = Array.new(nicknames.size, nil)
				if abundances
					abundances.each do |ab|
						idx = nicknames.index{|elem| elem == ab.nickname}
						if idx
							numbers[idx] = ab.data_in_parts
							error_numbers[idx] = ab.error_in_parts
						end
					end
				end
				array_of_numbers << numbers
				array_of_error_numbers << error_numbers
			end

			array_of_units = []
			array_of_numbers.transpose.each do |numbers|
				unit = with_unit ? with_unit : unit_from_numbers(numbers)
				# number = numbers.compact.min
				# unit = number_to_unit(number, :units => default_units ) if number
				array_of_units << unit
			end


			array_of_data = []
			array_of_abundances.each_with_index do |abundances, i|
				#data = Array.new(nicknames.size, [nil, nil])
				values = Array.new(nicknames.size, nil)
				errors = Array.new(nicknames.size, nil)
				if abundances
					abundances.each_with_index do |ab, j|
						idx = nicknames.index{|elem| elem == ab.nickname}
						if idx
							unit = array_of_units[idx]
							number = array_of_numbers[i][idx]
							error_number = array_of_error_numbers[i][idx]
							values[idx] = (number ? number_to(number, unit) : nil)
							errors[idx] = (error_number ? number_to(error_number, unit) : nil)
						end
					end
				end
				if without_error
					data = values
				else
					data = values.zip(errors)
				end
				array_of_data << data
			end

			spot_keys = array_of_spot.compact.map{|spot| spot.keys }.flatten.uniq
			spot_methods = spot_keys.map{|m| "spot_#{m}"}
			array_of_spot_data = []
			array_of_spot.each do |spot|
				data = Array.new(spot_keys.size, nil)
				if spot
					spot_keys.each_with_index do |key, idx|
						data[idx] = spot[key]
					end
				end
				array_of_spot_data << data
			end

			place_keys = array_of_place.compact.map{|place| place.keys }.flatten.uniq
			place_methods = place_keys.map{|m| "place_#{m}"}
			array_of_place_data = []
			array_of_place.each do |place|
				data = Array.new(place_keys.size, nil)
				if place
					place_keys.each_with_index do |key, idx|
						data[idx] = place[key]
					end
				end
				array_of_place_data << data
			end

			if omit_null
				omit_ids = []
				array_of_data.each_with_index do |data, idx|
					omit_ids << idx if data.flatten.none?
				end
			end

			attrib_keys = []
			#column_names = hashs.first.keys
			hashs.each do |hash|
				attrib_keys.concat(hash.keys)
				attrib_keys.uniq!
			end

			column_names = attrib_keys.dup
			column_names.concat(spot_methods) unless without_spot
			column_names.concat(place_methods) unless without_place
			if unit_separate
				unit_names = hashs.first.keys.map{|key| ""}
				unit_names.concat(spot_methods.map{|sp| ""}) unless without_spot
				unit_names.concat(place_methods.map{|sp| ""}) unless without_place
			end
#			nicknames_with_unit = []
			nicknames.each_with_index do |nickname, idx|
				unit = array_of_units[idx]
				if unit_separate
					column_names << nickname
					unit_names << ( ( unit && unit != 'parts' ) ? "#{unit}" : "")
					unless without_error
						column_names << "#{nickname}_error"
						unit_names << ""
					end	
				else
					column_names << ( ( unit && unit != 'parts' ) ? "#{nickname} (#{unit})" : nickname)
					unless without_error
						column_names << "#{nickname}_error"
					end
				end
			end
			#column_names.concat(nicknames_with_unit.flatten)

			# if unit_separate
			# 	unit_names = hashs.first.keys.map{|key| ""}
			# 	unit_names.concat(spot_methods.map{|sp| ""}) unless without_spot
			# 	unit_names.concat(array_of_units)
			# end
			string = CSV.generate("", csv_opts) do |csv|
				csv << column_names
				csv << unit_names if unit_separate
				hashs.each_with_index do |h, idx|
				  next if omit_null && omit_ids.include?(idx)
#					row = h.values
					row = attrib_keys.map{|key| h.has_key?(key) ? h[key]: nil }
					row.concat(array_of_spot_data[idx]) unless without_spot
					row.concat(array_of_place_data[idx]) unless without_place
					row.concat(array_of_data[idx].flatten)
					csv << row
				end
			end
			if opts[:transpose]
				string = transpose(string, csv_opts)
			end
			string
		end

		def self.decode_file(path, opts ={})
			string = File.open(path).read
			decode_string(string, opts)
		end

		def self.tab_separated?(string)
			string =~ /\t/
		end

		def self.tsv2csv(string)
		  string.gsub(/\t/,',')
          vals = string.split(/\t/)
          vals.map{|val| val =~ /\,/ ? "\"#{val}\"" : val}.join(',')
		end

		def self.org_mode?(string)
          string = string.gsub(/\r+\n/, "\n")
          string =~ /^\|.*\|$/
		end

		def self.org2csv(string)
			string.gsub!(/^#\+TBLNAME:.*\n/,"")
			string.gsub!(/^\+TBLNAME:.*\n/,"")
			string.gsub!(/^\|\-.*\|\n/,"")
			string.gsub!(/^\|\-.*\n/,"")
			string.gsub!(/^\|\s*/,"")
			string.gsub!(/\s*\|$/,"")
			string.gsub!(/\|\Z/,"")
            lines = string.split(/\n/)
            rlines = []
            lines.each do |line|
              vals = line.split(/\s*\|\s*/)
              rlines << vals.map{|val| val =~ /\,/ ? "\"#{val}\"" : val}.join(',')
            end
            string = rlines.join("\n")
            string
		end


		def self.column_wise?(string)
			csv = CSV.new(string)
			array_of_arrays = csv.to_a
			first_row = array_of_arrays[0].clone
			first_column = array_of_arrays.map{|array| array[0]}
			to_method_array(first_column).size > to_method_array(first_row).size
		end

		def self.to_method_array(array)
			acq_methods = Casteml::Acquisition.instance_methods
			array.compact.map{|item| item.gsub(/-/,'_').to_sym }.map{|item| acq_methods.include?(item) ? item : nil }.compact
		end

		def self.transpose(string, opts = {})
			csv = CSV.new(string, opts)
			array_of_arrays = csv.to_a
			max_items = array_of_arrays.map{|array| array.size }.max
			unless array_of_arrays.all?{|array| array.size == max_items }
				array_of_arrays.each do |array|
					if array.size < max_items
						array[max_items - 1] = nil
					end
				end
			end
			csv_string = CSV.generate("", opts) do |csv|
				array_of_arrays.transpose.each do |array|
					csv << array
				end
			end
			csv_string
		end

		def self.decode_string(string, opts = {})
			raise "empty csv!" if string.empty?
			string = string.gsub(/\r+\n/, "\r\n")
			if org_mode?(string)
				string = org2csv(string)
			elsif tab_separated?(string)
				string = tsv2csv(string)
			end
			string = transpose(string) if column_wise?(string)
			sio = StringIO.new(string,"r")
			strip_filter = Proc.new do |v|
				begin
					v.strip
				rescue
					v
				end
			end
			csv = CSV.new(sio, {
				:headers => true, 
				:header_converters => strip_filter,
				:converters => strip_filter
				})
			rows = []
			csv.each do |row|
				if csv.lineno == 2 && row.unit_row?	
					row.each_with_index do |a, index|
						if a[1] && index != 0
							csv.headers[index] += " (#{a[1]})"
						end
					end
					next
				else
					raise "invalid row(#{csv.lineno}) #{row.to_s}" unless row.valid?
					rows << row.to_hash
				end
			end
			rows
		end

		def self.to_attrib

		end
	end	
end
