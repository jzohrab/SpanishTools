# Get all of the unknowns,
# generate polly files and play them, generating a file snippet
# to substitute in the unknowns.txt.


require_relative 'get_words'
require_relative '../lib/Polly'
require_relative '../lib/Config'

config = Config.new()
voices = config.speaker_ids()

entries = Core5000::get_entries().sort { |a, b| a[:rank] <=> b[:rank] }

def play_file(f)
  cmd = "afplay #{f}"
  # puts cmd
  `#{cmd}`
end

outfile = File.join(config.output_dir, "replace_unknowns.txt")
File.delete(outfile) if File.exist?(outfile)

entries.each do |e|
  puts "\n#{e[:rank]}. #{e[:word]}"
  puts "  Creating file ..."

  text = "#{e[:word]}.  #{e[:sample]}."
  p = File.join(config.output_dir, "#{e[:word]}_#{e[:rank]}.mp3")
  SpanishPolly.create_mp3(text, 'Conchita', p) unless File.exist?(p)
  puts "  #{text}"
  play_file(p)
  
  puts "  Hit RETURN if known, any letter and return if not, q and return to QUIT"
  s = gets().strip
  break if s == 'q'
  comment = '# '
  comment = '' if s != ''
  File.open(outfile, 'a') { |f| f.puts "#{comment}#{e[:raw]}" }
end

puts
File.open(outfile, 'r') { |f| puts f.read } if File.exist?(outfile)
