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

  # Cloze creation usually likes longer paragraphs.  Delimiting these can be a real hassle,
  # so allow splits at paragraphs as well, as well as grouping multiple paragraphs.
  def test_can_split_sentences_at_paragraph_breaks()
    fulltext = "Here is para 1.  It has multiple sentences.
Here is para 2, with one sentence.
[I'm grouping the next 2.  This is para 3.  Multiple sentences.
And here is para 4.  Again multiple.]"
    sentences = [
      "Here is para 1.  It has multiple sentences.",
      "Here is para 2, with one sentence.",
      "I'm grouping the next 2.  This is para 3.  Multiple sentences.\nAnd here is para 4.  Again multiple."
    ]
    assert_equal(sentences, @se.extract_sentences(fulltext, "\n"))
  end
end
