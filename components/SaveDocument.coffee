noflo = require 'noflo'

class FindDocument extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.in.on 'data', (document) =>
      document.save (err) =>
        return @sendError err if err?
        return unless @outPorts.out.isAttached()
        @outPorts.out.send(document)
        @outPorts.out.disconnect()

  sendError: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(err)
    @outPorts.error.disconnect()

exports.getComponent = -> new FindDocument
