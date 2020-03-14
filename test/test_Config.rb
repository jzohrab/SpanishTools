# coding: utf-8
require_relative '../lib/Config'
require 'test/unit'

class Test_Config < Test::Unit::TestCase

  def setup()
    # Use the example file
    @c = Config.new(File.join(__dir__, '..', 'config.yml.example'))
  end

  def test_read_is_ok()
    assert_equal('es-ES', @c.language_code)
    assert_equal(["Conchita", "Lucia", "Enrique"], @c.speaker_ids)
  end

end
