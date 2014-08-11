# coding: utf-8

require 'forwardable'
require 'stoplight/data_store'
require 'stoplight/data_store/base'
require 'stoplight/data_store/memory'
require 'stoplight/data_store/redis'
require 'stoplight/error'
require 'stoplight/failure'
require 'stoplight/light'

module Stoplight
  VERSION = Gem::Version.new('0.0.0')

  class << self
    extend Forwardable

    def_delegators :data_store, *%i(
      attempts
      clear_attempts
      clear_failures
      failures
      names
      record_attempt
      record_failure
      set_state
      set_threshold
      state
    )

    def data_store(data_store = nil)
      @data_store = data_store if data_store
      @data_store = DataStore::Memory.new unless defined?(@data_store)
      @data_store
    end

    def green?(name)
      case data_store.state(name)
      when DataStore::STATE_LOCKED_GREEN
        true
      when DataStore::STATE_LOCKED_RED
        false
      else
        data_store.failures(name).size < threshold(name)
      end
    end

    def red?(name)
      !green?(name)
    end

    def threshold(name)
      data_store.threshold(name) || Light::DEFAULT_THRESHOLD
    end
  end
end
