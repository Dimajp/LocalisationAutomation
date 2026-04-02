#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'

ORIGINAL_DIR   = "CurrentLocalization"
GENERATED_DIR  = "Generated/Localization"
OUTPUT_FOLDER = "Generated"
DIFF_FILE      = "#{OUTPUT_FOLDER}/localization_diff.txt"


# ----------------------------
# Parse .strings file
# ----------------------------
def parse_strings(path)
	
	data = {}
	
	return data unless File.exist?(path)
	
	File.readlines(path, encoding: "UTF-8").each do |line|
		
		line.strip!
		
		next if line.empty?
		next if line.start_with?("//")
		
		# "KEY" = "VALUE";
		if line =~ /^"(.*)"\s*=\s*"(.*)";$/
			key = Regexp.last_match(1)
			val = Regexp.last_match(2)
			
			data[key] = val
		end
	end
	
	data
end


# ----------------------------
# Find languages
# ----------------------------
def find_languages(dir)
	
	langs = []
	
	return langs unless Dir.exist?(dir)
	
	Dir.entries(dir).each do |d|
		if d.end_with?(".lproj")
			langs << d.gsub(".lproj", "")
		end
	end
	
	langs.sort
end


# ----------------------------
# Main
# ----------------------------

orig_langs = find_languages(ORIGINAL_DIR)
gen_langs  = find_languages(GENERATED_DIR)

all_langs = (orig_langs + gen_langs).uniq.sort


if all_langs.empty?
	abort "No localization folders found"
end


FileUtils.mkdir_p(OUTPUT_FOLDER)

diffs = []

diffs << "Localization Diff Report"
diffs << "========================"
diffs << "Generated at: #{Time.now}"
diffs << ""


# ----------------------------
# Compare each language
# ----------------------------

all_langs.each do |lang|
	
	diffs << "Language: #{lang}"
	diffs << "-" * 40
	
	orig_file = "#{ORIGINAL_DIR}/#{lang}.lproj/Localizable.strings"
	gen_file  = "#{GENERATED_DIR}/#{lang}.lproj/Localizable.strings"
	
	unless File.exist?(orig_file)
		diffs << "  ❗ Missing original file - #{orig_file}"
		diffs << ""
		next
	end
	
	unless File.exist?(gen_file)
		diffs << "  ❗ Missing generated file  - #{gen_file}"
		diffs << ""
		next
	end
	
	
	orig_data = parse_strings(orig_file)
	gen_data  = parse_strings(gen_file)
	
	all_keys = (orig_data.keys + gen_data.keys).uniq.sort
	
	has_diff = false
	
	
	all_keys.each do |key|
		
		o = orig_data[key]
		g = gen_data[key]
		
		# Missing in generated
		if o && !g
			diffs << "  [-] Removed: #{key}"
			diffs << "      Original: #{o}"
			has_diff = true
			
			# New in generated
		elsif !o && g
			diffs << "  [+] Added:   #{key}"
			diffs << "      New: #{g}"
			has_diff = true
			
			# Changed
		elsif o != g
			diffs << "  [*] Changed: #{key}"
			diffs << "      Original: #{o}"
			diffs << "      New:      #{g}"
			has_diff = true
		end
		end
		
		
		unless has_diff
			diffs << "  ✓ No differences"
		end
		
		diffs << ""
	end
	
	
	# ----------------------------
	# Write diff file
	# ----------------------------
	
	File.open(DIFF_FILE, "w", encoding: "UTF-8") do |f|
		f.puts diffs.join("\n")
	end
	
	
	puts "Diff file created:"
	puts DIFF_FILE
