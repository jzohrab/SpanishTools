# coding: utf-8
require_relative '../lib/LanguageUtils'
require 'test/unit'

class Test_LanguageUtils_WordsAreLike < Test::Unit::TestCase

  def assert_like(a, b, message = '')
    assert_true(LanguageUtils::are_like(a, b), "#{message}: #{a}, #{b} should be like")
  end

  def assert_not_like(a, b, message = '')
    assert_false(LanguageUtils::are_like(a, b), "#{message}: #{a}, #{b} should NOT be like")
  end

  def test_misc_easy()
    assert_like('a', 'a')
    assert_like('tonto', 'tontos', "Plurals")
  end

  def test_adjectives()
    assert_like('grande', 'grandes', 'plural')
    assert_like('rojo', 'roja', 'masc/fem')
    assert_like('rojo', 'rojos', 'sing/pl')
    assert_like('rojo', 'rojas', 'sing/pl m/f')
    assert_like('rojas', 'rojo', 'sing/pl m/f')
  end

  def test_verbs_with_pronouns()
    suffixes = ['', 'lo', 'la', 'los', 'las']
    suffixes.each do |suffix1|
      suffixes.each do |suffix2|
        assert_like("ver#{suffix1}", "ver#{suffix2}", suffix1 + suffix2)
        assert_not_like("leer#{suffix1}", "ver#{suffix2}", suffix1 + suffix2)
      end
    end
  end

  def test_AR_verbs()
    assert_like('hablar', 'hablaba')
    assert_like('hable', 'hablaríamos')
    assert_like('hablaríamos', 'habló')
  end

  def test_ER_verbs()
    assert_like('comer', 'comía')
    assert_like('comíamos', 'comieron')
    assert_like('comas', 'comiste')
  end

  def test_IR_verbs()
    assert_like('vivo', 'vivías')
    assert_like('vivir', 'vivirá')
    assert_like('viviríamos', 'vivió')
  end

end

