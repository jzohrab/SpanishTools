# Given a yaml file generated with build_source.rb, creates data
# to be imported into Anki.
# 

require 'optparse'
require 'yaml'
require_relative '../lib/AnkiCardUtils'
  
######################################
# Options

# Return a hash describing the options.
def parse_args(args)
  options = {
    :outputdict => false,
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} <input filepath> [options]"

    opts.separator ""
    opts.separator "Data options:"
    opts.on("-t T", String, "Tag") do |t|
      options[:tag] = t
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
  puts "Missing input file path."
  exit 1
end
input = ARGV[0]
if (!File.exist?(input))
  puts "Invalid/missing file name"
  exit 1
end
data = YAML.load_file(input)


settings = {
  :field_delimiter => "|",
  :preword => "<font color=\"#ff0000\">",
  :postword => "</font>",
  :tag => options[:tag],
  :blank => '_____'
}

# Fill in extra things for anki: highlighting, blanks, etc.
anki_data = data.map! do |d|
  AnkiCardUtils.get_card_data(d, settings)
end

# Map to CSV data
card_data = anki_data.map! do |d|
  # Order of the fields in my notes.
  card = [
    d[:root],
    d[:text_with_blank],
    d[:text_with_highlight],
    d[:picture_link],
    d[:definition],
    '',
    d[:sound_link],
    ''
  ]
  card << settings[:tag] if settings[:tag]
  card.join(settings[:field_delimiter])
end

output = "#{input}.cards.txt"
File.open(output, 'w') { |f| f.puts(card_data) }
puts "Generated #{output}"
