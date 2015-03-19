expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a synchronous factory', ->
  {factory} = {}

  beforeEach ->
    factory = Unionized.define ->
      @set 'foo', 10
      @set 'biz.fizz', 10
      @set 'biz.faz', 10

  it 'creates an object', fibrous ->
    result = factory.json
      'baz': 'bang'
    expect(result.foo).to.equal 10
    expect(result.biz).to.deep.equal fizz: 10, faz: 10
    expect(result.baz).to.equal 'bang'

  # it 'builds an object', fibrous ->
  #   result = factory.sync.build()
  #   expect(result.foo).to.equal 10
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 10

  # it 'JSONs up an object', fibrous ->
  #   result = factory.sync.json()
  #   expect(result.foo).to.equal 10
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 10

  # it 'adds a new property', fibrous ->
  #   result = factory.sync.create baz: 20
  #   expect(result.baz).to.equal 20
  #   expect(result.foo).to.equal 10
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 10

  # it 'changes a property', fibrous ->
  #   result = factory.sync.create foo: 20
  #   expect(result.foo).to.equal 20
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 10

  # it 'changes a nested property', fibrous ->
  #   result = factory.sync.create 'biz.faz': 20
  #   expect(result.foo).to.equal 10
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 20

  # it 'changes the root of a nested property', fibrous ->
  #   result = factory.sync.create biz: 20
  #   expect(result.biz).to.equal 20

  # it 'unsets a property', fibrous ->
  #   result = factory.sync.create foo: undefined
  #   expect(Object.keys result).to.not.contain 'foo'
  #   expect(result.biz).to.deep.equal fizz: 10, faz: 10

  # it 'unsets the root of nested properties', fibrous ->
  #   result = factory.sync.create biz: undefined
  #   expect(result.foo).to.equal 10
  #   expect(Object.keys result).to.not.contain 'biz'
