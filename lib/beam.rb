$LOAD_PATH.unshift(File.dirname(__FILE__))
require "beam/version"
require 'beam/extensions/exception'

module Beam
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.lib
    File.join root, 'lib'
  end

  def self.tmp
    File.join root, 'tmp'
  end

  def self.spec
    File.join root, 'spec'
  end
end

require 'beam/upload'
require 'beam/upload_controller_methods'
