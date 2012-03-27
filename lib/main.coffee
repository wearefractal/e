e = (err) ->
  return unless err
  err = new Error err unless err instanceof Error
  stack = e.stack err, arguments.callee
  if stack and stack[0]
    #err.frames = stack
    err.fileName = stack[0].getFileName()
    err.functionName = stack[0].getFunctionName()
    err.lineNumber = stack[0].getLineNumber()
    err.columnNumber = stack[0].getColumnNumber()
    err.context = stack[0].getThis()
  middle err for middle in e.middleware

e.middleware = []
e.use = (fn) -> e.middleware.push fn

# Call error handler if err exists in first arg
# Call wrapped fn if err doesnt exist
e.wrap = (fn) ->
  (err, args...) ->
    if err?
      e err
    else
      fn args...
    return

# Call error handler if err exists in first arg
# Call wrapped fn
e.handle = (fn) ->
  (args...) ->
    e args[0] if args[0]?
    fn args...

# Change stackTraceLimit - higher = more verbose
e.limit = (n) -> Error.stackTraceLimit = n

# Handle all global errors
e.global = -> process.on 'uncaughtException', e

# Grab raw stack frames from V8
e.stack = (err=new Error, callee=arguments.callee) ->
  orig = Error.prepareStackTrace
  err.originalStack = err.stack
  Error.prepareStackTrace = (_, stack) -> stack
  Error.captureStackTrace err, callee
  frames = err.stack
  err.stack = err.originalStack
  Error.prepareStackTrace = orig
  return frames

# Included middleware
e.console = (err) ->
  contents = "[#{new Date()}] - #{err.message}"
  contents += " thrown in #{err.fileName}" if err.fileName?
  contents += "::#{err.functionName}" if err.functionName?
  contents += ":#{err.lineNumber}" if err.lineNumber?
  contents += "\r\n#{err.stack}"
  console.log contents

e.logger = (file) ->
  (err) ->
    fs = require 'fs'
    fs.readFile file, (_, contents) ->
      contents ?= " -- Error Log -- "
      contents += "\r\n[#{new Date()}] - #{err.message}"
      contents += " thrown in #{err.fileName}" if err.fileName?
      contents += "::#{err.functionName}" if err.functionName?
      contents += ":#{err.lineNumber}" if err.lineNumber?
      contents += "\r\n#{err.stack}"
      fs.writeFile file, contents

e.mongo = (db) ->
  (err) ->
    mongo = require 'mongodb'
    # TODO

module.exports = e