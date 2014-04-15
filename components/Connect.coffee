mongoose = require 'mongoose'
noflo = require 'noflo'

class Connect extends noflo.Component
  constructor: ->
    @inPorts =
      connect: new noflo.Port 'string'
      disconnect: new noflo.Port 'string'
    @outPorts =
      connected: new noflo.Port 'object'
      disconnected: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @connections = {}

    self = this
    @connectedListener = () ->
      return unless self.outPorts.connected.isAttached()
      self.outPorts.connected.send(this)
      self.outPorts.connected.disconnect()
    @disconnectedListener = () ->
      delete self.connections[this.uri]
      return unless self.outPorts.disconnected.isAttached()
      self.outPorts.disconnected.send(this)
      self.outPorts.disconnected.disconnect()
    @errorListener = (err) ->
      delete self.connections[this.uri]
      return unless self.outPorts.error.isAttached()
      self.outPorts.error.send(err)
      self.outPorts.error.disconnect()

    @inPorts.connect.on 'data', (uri) =>
      unless @connections[uri]
        @connections[uri] = mongoose.createConnection(uri)
        @connections[uri].uri = uri
      conn = @connections[uri]
      conn.on 'connected', @connectedListener
      conn.on 'disconnected', @disconnectedListener
      conn.on 'error', @errorListener

    @inPorts.disconnect.on 'data', (uri) =>
      conn = @connections[uri]
      return unless conn
      conn.removeListener 'connected', @connectedListener
      conn.removeListener 'disconnected', @disconnectedListener
      conn.removeListener 'error', @errorListener
      conn.close () =>
        return unless @outPorts.disconnected.isAttached()
        @outPorts.disconnected.send(conn)
        @outPorts.disconnected.disconnect()
      delete @connections[uri]

exports.getComponent = -> new Connect
