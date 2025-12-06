# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "kd-imagor-ruby"

require "minitest/autorun"

class Minitest::Test
  def setup
    KdImagor.reset_configuration!
  end
end
