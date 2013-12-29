require 'rails'

module Beam
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../config/initializers', __FILE__)

      desc "This generator adds beam.rb to initializers with default config"
      def copy_beam_config
        copy_file "beam.rb", "config/initializers/beam.rb"
      end
    end
  end
end
