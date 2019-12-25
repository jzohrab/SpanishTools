# coding: utf-8
# Extracts words and phrases from a paragraph.  Phrases are delimited by * *,
# words are indicated by a trailing *.  See the tests for examples (in ../test).
class WordExtractor

  def extract_words(p)
    # Regex determined by trial and error ...  The first part (before
    # the '|') finds phrases, and the second finds words.
    # CRAZY unicode regexing, ref https://www.regular-expressions.info/unicode.html
    parts = p.scan(/(\*\b.*?\b\*)|(\b(?:\p{L}\p{M}*+|\d)+\b\*)/m).
            flatten.
            delete_if { |s| s.nil? }
    ret = parts.
          map { |s| s.gsub('*', '') }.
          map { |s| s.strip }.
          delete_if { |s| s == '' }.
          uniq
    return ret

  end

end
