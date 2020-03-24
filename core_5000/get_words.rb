# coding: utf-8
# Get all the words from rawdata.txt
# Format: index|word|type|english def'n|sample_sentence

require_relative '../lib/LanguageUtils'

module Core5000

  class Core5000

    attr_accessor :entries, :words

    def initialize(filename)
      @entries = get_entries(filename)
      @words = @entries.map { |e| e[:word] }
    end

    # Returns array of hashes for each line in rawdata.txt.
    def get_entries(filename)
      lines = File.readlines(filename)
      hsh = lines.select { |s| s !~ /^#/ && s.strip != '' }.map do |lin|
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

    def includes(candidate)
      @words.each do |w|
        return true if LanguageUtils::are_like(candidate, w)
      end
      return false
    end

    def possible_matches(candidate)
      @entries.select { |e| LanguageUtils::are_like(candidate, e[:word]) }
    end

  end

  # Live code only uses the file "unknown.txt", to ensure the code
  # only refers to unknown core words.
  @core5000 = Core5000.new(File.join(__dir__, 'unknown.txt'))
  
  def self.get_entries()
    @core5000.entries
  end

  def self.get_words()
    @core5000.words
  end

  def self.includes(candidate)
    @core5000.includes(candidate)
  end

  def self.possible_matches(candidate)
    @core5000.possible_matches(candidate)
  end

end


# Manual testing and checking
if $0 == __FILE__ then
  if ARGV.size > 0 then
    words = ARGV.join(' ').gsub(/[.¿?¡!"',\-\n]/, ' ').downcase.split()
    core =
      words.
        uniq.
        map do |w|
      matches = Core5000::possible_matches(w)
      min_rank = matches.map { |m| m[:rank].to_i }.min
          { word: w, matches: matches, rank: min_rank }
        end.
        select { |w| w[:matches].size != 0 }.
        sort { |a, b| a[:rank] <=> b[:rank] }.
        reverse
    core.each do |w|
      puts "\n#{w[:word]} (#{w[:rank]})"
      w[:matches].each do |m|
        puts "  #{m[:word]} (#{m[:rank]}) - #{m[:sample]}"
      end
    end
  else
    words = Core5000::get_words()
    puts "#{words.size} words total"
    puts "#{Core5000::WORDS.size} total, from class constant."
    dups = words.select { |e| words.count(e) > 1 }.uniq
    puts "#{dups.size} dups total"
  end
end
