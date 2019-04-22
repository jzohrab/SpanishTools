# Given a yaml file generated with build_source.rb, creates data
# to be imported into Anki.
# 

require 'optparse'
require 'yaml'
require 'uri'
  
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


# Given a yaml file created with the CardsFromTextSource util,
# generates data.
def generate_cards(yml, settings = {})
  field_delimiter = settings[:field_delimiter] || "\t"
  preword = settings[:preword] || ''
  postword = settings[:postword] || ''
  tag = settings[:tag]

  card_data = yml.map do |d|
    highlight = "#{preword}#{d[:word]}#{postword}"
    raw_sentence = d[:sentence].gsub("\n", '<br>')
    sentence = raw_sentence.dup.gsub(d[:word], highlight)
    sentence_with_blank = raw_sentence.dup.gsub(d[:word], '_____')
    uri_string = URI::encode(d[:root])
    pic_search_url = "https://www.bing.com/images/search?q=#{uri_string}&cc=es"
    pic_search_link = "zzTODO replace: <a href=""#{pic_search_url}"">pic_#{uri_string}</a> ."
    sound_search_url = "https://forvo.com/word/#{uri_string}/#es"
    sound_search_link = "zzTODO replace: <a href=""#{sound_search_url}"">sound_#{uri_string}</a> ."
    definition = ''
    if (d[:definitions].size > 0)
      definition = d[:definitions][0]
    end

    # Order of the fields in my notes.
    card = [d[:root], sentence_with_blank, sentence, pic_search_link, definition, '', sound_search_link, '']
    card << tag if tag
    card.join(field_delimiter)
  end

  card_data
end

settings = {
  :field_delimiter => "|",
  :preword => "<font color=\"#ff0000\">",
  :postword => "</font>",
  :tag => options[:tag]
}

output = "#{input}.cards.txt"
File.open(output, 'w') { |f| f.puts(generate_cards(data, settings)) }
puts "Generated #{output}"
