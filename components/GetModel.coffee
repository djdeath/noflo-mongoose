schemagen = require 'mongoose-schemagen'
noflo = require 'noflo'

class CreateModel extends noflo.Component
  constructor: ->
    @inPorts =
      connection: new noflo.Port 'object'
      name: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.connection.on 'data', (connection) =>
      @connection = connection
      @createmodel()
    @inPorts.name.on 'data', (name) =>
      @name = name
      @createmodel()

  createModel: () ->
    return unless @connection and @name
    model = @connection.model(@name)
    delete @name
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(model)
    @outPorts.out.disconnect()

exports.getComponent = -> new CreateModel
