# coding: utf-8
require_relative '../lib/WordExtractor'
require 'test/unit'

class Test_WordExtractor < Test::Unit::TestCase

  def setup()
    @we = WordExtractor.new()
  end

  def assert_extracted(expected, sentence)
    words = @we.extract_words(sentence)
    assert_equal(expected, words)
  end
  
  def test_words_with_asterisk()
    assert_extracted(['word'], "One word* with asterisk")
  end

  def test_two_words_with_asterisk()
    assert_extracted(['word', 'with'], "More than one word* with* asterisks")
  end

  def test_dup_words_ignored()
    assert_extracted(['word'], "word* duplicates word*")
  end

  def test_asterisk_after_space_is_ignored()
    assert_extracted([], "One word * with asterisk after space")
  end

  def test_asterisk_after_period_is_ignored()
    assert_extracted([], "One word.*  But bad asterisk")
  end

  def test_asterisk_before_period_is_ok()
    assert_extracted(['word'], "One word*.  Good asterisk")
  end

  def test_can_handle_spanish_characters()
    assert_extracted(['dirección', 'sí', 'mañana'], "La dirección*, sí*, hasta mañana*.")
  end

  # The "psicólogos" word wasn't getting found due to the encoding of the ó (there are
  # multiple ways to encode it).  Now fixed.
  def test_failing_case()
    assert_extracted(['psicólogos'], "Los detectives son también un poco psicólogos*.")
  end

  def test_word_with_bar()
    assert_extracted(['psicólogos|forceroot'], "Los detectives son también un poco psicólogos|forceroot*.")
  end

  def test_asterisks_before_punctuation()
    assert_extracted(['word', 'here', 'others', 'well'], "One word*, entered here*.  And then others* as well*!")
  end

  def test_work_is_returned_as_is()
    assert_extracted(['wo1234rd'], "One wo1234rd* with asterisk")
  end

  def test_phrase_delimited_by_asterisks()
    assert_extracted(['phrase with'], "one *phrase with* asterisks")
  end

  def test_phrase_delimited_by_asterisks_with_roots()
    assert_extracted(['phrase with|forceroot'], "one *phrase with|forceroot* asterisks")
  end

  def test_phrase_and_words()
    assert_extracted(['phrase and', 'word'], "one *phrase and* another word*")
  end

  def test_single_word_phrase_and_word()
    assert_extracted(['phrase', 'word'], "one *phrase* and another word*")
  end

  def test_asterisk_at_start_only_returns_nothing()
    assert_extracted([], "one *phrase with bad asterisks")
  end
  
end
