# frozen_string_literal: true

require 'pdf-reader'
require 'fileutils'

RULES_DIR = 'rules_reference'
SRD_DIR = 'srd_reference'

[RULES_DIR, SRD_DIR].each do |dir|
  unless Dir.exist?(dir)
    puts "Directory '#{dir}' not found. Please create it if needed."
    next
  end

  Dir.glob("#{dir}/*.pdf").each do |pdf_path|
    txt_path = pdf_path.sub('.pdf', '.txt')

    puts "Processing #{pdf_path}..."

    begin
      reader = PDF::Reader.new(pdf_path)
      File.open(txt_path, 'w') do |file|
        reader.pages.each do |page|
          file.puts page.text
        end
      end
      puts "Created #{txt_path}"
    rescue StandardError => e
      puts "Failed to process #{pdf_path}: #{e.message}"
    end
  end
end

puts 'Done! You can now use the .txt files for rules references.'
