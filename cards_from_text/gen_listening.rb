# Given a delimited text file, generate data and mp3 files
# to be imported into Anki.

require 'optparse'
require_relative '../lib/TextParser'
require_relative '../lib/AnkiCardUtils'
require_relative '../lib/Config'
require_relative '../lib/Polly'
  
######################################
# Options

# Return a hash describing the options.
def parse_args(args)
  options = {
    :console => false,
    :tag => nil
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

def random_string(length=5)
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  ret = ''
  length.times { ret << chars[rand(chars.size)] }
  ret
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

config = Config.new()
puts "Generating #{config.language_code} mp3 files using speakers #{config.speaker_ids}"

raw_input = File.read(input)
tp = TextParser.new()
data = tp.extract(raw_input)

# Adding some tokens to the filename to make it unique.
random_token = random_string(5)
counter = 0
data.map! do |d|
  counter += 1
  filename = "#{AnkiCardUtils.get_filename_base(d[:text])}_#{counter}_#{random_token}.mp3"
  d[:filename] = filename
  d
end

filedata = data.map { |d| [ d[:text], "[sound:#{d[:filename]}]", options[:tag] ].join('|') }

output = "#{input}.cards.txt"
File.open(output, 'w') { |f| f.puts(filedata) }
puts "Generated #{output}"

audio_outfolder = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(audio_outfolder)
puts "Generating sound files in #{audio_outfolder}"

voicedata = data.map do |d|
  {
    text: d[:text],
    voice_id: config.random_speaker_id(),
    filename: File.join(audio_outfolder, d[:filename])
  }
end
# puts voicedata
SpanishPolly.bulk_create_mp3(voicedata)

puts
puts "Audio files generated (suffixed with random token #{random_token})."
puts "Please close Anki, and move the files to ~/Library/Application Support/Anki2/User#/collection.media ."
puts "Open Anki and import the output file #{output} to the appropriate deck (Fields: Text, Recording, Tag)."
