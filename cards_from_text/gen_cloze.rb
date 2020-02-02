# Given a delimited text file, generate cloze data
# to be imported into Anki.

require 'optparse'
require 'yaml'
require_relative '../lib/ClozeCreator'
require_relative '../lib/SentenceExtractor'
  
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
    opts.on("-p P", String, "Prompt added to cloze hint") do |p|
      options[:prompt] = p
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
se = SentenceExtractor.new()
sentences = se.extract_sentences(raw_input, "\n")

cc = ClozeCreator.new()
output = sentences.map do |s|
  output_sentence = s.gsub("\n", '<br>')
  cloze = cc.create_cloze(output_sentence, options[:prompt])
  if (cloze == output_sentence)
    nil
  else
    cloze
  end
end.compact

settings = {
  :field_delimiter => "|",
  :tag => options[:tag]
}

# Map to CSV data
card_data = output.map do |s|
  card = [s]
  card << settings[:tag] if settings[:tag]
  card.join(settings[:field_delimiter])
end

if options[:console] then
  puts card_data
  exit(0)
else
  output = "#{input}.cloze.txt"
  File.open(output, 'w') { |f| f.puts(card_data) }
  puts "Generated #{output}"
end
