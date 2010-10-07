require 'adapter/asserts'
require 'adapter/exceptions'

module Adapter
  extend Asserts

  def self.definitions
    @definitions ||= {}
  end

  def self.define(name, mod=nil, &block)
    definition_module = Module.new
    definition_module.send(:include, mod) unless mod.nil?
    definition_module.send(:include, Module.new(&block)) if block_given?
    assert_valid_module(definition_module)
    definitions[name.to_sym] = definition_module
  end

  def self.adapters
    @adapters ||= {}
  end

  def self.[](name)
    assert_valid_adapter(name)
    adapters[name.to_sym] ||= get_adapter_instance(name)
  end

  private
    def self.get_adapter_instance(name)
      Class.new do
        attr_reader :client

        def initialize(client)
          @client = client
        end

        include Adapter.definitions[name.to_sym]
      end
    end
end