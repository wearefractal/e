e = (err, args...) ->
  err = new Error err unless err instanceof Error
  Error.captureStackTrace err, arguments.callee
  middle err, args... for middle in e.middleware

e.middleware = []
e.use = (fn) -> e.middleware.push fn

# Call error handler if err exists in first arg
# Call wrapped fn if err doesnt exist
e.wrap = (fn) ->
  (err, args...) ->
    return e err if err instanceof Error
    fn args...

# Call error handler if err exists in first arg
# Call wrapped fn
e.handle = (fn) ->
  (args...) ->
    e args[0] if args[0] instanceof Error
    fn args...

# Change stackTraceLimit
e.limit = (n) -> Error.stackTraceLimit = n

# Handle all global errors
e.global = -> process.on 'uncaughtException', e

# Included middleware
e.console = (err, loc, ctx) ->
  contents = "[#{new Date()}] - #{err.message}"
  contents += " thrown in #{loc}" if loc?
  contents += "\r\n#{err.stack}"
  console.log contents

e.logger = (file) ->
  (err, loc, ctx) ->
    fs = require 'fs'
    fs.readFile file, (_, contents) ->
      contents ?= " -- Error Log -- "
      contents += "\r\n[#{new Date()}] - #{err.message}"
      contents += " thrown in #{loc}" if loc?
      contents += "\r\n#{err.stack}"
      fs.writeFile file, contents

e.mongo = (db) ->
  (err, loc, ctx) ->
    mongo = require 'mongodb'
    # TODO

module.exports = e