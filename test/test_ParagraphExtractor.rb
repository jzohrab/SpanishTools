require_relative '../lib/ParagraphExtractor'
require 'test/unit'

class Test_ParagraphExtractor < Test::Unit::TestCase

  def setup()
    @se = ParagraphExtractor.new()
  end

  def test_allow_text_fragments_as_paragraph()
    text = "This has no punctuation but should still be considered a sentence"
    assert_equal([text], @se.extract(text))
  end

  def test_one_paragraph()
    text = "I see a car.  It is blue."
    expected = ['I see a car.  It is blue.']
    assert_equal(expected, @se.extract(text))
  end

  def test_two_paragraph()
    text = "I see a car.
It is blue."
    expected = ['I see a car.', 'It is blue.']
    assert_equal(expected, @se.extract(text))
  end

  def test_chunk_inside_paragraph_splits_paragraph_up()
    text = "Here is one. [Here is two.  Here is three.] Here is four."
    expected = ["Here is one.", "Here is two.  Here is three.", "Here is four."]
    assert_equal(expected, @se.extract(text))
  end
  
  def test_skip_paragraphs_that_are_blank()
    text = "I see a car.

It is blue."
    expected = ['I see a car.', 'It is blue.']
    assert_equal(expected, @se.extract(text))
  end

  def test_paragraphs_that_are_delimited_by_square_brackets_are_kept_together()
    text = "[I see a car.
It is blue.]
I want to drive.  That car.
[That car.  There.]"
    expected = ["I see a car.\nIt is blue.", 'I want to drive.  That car.', 'That car.  There.']
    assert_equal(expected, @se.extract(text))
  end

  def test_sanity_check()
    text = "[I see a car.  It is blue.   ]

    I want to drive.  
That car.

[
   That car.
There.   ]"
    expected = ['I see a car.  It is blue.', 'I want to drive.', 'That car.', "That car.\nThere."]
    assert_equal(expected, @se.extract(text))
  end

  def test_chunks_can_contain_paragraph_breaks()
    text = "[I want to drive.
That car.]"
    expected = ["I want to drive.\nThat car."]
    assert_equal(expected, @se.extract(text))
  end

  def test_sanity_check_2()
    fulltext = "Here is para 1.  It has multiple sentences.
Here is para 2, with one sentence.
[I'm grouping the next 2.  This is para 3.  Multiple sentences.
And here is para 4.  Again multiple.]
And another 5"
    expected = [
      "Here is para 1.  It has multiple sentences.",
      "Here is para 2, with one sentence.",
      "I'm grouping the next 2.  This is para 3.  Multiple sentences.\nAnd here is para 4.  Again multiple.",
      "And another 5"
    ]
    assert_equal(expected, @se.extract(fulltext))
  end
end
