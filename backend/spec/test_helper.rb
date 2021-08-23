# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter "helper"
  add_filter "exception"
  add_filter "view"

  add_group 'Controllers', 'controllers'
  add_group 'Models', 'models'
end