require File.dirname(__FILE__) + '/../test_helper'

class ItemHelperTest < ActiveSupport::TestCase
  include ItemsHelper
  include ActionView::Helpers::NumberHelper
  def test_format_price
    assert_equal format_price(59800), "59,800"
  end
end
