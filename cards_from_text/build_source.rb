# Generates a yaml file of words, the sentence it appears in,
# and possible candidate definitions from TheFreeDictionary.
#
# Sample call:
#   ruby (this_file) /path/to/delimited/input.txt
#
# After running this program, edit the newly created output .yml file,
# deleting all bad or inappropriate definitions.  Then run the other
# utility to generate the final cards.

require 'yaml'
require_relative '../lib/TheFreeDictionary'
require_relative '../lib/BatchLookup'
require_relative '../core_5000/get_words'


def get_yaml_string(y)
  # Don't wrap text in yaml - makes it easier to delete lines.
  yaml_content = y.to_yaml(options = {:line_width => -1})

  # Adding some spaces between each "word" entry to break up
  # the solid wall of text.
  return yaml_content.gsub(/^- /, "\n\n\n- ")
end


#########################3
# MAIN

infile = ARGV[0]
puts "Please specify input file" if infile.nil?
puts "Missing file #{infile}" unless File.exist?(infile)

content = File.read(infile)
b = BatchLookup.new()
ret = b.batch_lookup(content, TheFreeDictionary.new(), settings = {})
# puts ret.inspect

core, noncore = ret.map do |hsh|
  hsh[:core] = Core5000::includes(hsh[:root])
  hsh
end.partition { |e| e[:core] == true }

puts "#{core.size} core 5000 words"
puts "#{noncore.size} non-core words"

outfile = "#{infile}.yaml"
File.open(outfile, 'w') do |f|
  f.write get_yaml_string(core + noncore)
end
puts "Generated #{outfile}."

# Verify that we can read the file again as YAML.
test_data = YAML.load_file(outfile)
puts "(verified ok)"
