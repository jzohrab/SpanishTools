# Extracts the words, grouped by sentences.

require_relative 'WordExtractor'
require_relative 'ParagraphExtractor'

class TextParser

  # From the given input string, extracts paragraphs separated by "\n",
  # or groups of paragraphs surrounded by [ ], with the words and their "roots".
  #
  # [
  #   {
  #     text: 'here is one text',
  #     words: [ { word: 'one', root: 'one' } ]
  #   }, ...
  # ]
  def extract(input_string)
    pe = ParagraphExtractor.new()
    texts = pe.extract(input_string)
    ret = texts.map do |s|
      {
        text: s.gsub(/\|.*?\*/, '').gsub('*', '').strip,
        words: get_words(s)
      }
    end
    ret
  end

  private

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
