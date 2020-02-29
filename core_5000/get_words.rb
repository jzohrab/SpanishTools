# Get all the words from rawdata.txt
# Format: index|word|type|english def'n|sample_sentence

module Core5000

  def self.get_words()
    lines = File.readlines(File.join(__dir__, 'rawdata.txt'))
    words = lines.map do |lin|
      parts = lin.split('|')
      raise "Bad line #{lin}" unless parts.size == 5
      parts[1]
    end
    words
  end

end


# Manual testing and checking
if $0 == __FILE__ then
  words = Core5000::get_words()
  puts "#{words.size} words total"
  dups = words.select { |e| words.count(e) > 1 }.uniq
  puts "#{dups.size} dups total"
end
