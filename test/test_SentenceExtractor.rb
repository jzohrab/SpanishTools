require_relative '../lib/SentenceExtractor'
require 'test/unit'

class Test_SentenceExtractor < Test::Unit::TestCase

  def setup()
    @se = SentenceExtractor.new()
  end

  def test_extracts_sentences_separated_by_fullstop()
    sentence = "I see a car.  It is blue."
    sentences = ['I see a car.', 'It is blue.']
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

  def test_skips_sentences_that_are_just_fullstop()
    sentence = "I see a car. . It is blue."
    sentences = ['I see a car.', 'It is blue.']
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

  def test_sentences_that_are_delimited_by_square_brackets_are_kept_together()
    sentence = "[I see a car.  It is blue.] I want to drive.  That car.  [That car.  There.]"
    sentences = ['I see a car.  It is blue.', 'I want to drive.', 'That car.', 'That car.  There.']
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

  def test_sanity_check()
    sentence = "[I see a car. [[[ It is blue.   ]    I want to drive.  .  That car.  [   That car.  There.   ]"
    sentences = ['I see a car.  It is blue.', 'I want to drive.', 'That car.', 'That car.  There.']
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

  def test_sentences_with_paragraph_breaks()
    sentence = "I want to drive.
That car."
    sentences = ['I want to drive.', 'That car.']
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

  def test_chunks_can_contain_paragraph_breaks()
    sentence = "[I want to drive.
That car.]"
    sentences = ["I want to drive.\nThat car."]
    assert_equal(sentences, @se.extract_sentences(sentence))
  end

end
