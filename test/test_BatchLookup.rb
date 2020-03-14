require_relative '../lib/BatchLookup'
require 'test/unit'

class Test_BatchLookup < Test::Unit::TestCase

  class FakeLookup
    @dict

    def initialize()
      @dict = {}
    end

    def add(word, root, def_example_array)
      defs = def_example_array.map do |a|
        {
          :definition => a[0],
          :examples => a[1]
        }
      end
      @dict[word] = {
        :root => root,
        :definitions => defs
      }
    end

    def lookup(word)
      dummy = {
        :root => nil,
        :definitions => []
      }
      if @dict.has_key?(word)
        @dict[word]
      else
        dummy
      end
    end
  end
  
  def setup()
    @b = BatchLookup.new()
    @b.console_log = false
    @src = FakeLookup.new()
    @src.add("word", "wordroot", [["defs", "sentence"]])
    @src.add("wordroot", "wordroot", [["defs", "sentence"]])
  end

  def test_lookup_returns_data_for_word()
    ret = @b.batch_lookup("some *word*.", @src)
    expected = [
      {
        :word => "word",
        :text => "some word.",
        :root => "wordroot",
        :definitions => ["defs"],
        :index=>"1 of 1"
      }
    ]
    assert_equal(expected, ret)
  end

  
  def test_lookup_returns_data_for_word_with_single_asterisk()
    ret = @b.batch_lookup("some other word*.", @src)
    expected = [
      {
        :word => "word",
        :text => "some other word.",
        :root => "wordroot",
        :definitions => ["defs"],
        :index=>"1 of 1"
      }
    ]
    assert_equal(expected, ret)
  end


  # The lookup doesn't work well with, e.g., reflexive verbs
  # ("me puse" doesn't find "ponerse"), so allow the user
  # to specify the root.
  def test_can_force_the_root_if_it_is_known()
    ret = @b.batch_lookup("some other *text|wordroot*.", @src)
    expected = [
      {
        :word => "text",
        :text => "some other text.",
        :root => "wordroot",
        :definitions => ["defs"],
        :index=>"1 of 1"
      }
    ]
    assert_equal(expected, ret)
  end


  def test_forcing_root_of_single_word_with_only_post_asterisk()
    ret = @b.batch_lookup("some other text|wordroot*.", @src)
    expected = [
      {
        :word => "text",
        :text => "some other text.",
        :root => "wordroot",
        :definitions => ["defs"],
        :index=>"1 of 1"
      }
    ]
    assert_equal(expected, ret)
  end

  
  # This is a bad test because it's just testing the dummy, which is defining
  # its own contract ... it's not really validating anything.  I'm still keeping
  # this test though because I'm going to redefine how BatchLookup calls
  # the lookup source.
  def test_BAD_TEST_lookup_returns_dummy_if_missing_definition()
    ret = @b.batch_lookup("some *MISSING_WORD*.", @src)
    expected = [
      {
        :word => "MISSING_WORD",
        :text => "some MISSING_WORD.",
        :root => nil,
        :definitions => [],
        :index=>"1 of 1"
      }
    ]
    assert_equal(expected, ret)
  end

end
