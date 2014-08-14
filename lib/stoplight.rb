# coding: utf-8

require 'forwardable'
require 'stoplight/data_store'
require 'stoplight/data_store/base'
require 'stoplight/data_store/memory'
require 'stoplight/data_store/redis'
require 'stoplight/error'
require 'stoplight/failure'
require 'stoplight/light'
require 'stoplight/mixin'

module Stoplight
  # @return [Gem::Version]
  VERSION = Gem::Version.new('0.1.0')

  # @return [Integer]
  DEFAULT_THRESHOLD = 3

  class << self
    extend Forwardable

    def_delegators :data_store, *%w(
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

    # @param data_store [DataStore::Base]
    # @return [DataStore::Base]
    def data_store(data_store = nil)
      @data_store = data_store if data_store
      @data_store = DataStore::Memory.new unless defined?(@data_store)
      @data_store
    end

    # @param name [String]
    # @return [Boolean]
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

    # @param name [String]
    # @return [Boolean]
    def yellow?(name)
      return false if green?(name)

      failures = failures(name)
      return false if failures.empty?

      failure = failures.last
      Time.now - failure.time > (5 * 60)
    end

    # @param name [String]
    # @return [Boolean]
    def red?(name)
      !green?(name) && !yellow?(name)
    end

    # @param name [String]
    # @return [Integer]
    def threshold(name)
      data_store.threshold(name) || DEFAULT_THRESHOLD
    end
  end
end
