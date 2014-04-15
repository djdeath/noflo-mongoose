noflo = require 'noflo'

class FindOneDocument extends noflo.Component
  constructor: ->
    @inPorts =
      model: new noflo.Port 'object'
      selector: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.model.on 'data', (model) =>
      @model = model

    @inPorts.selector.on 'data', (selector) =>
      return unless @model
      @model.findOne selector, (err, docs) =>
        return @sendError err if err?
        return unless @outPorts.out.isAttached()
        @outPorts.out.send(docs)
        @outPorts.out.disconnect()

  sendError: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(err)
    @outPorts.error.disconnect()

exports.getComponent = -> new FindOneDocument
