function createSocket() {
  // Action cable has a websocket mounted at:
  // ws://localhost:3000/cable
  const socket_url = 'ws://localhost:3000/cable'
  const socket = new WebSocket(socket_url);

  socket.onopen = function (event) {
    console.log("Connected to server");
    const msg = {
      command: 'subscribe',
      identifier: JSON.stringify({
        id: 1,
        channel: 'AlertsChannel'
      })
    };
    socket.send(JSON.stringify(msg));
  }

  socket.onmessage = function (event) {
    console.log("Recevied data from server", event.data)
  }

  socket.onclose = function (event) {
    console.log("Disconnected from the server");
  }

  socket.onerror = function (error) {
    console.log("WebSocket error observed: ", error);
  }
}

createSocket();