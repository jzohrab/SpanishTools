# coding: utf-8
require_relative '../lib/VerbCardCreator'
require 'test/unit'

class Test_VerbCardCreator < Test::Unit::TestCase

  def setup()
    @cc = VerbCardCreator.new()
  end


  def test_single_card()
    text = "Here is a single *verb|root*."
    cards = @cc.create_cards(text)
    expected = [
      { :root => 'root',
        :text => 'Here is a single <b>verb</b>.',
        :text_with_blank => 'Here is a single ___.',
        :word => 'verb',
        :conjugation_link => "https://www.conjugacion.es/del/verbo/root.php"
      }
    ]
    assert_equal(expected, cards)
  end


  def test_two_cards_from_one_text()
    text = "Here is a single *verb|root* and another *v2|r2*."
    cards = @cc.create_cards(text)
    expected = [
      { :root => 'root',
        :text => 'Here is a single <b>verb</b> and another v2.',
        :text_with_blank => 'Here is a single ___ and another v2.',
        :word => 'verb',
        :conjugation_link => "https://www.conjugacion.es/del/verbo/root.php"
      },
      { :root => 'r2',
        :text => 'Here is a single verb and another <b>v2</b>.',
        :text_with_blank => 'Here is a single verb and another ___.',
        :word => 'v2',
        :conjugation_link => "https://www.conjugacion.es/del/verbo/r2.php"
      }
    ]
    assert_equal(expected, cards)
  end


  def test_single_card_created_if_both_elements_are_identical()
    text = "Here is a single *verb|root* and another *verb|root*."
    cards = @cc.create_cards(text)
    expected = [
      { :root => 'root',
        :text => 'Here is a single <b>verb</b> and another <b>verb</b>.',
        :text_with_blank => 'Here is a single ___ and another ___.',
        :word => 'verb',
        :conjugation_link => "https://www.conjugacion.es/del/verbo/root.php"
      }
    ]
    assert_equal(expected, cards)
  end


  def test_error_raised_if_missing_root_form_of_verb()
    text = "Here is a single *verb* but the root isn't specified."
    assert_raise do
      cards = @cc.create_cards(text)
    end
  end

end
