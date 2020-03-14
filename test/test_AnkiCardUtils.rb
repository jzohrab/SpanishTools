require_relative '../lib/AnkiCardUtils'
require 'test/unit'

class Test_AnkiCardUtils < Test::Unit::TestCase

  def setup()
    @utils = AnkiCardUtils.new()
    @data = {
      :word => 'someword',
      :text => 'some text with someword in it',
      :root => 'someroot',
      :definitions => ['def']
    }
    @settings = {
      :blank => '_',
      :preword => '>',
      :postword => '<'
    }
  end

  def test_returns_data()
    ret = AnkiCardUtils.get_card_data(@data)
    assert_true(ret.is_a?(Hash))
  end

  def assert_blanked_text_equals(word, text, expected)
    @data[:word] = word
    @data[:text] = text
    ret = AnkiCardUtils.get_card_data(@data, @settings)
    msg = "\"#{word}\" in \"#{text}\""
    assert_equal(expected, ret[:text_with_blank], msg)
  end

  [
    ['text only contains word', 'word', 'word', '_'],
    ['caps ignored base case', 'word', 'WORD', '_'],
    ['blanked', 'word', 'a word is here', 'a _ is here'],
    ['not blanked if part of another word', 'w', 'a w longw w', 'a _ longw _'],
    ['article removed', 'w', 'el w is here', '(el/la) _ is here'],
    ['article left for different word', 'w', 'el word is here', 'el word is here'],
    ['article in middle', 'w', 'xx el w xx', 'xx (el/la) _ xx'],
    ['article at start', 'w', 'el w xx', '(el/la) _ xx'],
    ['caps ignored', 'w', 'el W xx', '(el/la) _ xx'],
    ['article word and period', 'w', 'el W.', '(el/la) _.'],
    ['caps article is ok', 'w', 'El W.', '(el/la) _.'],
    ['article word embedded', 'w', 'el wstuff', 'el wstuff'],
    ['indef article is ok', 'w', 'Una w', '(un/una) _'],
    ['indef article lowercase', 'w', 'un w', '(un/una) _'],
    ['plural indef', 'w', 'xxx unos w yyy', 'xxx (unos/unas) _ yyy'],
    ['plural indef uppercase', 'w', 'xxx. Unos w yyy', 'xxx. (unos/unas) _ yyy'],
    ['plural def', 'w', 'xxx los w yyy', 'xxx (los/las) _ yyy'],
    ['plural def uppercase', 'w', 'xxx. Las w yyy', 'xxx. (los/las) _ yyy'],
  ].each do |testcase, word, text, expected|
    methodname = "test_blanked_#{testcase.gsub(' ', '_')}"
    define_method :"#{methodname}" do
      assert_blanked_text_equals(word, text, expected)
    end
  end

  def assert_highlight_text_equals(word, text, expected)
    @data[:word] = word
    @data[:text] = text
    ret = AnkiCardUtils.get_card_data(@data, @settings)
    msg = "\"#{word}\" in \"#{text}\""
    assert_equal(expected, ret[:text_with_highlight], msg)
  end

  [
    ['text only contains word', 'word', 'word', '>word<'],
    ['caps ignored base case', 'word', 'WORD', '>WORD<'],
    ['highlight', 'word', 'a word is here', 'a >word< is here'],
    ['not blanked if part of another word', 'w', 'a w longw w', 'a >w< longw >w<'],
    ['word with article', 'w', 'the el w is here', 'the >el w< is here'],
    ['caps ignored', 'w', 'el W xx', '>el W< xx'],
    ['article word and period', 'w', 'el W.', '>el W<.'],
    ['indef article is ok', 'w', 'Una w', '>Una w<'],
    ['multiple cases', 'ab', 'Ab abc AB aB ab cab', '>Ab< abc >AB< >aB< >ab< cab']
  ].each do |testcase, word, text, expected|
    methodname = "test_highlight_#{testcase.gsub(' ', '_')}"
    define_method :"#{methodname}" do
      assert_highlight_text_equals(word, text, expected)
    end
  end

end


class Test_AnkiCardUtils_get_filename_base < Test::Unit::TestCase

  def test_short_name()
    assert_equal("Hola", AnkiCardUtils.get_filename_base("Hola"))
  end

  def test_last_period_stripped()
    assert_equal("Hola", AnkiCardUtils.get_filename_base("Hola."))
  end

  def spaces_replaced_with_underscore()
    assert_equal("Hola_tengo_un_gato", AnkiCardUtils.get_filename_base("Hola tengo un gato y su nombre es Lola."))
  end

  def test_long_name_truncated_to_20_chars()
    assert_equal("Hola_tengo_un_gato_y", AnkiCardUtils.get_filename_base("Hola tengo un gato y su nombre es Lola."))
  end

  def test_long_name_truncated_to_specified_chars()
    assert_equal("Hola_ten", AnkiCardUtils.get_filename_base("Hola tengo un gato y su nombre es Lola.", 8))
  end

end
