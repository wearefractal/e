should = require 'should'
require 'mocha'
e = require '../index'

describe 'e', ->
  beforeEach -> e.middleware = []

  describe 'middleware', ->
    it '#use()', (done) ->
      e.use (err, file, context) ->
        should.exist err
        should.exist err.message
        err.message.should.equal "NO"
        should.exist file
        file.should.equal "filename.coffee"
        should.exist context
        done()
      e "NO", "filename.coffee", @

  describe '#console', ->
    it 'should log an error properly', (done) ->
      e.use e.logger './test/test.txt'
      e.use -> done()
      e "NO"

  describe '#logger()', ->
    it 'should log an error properly', (done) ->
      old = console.log
      console.log = ->
        done()
        console.log = old
      e.use e.console
      e "NO"

  ### Screws up mocha
  describe '#global()', ->
    it 'should handle a global error properly', (done) ->
      e.use -> done()
      throw "NO"
  ###

  describe '#wrap()', ->
    it 'should wrap with an error properly', (done) ->
      e.use -> done()
      fn = e.wrap -> throw 'Code reached'
      fn new Error("NO"), "test"

    it 'should wrap without an error properly', (done) ->
      e.use -> throw 'Code reached'
      fn = e.wrap -> done()
      fn null, "test"

  describe '#handle()', ->
    it 'should wrap with an error properly', (done) ->
      e.use -> done()
      fn = e.wrap -> done()
      fn new Error("NO"), "test"

    it 'should wrap without an error properly', (done) ->
      e.use -> done()
      fn = e.wrap -> done()
      fn null, "test"