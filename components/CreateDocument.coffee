noflo = require 'noflo'

class CreateDocument extends noflo.Component
  constructor: ->
    @inPorts =
      model: new noflo.Port 'object'
      data: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.model.on 'data', (model) =>
      @model = model

    @inPorts.data.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup(group)
    @inPorts.data.on 'data', (data) =>
      return unless @model
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(new @model(data))
    @inPorts.data.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.data.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateDocument
