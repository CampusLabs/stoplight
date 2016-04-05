# coding: utf-8

module Stoplight
  class Light # rubocop:disable Style/Documentation
    include Runnable

    # @return [Proc]
    attr_reader :error_handler
    # @return [Proc]
    attr_reader :code
    # @return [DataStore::Base]
    attr_reader :data_store
    # @return [Proc]
    attr_reader :error_notifier
    # @return [Proc, nil]
    attr_reader :fallback
    # @return [String]
    attr_reader :name
    # @return [Array<Notifier::Base>]
    attr_reader :notifiers
    # @return [Fixnum]
    attr_reader :threshold
    # @return [Float]
    attr_reader :timeout

    class << self
      # @return [DataStore::Base]
      attr_accessor :default_data_store
      # @return [Proc]
      attr_accessor :default_error_notifier
      # @return [Array<Notifier::Base>]
      attr_accessor :default_notifiers
    end

    @default_data_store = Default::DATA_STORE
    @default_error_notifier = Default::ERROR_NOTIFIER
    @default_notifiers = Default::NOTIFIERS

    # @param name [String]
    # @yield []
    def initialize(name, &code)
      @name = name
      @code = code

      with_error_handler(Default::ERROR_HANDLER)
      @data_store = self.class.default_data_store
      @error_notifier = self.class.default_error_notifier
      @fallback = Default::FALLBACK
      @notifiers = self.class.default_notifiers
      @threshold = Default::THRESHOLD
      @timeout = Default::TIMEOUT
    end

    # @param error_handler [Proc]
    # @return [self]
    def with_error_handler(error_handler)
      m = Module.new
      (class << m; self; end).instance_eval do
        define_method(:===) do |error|
          handler = ErrorHandler.new
          error_handler.call(error, handler)
          Default::AVOID_RESCUING.none? { |ar| ar === error } && handler.handle_error == error
        end
      end
      @error_handler = m
      self
    end

    class ErrorHandler
      attr_reader :handle_error

      def handle(error)
        @handle_error = error
      end
    end

    # @param data_store [DataStore::Base]
    # @return [self]
    def with_data_store(data_store)
      @data_store = data_store
      self
    end

    # @yieldparam error [Exception]
    # @return [self]
    def with_error_notifier(&error_notifier)
      @error_notifier = error_notifier
      self
    end

    # @yieldparam error [Exception, nil]
    # @return [self]
    def with_fallback(&fallback)
      @fallback = fallback
      self
    end

    # @param notifiers [Array<Notifier::Base>]
    # @return [self]
    def with_notifiers(notifiers)
      @notifiers = notifiers
      self
    end

    # @param threshold [Fixnum]
    # @return [self]
    def with_threshold(threshold)
      @threshold = threshold
      self
    end

    # @param timeout [Float]
    # @return [self]
    def with_timeout(timeout)
      @timeout = timeout
      self
    end
  end
end
