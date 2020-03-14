require 'uri'

class AnkiCardUtils

  # Highlight the (optional) article and word in the text.
  def self.get_highlighted_text(raw_text, word, article_pairs, settings)
    highlight = raw_text.dup

    preword = settings[:preword] || ''
    postword = settings[:postword] || ''

    full_re = "(?:(?:#{article_pairs.join('/').gsub('/', '|')}) )?#{word}"
    # puts full_re
    raw_text.scan(/\b#{full_re}\b/i).uniq.each do |cased_word|
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
    raw_text = d[:text].gsub("\n", '<br>')

    article_pairs = ['el/la', 'los/las', 'un/una', 'unos/unas']

    d[:text_with_highlight] = self.get_highlighted_text(raw_text, word, article_pairs, settings)

    text_with_blank = raw_text.dup.gsub(/\b#{word}\b/i, blank)

    article_pairs.each do |a|
      re = /\b(#{a.gsub('/', '|')}) #{blank}/i
      text_with_blank.gsub!(re, "(#{a}) #{blank}")
    end

    d[:text_with_blank] = text_with_blank

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

  # MP3 filenames are made using the source paragraph, but we need to keep that manageable.
  def self.get_filename_base(s, length = 20)
    ret = s.strip.gsub(' ', '_').gsub(/\.$/, '')
    return ret if ret.size <= length
    return ret[0..length - 1]
  end
  
end
