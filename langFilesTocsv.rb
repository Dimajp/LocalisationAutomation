#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'
require 'csv'

BASE_DIR = "CurrentLocalization"
OUTPUT_FOLDER = "Generated"
OUTPUT_FILE = OUTPUT_FOLDER + "/" + "localization.csv"

USAGE = <<END
Convert Localizable.strings files to translations.csv
Usage: put related *.lproj folders with Localizable.strings files to 'CurrentLocalization' folder
perform 'ruby langFiles2csv.rb'
check results in "Generated" folder
END

# ----------------------------
# Parse .strings file (fully robust)
# ----------------------------
def parse_strings_file(path)
	data = {}
	current_section = nil
	buffer = ""
	inside_string = false
	
	File.readlines(path, encoding: "UTF-8").each do |line|
		line.strip!
		
		# Section start
		if line.start_with?("//---")
			current_section = line.gsub("//---", "").strip
			data["##{current_section}"] = nil
			next
		end
		
		# Ignore comments and empty lines
		next if line.start_with?("//")
		next if line.empty?
		
		if inside_string
			buffer += "\n" + line
			# Check if this line ends the string
			if buffer =~ /";\s*$/
				inside_string = false
			else
				next
			end
		else
			buffer = line
			inside_string = !(buffer =~ /";\s*$/)  # continue accumulating if multiline
			next if inside_string
		end
		
		# Now buffer contains full key=value pair
		if buffer =~ /^"((?:\\.|[^"\\])*)"\s*=\s*"((?:\\.|[^"\\])*)";\s*$/
			key = Regexp.last_match(1)
			val = Regexp.last_match(2)
			
			# Unescape sequences
			key = key.gsub(/\\n/, "\n").gsub(/\\t/, "\t").gsub(/\\"/, '"')
			val = val.gsub(/\\n/, "\n").gsub(/\\t/, "\t").gsub(/\\"/, '"')
			
			data[key] = val
		else
			puts "Warning: Could not parse key/value: #{buffer.strip}"
		end
		
		buffer = ""  # reset buffer
	end
	
	data
end

# ----------------------------
# Find languages
# ----------------------------
def find_languages
	langs = []
	
	Dir.entries(BASE_DIR).each do |dir|
		if dir.end_with?(".lproj")
			langs << dir.gsub(".lproj", "")
		end
	end
	
	langs.sort
end

# ----------------------------
# Main
# ----------------------------

languages = find_languages

if languages.empty?
	abort "No .lproj folders found in #{BASE_DIR}"
end

puts "Found languages: #{languages.join(', ')}"

translations = {}
all_keys = []

# ----------------------------
# Read all .strings files
# ----------------------------
languages.each do |lang|
	
	file = "#{BASE_DIR}/#{lang}.lproj/Localizable.strings"
	
	unless File.exist?(file)
		puts "Skipping missing: #{file}"
		next
	end
	
	puts "Reading: #{file}"
	
	parsed = parse_strings_file(file)
	
	parsed.each do |key, val|
		
		# Section header
		if key.start_with?("#")
			all_keys << key unless all_keys.include?(key)
			next
		end
		
		all_keys << key unless all_keys.include?(key)
		
		translations[key] ||= {}
		translations[key][lang] = val
	end
end

# ----------------------------
# Write CSV
# ----------------------------

FileUtils.mkdir_p(OUTPUT_FOLDER)  # creates 'Generated' folder if it doesn't exist

CSV.open(OUTPUT_FILE, "w", encoding: "UTF-8") do |csv|
	
	# Header
	csv << ["KEY"] + languages
	
	all_keys.each do |key|
		
		# Section row
		if key.start_with?("#")
			csv << [key]  # section headers remain unquoted
			next
		end
		
		row = []
		row << key  # keys remain unquoted
		
		languages.each do |lang|
			value = translations.dig(key, lang)
			# Only quote non-empty values, leave empty cells blank
			if value.nil? || value.empty?
				row << ""
			else
				row << '"' + value + '"'
			end
		end
		
		csv << row
	end
end

puts "CSV file created: #{OUTPUT_FILE}"

