# coding: utf-8
require_relative '../lib/ClozeCreator'
require 'test/unit'

class Test_ClozeCreator < Test::Unit::TestCase

  def setup()
    @cc = ClozeCreator.new()
  end

  def assert_extracted(expected, sentence, prompt = nil)
    cloze = @cc.create_cloze(sentence, prompt)
    assert_equal(expected, cloze)
  end

  def test_no_delimiters()
    assert_extracted("hi there", "hi there")
  end

  def test_single()
    assert_extracted("hi {{c1::there}}", "hi *there*")
  end

  def test_two_words()
    assert_extracted("{{c1::hi}} {{c2::there}}", "*hi* *there*")
  end

  def test_hint_added_after_cloze()
    assert_extracted("{{c1::well hi::greeting}} {{c2::there}}", "*well hi|greeting* *there*")
  end

  def test_number_can_be_forced()
    assert_extracted("{{c2::hi}} {{c1::there}} {{c2::champ::note forced}}", "*(2)hi* *there* *(2)champ|note forced*")
  end

  def test_number_can_be_any_number()
    assert_extracted("{{c8::hi}} {{c1::there}} {{c2::champ::note forced}}", "*(8)hi* *there* *champ|note forced*")
  end

  def test_prompt_added_to_hint()
    assert_extracted("{{c1::hi::(something)}} {{c2::there::note (something)}}", "*hi* *there|note*", "something")
  end

end
