# Cloze card from delimited sentence.
#
# Given a sentence containing a story with desired cloze words delimited
# with "*", outputs the marked-up result and extra content so that the
# word reading can be practiced.
#

class ClozeCreator
  
  def create_cloze(sentence, prompt)

    # Form: *(optional_number)word|optional_hint*
    output = sentence.gsub(/\*(?:\((\d+)\))?(.*?)\*/) do |m|
      number = $1
      word, raw_hint = $2.split('|')
      number_token = number.nil? ? '_NUMBER_' : number

      hint = raw_hint
      if !prompt.nil?
        hint = "#{raw_hint} (#{prompt})".strip
      end
      
      word_hint = word
      if !hint.nil?
        word_hint = "#{word}::#{hint}"
      end        

      "{{c#{number_token}::#{word_hint}}}"
    end

    # Replace remaining _NUMBER_ token with numbers.
    i = 1
    while (output.include?("{{c_NUMBER_::"))
      output.sub!("{{c_NUMBER_::", "{{c#{i}::")
      i += 1
    end

    output
  end

end

