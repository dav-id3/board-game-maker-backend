
const app = require('express')();
const server = require('http').createServer(app);
const io = require('socket.io')(server,{
    cors: {
        origin: process.env.WEB_HOST + ":" + process.env.WEB_PORT,
        methods: ["GET", "POST"],
        credentials: true
      }
});
const PORT = process.env.API_PORT || 8080;

io.on('connection', (socket) => {
    console.log('A client connected.');
    socket.on('send', (payload) => {
        console.log(payload);
        socket.broadcast.emit('broadcast', payload);
    });
    socket.on('disconnect', () => {
        console.log('Conenction closed.');
    });
});

server.listen(PORT, () => {
    console.log(process.env.WEB_HOST + ":" + process.env.WEB_PORT)
    console.log(('server listening. Port:' + PORT));
});

process.on('SIGINT', function() {
    console.log('Do something useful here.');
    server.close();
    process.exit()
  });