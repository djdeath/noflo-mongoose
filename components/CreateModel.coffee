noflo = require 'noflo'

class CreateModel extends noflo.Component
  constructor: ->
    @inPorts =
      connection: new noflo.Port 'object'
      name: new noflo.Port 'string'
      schema: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.connection.on 'data', (connection) =>
      @connection = connection
      @createModel()
    @inPorts.name.on 'data', (name) =>
      @name = name
      @createModel()
    @inPorts.schema.on 'data', (schema) =>
      @schema = schema
      @createModel()

  createModel: () ->
    return unless @connection and @name and @schema
    model = @connection.model(@name, @schema)
    delete @name
    delete @schema
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(model)
    @outPorts.out.disconnect()

exports.getComponent = -> new CreateModel
