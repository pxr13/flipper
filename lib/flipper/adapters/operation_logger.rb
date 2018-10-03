require 'delegate'
require 'flipper'

module Flipper
  module Adapters
    # Public: Adapter that wraps another adapter and stores the operations.
    #
    # Useful in tests to verify calls and such. Never use outside of testing.
    class OperationLogger < SimpleDelegator
      include ::Flipper::Adapter

      class Operation
        attr_reader :type, :args

        def initialize(type, args)
          @type = type
          @args = args
        end
      end

      OperationTypes = [
        :features,
        :add,
        :remove,
        :clear,
        :get,
        :get_multi,
        :get_all,
        :enable,
        :disable,
      ].freeze

      # Internal: An array of the operations that have happened.
      attr_reader :operations

      # Public: The name of the adapter.
      attr_reader :name

      # Public: The adapter being wrapped.
      attr_reader :adapter

      def initialize(adapter, operations = nil)
        super(adapter)
        @adapter = adapter
        @name = :operation_logger
        @operations = operations || []
      end

      def features
        @operations << Operation.new(:features, [])
        @adapter.features
      end

      def add(feature)
        @operations << Operation.new(:add, [feature])
        @adapter.add(feature)
      end

      def remove(feature)
        @operations << Operation.new(:remove, [feature])
        @adapter.remove(feature)
      end

      def clear(feature)
        @operations << Operation.new(:clear, [feature])
        @adapter.clear(feature)
      end

      def get(feature)
        @operations << Operation.new(:get, [feature])
        @adapter.get(feature)
      end

      # Public
      def get_multi(features)
        @operations << Operation.new(:get_multi, [features])
        @adapter.get_multi(features)
      end

      # Public
      def get_all
        @operations << Operation.new(:get_all, [])
        @adapter.get_all
      end

      # Public
      def enable(feature, gate, thing)
        @operations << Operation.new(:enable, [feature, gate, thing])
        @adapter.enable(feature, gate, thing)
      end

      def disable(feature, gate, thing)
        @operations << Operation.new(:disable, [feature, gate, thing])
        @adapter.disable(feature, gate, thing)
      end

      # Public: Count the number of times a certain operation happened.
      def count(type)
        type(type).size
      end

      # Public: Get all operations of a certain type.
      def type(type)
        @operations.select { |operation| operation.type == type }
      end

      # Public: Get the last operation of a certain type.
      def last(type)
        @operations.reverse.find { |operation| operation.type == type }
      end

      # Public: Resets the operation log to empty
      def reset
        @operations.clear
      end
    end
  end
end
