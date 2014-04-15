Connect = require '../components/Connect'
socket = require('noflo').internalSocket

setupComponent = ->
  c = Connect.getComponent()
  connect = socket.createSocket()
  disconnect = socket.createSocket()
  connected = socket.createSocket()
  disconnected = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.connect.attach connect
  c.inPorts.disconnect.attach disconnect
  c.outPorts.connected.attach connected
  c.outPorts.disconnected.attach disconnected
  c.outPorts.error.attach err
  return [c, connect, disconnect, connected, disconnected, err]

exports['test connection'] = (test) ->
  [c, connect, disconnect, connected, disconnected, err] = setupComponent()
  err.once 'data', (err) ->
    test.fail err
    test.done()
  connected.once 'data', (conn1) ->
    test.ok true
    disconnected.once 'data', (conn2) ->
      test.equal conn1, conn2
      test.ok true
      test.done()
    disconnect.send 'mongodb://localhost/test-database'
    disconnect.disconnect()
  connect.send 'mongodb://localhost/test-database'
  connect.disconnect()

exports['test connection failure'] = (test) ->
  [c, connect, disconnect, connected, disconnected, err] = setupComponent()
  err.once 'data', (err) ->
    test.ok true
    test.done()
  connected.once 'data', (connection) ->
    test.fail()
    test.done()
  connect.send 'mongodb://pirhnperherohinerh/test-database'
  connect.disconnect()
