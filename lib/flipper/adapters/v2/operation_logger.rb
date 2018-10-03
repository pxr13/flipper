require 'flipper'
require 'delegate'

module Flipper
  module Adapters
    module V2
      class OperationLogger < SimpleDelegator
        include ::Flipper::Adapter

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

        def version
          Adapter::V2
        end

        def get(key)
          @operations << Flipper::Adapters::OperationLogger::Operation.new(:get, [key])
          @adapter.get(key)
        end

        def set(key, value)
          @operations << Flipper::Adapters::OperationLogger::Operation.new(:set, [key, value])
          @adapter.set(key, value)
        end

        def del(key)
          @operations << Flipper::Adapters::OperationLogger::Operation.new(:del, [key])
          @adapter.del(key)
        end

        def count(type)
          @operations.select { |operation| operation.type == type }.size
        end

        def reset
          @operations.clear
        end
      end
    end
  end
end
