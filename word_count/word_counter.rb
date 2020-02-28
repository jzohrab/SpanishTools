# Given a file, extracts frequency of all words.

require_relative '../lib/HashWordSquish'

raise 'Missing filename' if ARGV.size == 0
fname = ARGV[0]
raise "Missing file #{fname}" if !File.exist?(fname)

ignore_words = []
ignore_file = File.join(__dir__, 'ignore.txt')
if File.exist?(ignore_file) then
  ignore_words =
    File.readlines(ignore_file).
      select { |s| s !~ /^#/ }.
      map { |s| s.downcase.strip }.
      select { |s| s != '' }.
      sort.
      uniq
end
# puts ignore_words.inspect

# CRAZY unicode regexing, ref https://www.regular-expressions.info/unicode.html
words = []
File.open(fname, 'r') do |f|
  words = f.read.downcase.scan(/\b(?:\p{L}\p{M}*+|\d|\|){3,16}\b/)
end
puts "Found #{words.count} words ..."
words -= ignore_words
puts "Processing #{words.count} words, ignoring words in ignore.txt ..."

counter = 0
frequency = Hash.new(0)
words.each do |word|
  counter += 1
  puts " ... #{counter} of #{words.count}" if counter % 1000 == 0
  frequency[word] = frequency[word] + 1
end
puts "Done."

pairs = frequency.
          to_a.
          sort { |a, b| a[1] <=> b[1] }.   # Sort by frequency
          reverse                          # Highest freq at the top

# Raw frequency: the words, as-is.
outfile = "#{fname}.frequency.RAW.txt"
File.open(outfile, 'w') do |f|
  pairs.each do |word, count|
    f.puts "#{count.to_s.rjust(5, '0')}|#{word}"
  end
end
puts "Wrote #{outfile}, #{pairs.size} words"


puts "Grouping like words where possible ..."
h = HashWordSquish.new()
rows = h.squish(frequency, $stdout).sort { |a, b| a[:count] <=> b[:count] }.reverse

outfile = "#{fname}.frequency.COMPRESSED.txt"
File.open(outfile, 'w') do |f|
  rows.each do |r|
    f.puts [r[:count].to_s.rjust(5, '0'), r[:word], r[:forms].join(',')].join('|')
  end
end
puts "Wrote #{outfile}, #{rows.size} word groups"
