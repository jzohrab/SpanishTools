require 'uri'

class AnkiCardUtils

  # Highlight the (optional) article and word in the sentence.
  def self.get_highlighted_sentence(raw_sentence, word, article_pairs, settings)
    highlight = raw_sentence.dup

    preword = settings[:preword] || ''
    postword = settings[:postword] || ''

    full_re = "(?:(?:#{article_pairs.join('/').gsub('/', '|')}) )?#{word}"
    # puts full_re
    raw_sentence.scan(/\b#{full_re}\b/i).uniq.each do |cased_word|
      # puts "\"#{cased_word}\""
      highlight.gsub!(/\b#{cased_word}\b/, "#{preword}#{cased_word}#{postword}")
    end
    highlight
  end


  # Adds data to raw hash h
  def self.get_card_data(h, settings = {})

    field_delimiter = settings[:field_delimiter] || "\t"
    tag = settings[:tag]
    blank = settings[:blank] || '_____'

    d = h.dup

    word = d[:word]
    raw_sentence = d[:sentence].gsub("\n", '<br>')

    article_pairs = ['el/la', 'los/las', 'un/una', 'unos/unas']

    d[:sentence_with_highlight] = self.get_highlighted_sentence(raw_sentence, word, article_pairs, settings)

    sentence_with_blank = raw_sentence.dup.gsub(/\b#{word}\b/i, blank)

    article_pairs.each do |a|
      re = /\b(#{a.gsub('/', '|')}) #{blank}/i
      sentence_with_blank.gsub!(re, "(#{a}) #{blank}")
    end

    d[:sentence_with_blank] = sentence_with_blank

    # Placeholders for sound and image links.
    token = "zzTODO"
    uri_string = URI::encode(d[:root])
    pic_search_url = "https://www.bing.com/images/search?q=#{uri_string}&cc=es"
    d[:picture_link] = "<a href=""#{pic_search_url}"">#{token}</a> ."

    sound_search_url = "https://forvo.com/word/#{uri_string}/#es"
    d[:sound_link] = "<a href=""#{sound_search_url}"">#{token}</a> ."

    definition = ''
    if (d[:definitions].size > 0)
      definition = d[:definitions][0]
    end
    d[:definition] = definition

    d

  end
  
end
