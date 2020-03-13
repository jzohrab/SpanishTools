# Extracts the words, grouped by sentences.

require_relative 'WordExtractor'
require_relative 'SentenceExtractor'

class TextParser

  # From the given input string, extracts paragraphs separated by "\n",
  # or groups of paragraphs surrounded by [ ], with the words and their "roots".
  #
  # [
  #   {
  #     sentence: 'here is one sentence',
  #     words: [ { word: 'one', root: 'one' } ]
  #   }, ...
  # ]
  def extract(input_string)
    se = SentenceExtractor.new()
    sentences = se.extract_sentences(input_string, "\n")
    ret = sentences.map do |s|
      {
        sentence: s.gsub(/\|.*?\*/, '').gsub('*', '').strip,
        words: get_words(s)
      }
    end.delete_if { |item| item[:words].count == 0 }
    ret
  end

  :private

  def get_words(s)
    we = WordExtractor.new()
    words = we.extract_words(s)
    words.map do |w|
      word, root = w.split('|')
      {
        :word => word.strip,
        :root => root.nil? ? word.strip : root.strip
      }
    end
  end

end
