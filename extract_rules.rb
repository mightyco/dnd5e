require 'pdf-reader'
require 'fileutils'

RULES_DIR = 'rules_reference'

unless Dir.exist?(RULES_DIR)
  puts "Directory '#{RULES_DIR}' not found. Please create it and add your PDFs."
  exit
end

Dir.glob("#{RULES_DIR}/*.pdf").each do |pdf_path|
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

puts "Done! You can now use the .txt files for rules references."



