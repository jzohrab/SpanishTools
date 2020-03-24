# coding: utf-8
require_relative '../core_5000/get_words'
require 'test/unit'

class Test_Core5000 < Test::Unit::TestCase

  def setup()
    f = File.join(__dir__, '..', 'core_5000', 'rawdata.txt')
    @core5000 = Core5000::Core5000.new(f)
  end
  
  def assert_includes(w)
    assert_true(@core5000.includes(w))
  end

  def assert_not_includes(w)
    assert_false(@core5000.includes(w))
  end

  def test_misc_easy()
    assert_includes('a')
    assert_includes('tontos')
    assert_not_includes('nonword')
    assert_not_includes('enano')
  end

  def test_adjectives()
    assert_includes('grande')
    assert_includes('rojo')
    assert_includes('rojo')
    assert_includes('rojo')
    assert_includes('rojas')
    assert_not_includes('nonworda')
  end

  def test_verbs_with_pronouns()
    suffixes = ['', 'lo', 'la', 'los', 'las']
    suffixes.each do |suffix1|
      suffixes.each do |suffix2|
        assert_includes("disfrazar#{suffix1}")
        assert_not_includes("BLARG#{suffix1}")
      end
    end
  end

  def test_AR_verbs()
    assert_includes('disfrazar')
    assert_includes('disfraze')
    assert_includes('disfrazaríamos')
  end

  def test_ER_verbs()
    assert_includes('decaer')
    assert_includes('decaíamos')
  end

  def test_IR_verbs()
    assert_includes('desmento')
    assert_includes('desmentir')
    assert_includes('desmentiríamos')
  end

end


class Test_Core5000_FixtureDictionary < Test::Unit::TestCase

  def setup()
    f = File.join(__dir__, 'fixture', 'core_5000_dict.txt')
    @core5000 = Core5000::Core5000.new(f)
  end
  
  def assert_includes(w)
    assert_true(@core5000.includes(w))
  end

  def assert_not_includes(w)
    assert_false(@core5000.includes(w))
  end

  def test_missing_item_is_not_in_core()
    assert_not_includes('de')
  end

  def test_commented_out_item_is_not_in_core()
    assert_not_includes('haber')
  end

  def test_sanity_check_should_still_exist()
    assert_includes('tontos')
  end

end
