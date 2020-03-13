# coding: utf-8
require_relative '../lib/TextParser'
require 'test/unit'

class Test_TextParser < Test::Unit::TestCase

  def setup()
    @tp = TextParser.new()
  end

  def assert_extracted(expected, sentence)
    actual = @tp.extract(sentence)
    assert_equal(expected, actual)
  end
  
  def test_words_with_asterisk()
    expected = [
      {
        sentence: 'One word with asterisk',
        words: [ { word: 'word', root: 'word' } ]
      }
    ]
    assert_extracted(expected, "One word* with asterisk")
  end

  def test_word_with_bar()
    expected = [
      {
        sentence: 'Los detectives son también un poco psicólogos.',
        words: [ { word: 'psicólogos', root: 'forceroot' } ]
      }
    ]
    assert_extracted(expected, "Los detectives son también un poco psicólogos|forceroot*.")
  end


  def test_full_test()
    text = "
This has *two* *things|items* delimited.  This is included, because it's in the same paragraph.

This *is* a separate line.

[This should have two *sentences*.
They are *grouped|together*.  And this is included, though it doesn't have any asterisks.]

This shouldn't be generated, as it doesn't have any delimiters.
     "
    expected = [
      {
        sentence: "This has two things delimited.  This is included, because it's in the same paragraph.",
        words: [ { word: 'two', root: 'two' }, { word: 'things', root: 'items' } ]
      },
      {
        sentence: 'This is a separate line.',
        words: [ { word: 'is', root: 'is' } ]
      },
      {
        sentence: "This should have two sentences.\nThey are grouped.  And this is included, though it doesn't have any asterisks.",
        words: [ { word: 'sentences', root: 'sentences' }, { word: 'grouped', root: 'together' } ]
      }
    ]
    assert_extracted(expected, text)
  end

  def test_sentences_dont_have_to_end_with_periods()
    text = "
here is *one* sentence
and here is number *two*
[ number *three* is here
it will be grouped with *four* ]
     "
    expected = [
      {
        sentence: 'here is one sentence',
        words: [ { word: 'one', root: 'one' } ]
      },
      {
        sentence: 'and here is number two',
        words: [ { word: 'two', root: 'two' } ]
      },
      {
        sentence: "number three is here\nit will be grouped with four",
        words: [ { word: 'three', root: 'three' }, { word: 'four', root: 'four' } ]
      }
    ]
    assert_extracted(expected, text)
  end

end
