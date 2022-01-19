#  cat somefile.txt | ruby examples.rb

require_relative '../lib/TheFreeDictionary'
require 'json'

f = TheFreeDictionary.new(nil)
f.debug = true

STDIN.each_line do |lin|
  word = lin.strip

  # Shortcut if blank
  next if word == ''

  result = f.lookup(word)
  # puts result.inspect

  puts "\n\n"
  puts result[:root]

  examples = result[:definitions].map do |d|
    d[:example]
  end
  examples =
    examples.
      select { |d| !d.nil? && d != '' }.
      sort { |a, b| a.length <=> b.length }.
      map { |e| "#{e.capitalize}" }.
      map { |e| e =~ /\.$/ ? e : "#{e}." }

  puts examples
end
