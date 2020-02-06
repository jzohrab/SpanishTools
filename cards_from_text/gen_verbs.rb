# Given a delimited text file, generate verb conj. data
# to be imported into Anki.

require 'optparse'
require 'yaml'
require_relative '../lib/VerbCardCreator'
  
######################################
# Options

# Return a hash describing the options.
def parse_args(args)
  options = {
    :outputdict => false,
    :console => false
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} <input filepath> [options]"

    opts.separator ""
    opts.separator "Data options:"

    opts.on("-t T", String, "Tag") do |t|
      options[:tag] = t
    end
    opts.on("-c", "--console", "Print output to console only") do |c|
      options[:console] = true
    end

    opts.separator ""
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end

  opt_parser.parse!(args)
  options
end

################################
# Main

options = parse_args(ARGV)

if (ARGV.size != 1)
  puts ARGV.inspect
  puts "Missing input file path."
  exit 1
end
input = ARGV[0]
if (!File.exist?(input))
  puts ARGV.inspect
  puts "Invalid/missing file name"
  exit 1
end

raw_input = File.read(input)

sentences = raw_input.split("\n")

cc = VerbCardCreator.new()
output = sentences.map do |s|
  output_sentence = s.gsub("\n", '<br>')
  cards = cc.create_cards(output_sentence)
end.compact.flatten
# puts output.inspect

settings = {
  :field_delimiter => "|",
  :tag => options[:tag]
}

# Map to CSV data
card_data = output.map do |s|
  card = [
    s[:sentence],
    s[:sentence_with_blank],
    s[:word],
    s[:root],
    "<a href=""#{s[:conjugation_link]}"">Conjugation</a> ."
  ]
  card << settings[:tag] if settings[:tag]
  card.join(settings[:field_delimiter])
end

if options[:console] then
  puts card_data
  exit(0)
else
  output = "#{input}.verbs.txt"
  File.open(output, 'w') { |f| f.puts(card_data) }
  puts "Generated #{output}"
end

puts "Field order for import:"
puts [:sentence, :sentence_with_blank, :word, :root, :conjugation_table_link, :tag].join("\n")

