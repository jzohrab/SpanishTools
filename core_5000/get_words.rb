# Get all the words from rawdata.txt
# Format: index|word|type|english def'n|sample_sentence

require_relative '../lib/LanguageUtils'

module Core5000

  # Returns array of hashes for each line in rawdata.txt.
  def self.get_entries()
    lines = File.readlines(File.join(__dir__, 'rawdata.txt'))
    hsh = lines.map do |lin|
      parts = lin.split('|')
      raise "Bad line #{lin}" unless parts.size == 5
      {
        rank: parts[0],
        word: parts[1],
        type: parts[2],
        translation: parts[3],
        sample: parts[4].strip
      }
    end
    hsh
  end

  ENTRIES = self.get_entries()

  def self.get_words()
    ENTRIES.map { |e| e[:word] }
  end

  WORDS = self.get_words()

  def self.includes(candidate)
    WORDS.each do |w|
      return true if LanguageUtils::are_like(candidate, w)
    end
    return false
  end

  def self.possible_matches(candidate)
    m = ENTRIES.select { |e| LanguageUtils::are_like(candidate, e[:word]) }
    m
  end

end


# Manual testing and checking
if $0 == __FILE__ then
  if ARGV.size == 1 then
    puts Core5000::possible_matches(ARGV[0]).inspect
  else
    words = Core5000::get_words()
    puts "#{words.size} words total"
    puts "#{Core5000::WORDS.size} total, from class constant."
    dups = words.select { |e| words.count(e) > 1 }.uniq
    puts "#{dups.size} dups total"
  end
end
