# Sample call:
#    $ ruby polly_unknowns.rb 501 600
# Gets entries from 501 to 600

# Get all of the unknowns,
# generate polly files and play them, generating a file snippet
# to substitute in the unknowns.txt.


require_relative 'get_words'
require_relative '../lib/Polly'
require_relative '../lib/Config'

from = 0
from = ARGV[0].to_i if ARGV.size > 0
to = 10000
to = ARGV[1].to_i if ARGV.size > 1

STDIN.flush

puts "Getting words from #{from} to #{to}"

entries =
  Core5000::get_entries().
    sort { |a, b| a[:rank] <=> b[:rank] }.
    select { |e| r = e[:rank].to_i; r >= from && r <= to }

def play_file(f)
  cmd = "afplay #{f}"
  # puts cmd
  `#{cmd}`
end

config = Config.new()
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
  s = STDIN.gets().strip
  break if s == 'q'
  comment = '# '
  comment = '' if s != ''
  File.open(outfile, 'a') { |f| f.puts "#{comment}#{e[:raw]}" }
end

puts
File.open(outfile, 'r') { |f| puts f.read } if File.exist?(outfile)
