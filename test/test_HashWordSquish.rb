# coding: utf-8
require_relative '../lib/HashWordSquish'
require 'test/unit'

class Test_HashWordSquish_WordsAreLike < Test::Unit::TestCase

  def setup()
    @hws = HashWordSquish.new()
  end

  def assert_like(a, b, message = '')
    assert_true(@hws.are_like(a, b), "#{message}: #{a}, #{b} should be like")
  end

  def assert_not_like(a, b, message = '')
    assert_false(@hws.are_like(a, b), "#{message}: #{a}, #{b} should NOT be like")
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


class Test_HashWordSquish_GroupLikeWords < Test::Unit::TestCase

  def setup()
    @hws = HashWordSquish.new()
  end

  def assert_group_like(words, expected, message)
    actual = @hws.group_like_words(words)
    assert_equal(actual, expected, message)
  end
  
  def test_misc_easy()
    assert_group_like(['a'], [['a']], "single")
    assert_group_like(['a', 'a'], [['a']], "single uniq")
    assert_group_like(['tonto', 'tontos'], [['tonto', 'tontos']], "Plurals combined")
  end

  def test_likes_are_grouped()
    assert_group_like(['tonto', 'a', 'tontos'], [['a'], ['tonto', 'tontos']], "Plurals combined, separate words")
  end

  def test_same_results_regardless_of_sort_order_of_input()
    words = ['rojo', 'roja', 'comer', 'comerlo', 'comerla']
    grouped = @hws.group_like_words(words)
    words.permutation.each do |p|
      assert_equal(@hws.group_like_words(words), grouped)
    end
  end
  
end


class Test_HashWordSquish < Test::Unit::TestCase

  def setup()
    @hws = HashWordSquish.new()
  end

  def test_single_entry()
    words = { 'a' => 1 }
    actual = @hws.squish(words)
    assert_equal([{word: 'a', count: 1, forms:['a']}], actual)
  end

  def test_adjectives_and_nouns()
    words = { 'perro' => 10, 'perros' => 1, 'rojos' => 20, 'rojas' => 200, 'rojo' => 2, 'comer' => 30, 'comerlos' => 3 }
    actual = @hws.squish(words)
    expected = [
      {word: 'comer', count: 33, forms: ['comer', 'comerlos']},
      {word: 'perro', count: 11, forms: ['perro', 'perros']},
      {word: 'rojas', count: 222, forms: ['rojas', 'rojo', 'rojos']},
    ]
    assert_equal(expected, actual)
  end

end

