# coding: utf-8
require_relative '../core_5000/get_words'
require 'test/unit'

class Test_Core5000 < Test::Unit::TestCase

  def assert_includes(w)
    assert_true(Core5000::includes(w))
  end

  def assert_not_includes(w)
    assert_false(Core5000::includes(w))
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
        assert_includes("ver#{suffix1}")
        assert_not_includes("BLARG#{suffix1}")
      end
    end
  end

  def test_AR_verbs()
    assert_includes('hablar')
    assert_includes('hable')
    assert_includes('hablaríamos')
  end

  def test_ER_verbs()
    assert_includes('comer')
    assert_includes('comíamos')
    assert_includes('comas')
  end

  def test_IR_verbs()
    assert_includes('vivo')
    assert_includes('vivir')
    assert_includes('viviríamos')
  end

end

