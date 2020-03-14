# Verb conjugation card from delimited text.

class VerbCardCreator


  def get_words_and_roots(p)
    parts = p.scan(/(\*\b.*?\b\*)/m).
            flatten.
            delete_if { |s| s.nil? }
    ret = parts.
          map { |s| s.gsub('*', '') }.
          map { |s| s.strip }.
          delete_if { |s| s == '' }.
          map { |s| s.split('|') }.
          map { |a| { :word => a[0], :root => a[1] } }.
          uniq
    return ret
  end

  def create_cards(text)

    word_root_array = get_words_and_roots(text)
    # puts word_root_array.inspect

    clean_text = text.gsub(/\*(.*?)\|.*?\*/) do |m|
      $1
    end
    # puts "CLEAN: #{clean_text}"

    ret = word_root_array.map do |h|
      raise "Missing root for word #{h[:word]}" if h[:root].nil?

      { :root => h[:root],
        :text => clean_text.dup.gsub(h[:word], "<b>#{h[:word]}</b>"),
        :text_with_blank => clean_text.dup.gsub(h[:word], '___'),
        :word => h[:word],
        :conjugation_link => "https://www.conjugacion.es/del/verbo/#{h[:root]}.php"
      }
    end

    return ret

  end

end

