mongoose = require 'mongoose'
noflo = require 'noflo'

class Connection extends noflo.Component
  constructor: ->
    @inPorts =
      connect: new noflo.Port 'string'
      disconnect: new noflo.Port 'bang'
    @outPorts =
      connected: new noflo.Port 'object'
      disconnected: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @connections = {}

    self = this
    @connectedListener = () =>
      return unless @outPorts.connected.isAttached()
      console.log('sending mongoose')
      console.log(mongoose)
      @outPorts.connected.send(mongoose)
      @outPorts.connected.disconnect()
    @disconnectedListener = () =>
      return unless @outPorts.disconnected.isAttached()
      @outPorts.disconnected.send(mongoose)
      @outPorts.disconnected.disconnect()
    @errorListener = (err) ->
      return unless @outPorts.error.isAttached()
      @outPorts.error.send(err)
      @outPorts.error.disconnect()

    @inPorts.connect.on 'data', (uri) =>
      @disconnect () =>
        @connect(uri)

    @inPorts.disconnect.on 'data', () =>
      @disconnect()

  connect: (uri) ->
    mongoose.connection.on 'connected', @connectedListener
    mongoose.connection.on 'disconnected', @disconnectedListener
    mongoose.connection.on 'error', @errorListener
    mongoose.connect(uri)

  disconnect: (callback) ->
    if mongoose.connection.readyState == 0
      callback() if callback
      return
    mongoose.connection.removeListener 'connected', @connectedListener
    mongoose.connection.removeListener 'disconnected', @disconnectedListener
    mongoose.connection.removeListener 'error', @errorListener
    mongoose.disconnect () =>
      return unless @outPorts.disconnected.isAttached()
      @outPorts.disconnected.send(mongoose)
      @outPorts.disconnected.disconnect()
      callback() if callback


exports.getComponent = -> new Connection
