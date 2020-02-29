# coding: utf-8

require_relative 'LanguageUtils'

class HashWordSquish
  
  def group_like_words(word_list, ostream = nil)

    words = word_list.uniq.sort

    # Cheap optimization: do an aggressive chop of word endings from
    # each word to find its shortest possible root, and use this as
    # the first pass of comparison when iterating through all words to
    # find groups.  This will not be accurate as a basis of
    # comparison, but it will serve as an initial rough cut.
    shortest_possible_word_roots = {}
    all_endings =
      [
        LanguageUtils::PLURALS,
        LanguageUtils::ADJECTIVES,
        LanguageUtils::VERB_ENDING_OBJECTS,
        LanguageUtils::REGULAR_AR_VERB_ENDINGS,
        LanguageUtils::REGULAR_ER_VERB_ENDINGS,
        LanguageUtils::REGULAR_IR_VERB_ENDINGS
      ].
        flatten.
        uniq.
        sort { |a, b| a.length != b.length ? a.length <=> b.length : a <=> b }.
        reverse
    # puts all_endings
    re = /(#{all_endings.join('|')})$/
    words.each do |w|
      shortest_possible_word_roots[w] = w.gsub(re, '')
    end
    
    ret = []

    # Pop top word from the sorted list, add to a new list C.  For
    # each word remaining in the sorted list, if it's like the top
    # word, add to C.
    current = words.shift
    while !current.nil?
      current_short_root = shortest_possible_word_roots[current]

      # puts "Building list for current word #{current}"
      likes = [current]
      words.each_with_index do |w, i|
        if shortest_possible_word_roots[w] == current_short_root && LanguageUtils::are_like(current, w) then
          likes << w
          words[i] = nil  # Don't change the size of the array during iteration
        end
      end

      ret << likes.sort
      words.compact!

      if ret.size % 1000 == 0 && !ostream.nil? then
        ostream.puts " ... #{ret.size} groups, #{words.size} words remaining"
      end

      current = words.shift
    end

    if !ostream.nil? then
      ostream.puts " ... #{ret.size} groups, #{words.size} words remaining"
    end

    ret
  end
  
  def squish(word_frequency_hash, ostream = nil)
    words = word_frequency_hash.keys.sort
    groups = group_like_words(words, ostream)
    groups.map do |g|
      {
        word: g[0],
        count: g.inject(0) { |sum, e| sum + word_frequency_hash[e] },
        forms: g
      }
    end
  end

end
