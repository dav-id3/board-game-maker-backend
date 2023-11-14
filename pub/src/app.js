const app = require("express")();
const mysql = require("mysql");
const server = require("http").createServer(app);
const connection = mysql.createConnection({
  host: process.env.MARIADB_HOST || "localhost",
  port: process.env.MARIADB_PORT || 3306,
  user: process.env.MARIADB_USER || "user",
  password: process.env.MARIADB_PASSWORD || "pass",
  database: process.env.MARIADB_DATABASE || "db",
});
const qMessage = "INSERT INTO `messages` (`name`, `text`) VALUES (?, ?)";
const qCardState =
  "INSERT INTO `card_states` (`id`, `table_id`, `x`, `y`, `is_flipped`, `z_index`) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE `x`=?, `y`=?, `is_flipped`=?, `z_index`=?";
// const qCardState = "UPDATE `card_states` SET `x`=?, `y`=? WHERE `id` = ?";
const io = require("socket.io")(server, {
  cors: {
    origin: process.env.WEB_HOST + ":" + process.env.WEB_PORT,
    methods: ["GET", "POST"],
    credentials: true,
  },
});
const PORT = process.env.API_PORT || 8080;

connection.connect(function (err) {
  if (err) throw err;
  console.log(
    "MYSQL Connected(" +
      connection.config.host +
      ":" +
      connection.config.port +
      ")."
  );
});

io.on("connection", (socket) => {
  console.log("A client connected.");
  socket.on("send", (payload) => {
    console.log(payload);
    if (payload.topic === "cardState") {
      connection.query(
        qCardState,
        [
          payload.data.id,
          payload.data.tableId,
          payload.data.deltaPosition.x,
          payload.data.deltaPosition.y,
          payload.data.isFlipped,
          payload.data.zIndex,
          payload.data.deltaPosition.x,
          payload.data.deltaPosition.y,
          payload.data.isFlipped,
          payload.data.zIndex,
        ],
        (err, result, fields) => {
          if (err) throw err;
        }
      );
    } else if (payload.topic === "message") {
      connection.query(
        qMessage,
        [payload.data.name, payload.data.text],
        (err, result, fields) => {
          if (err) throw err;
        }
      );
    }
    socket.broadcast.emit("broadcast", payload);
  });
  socket.on("disconnect", () => {
    console.log("Conenction closed.");
  });
});

server.listen(PORT, () => {
  console.log("server listening. Port:" + PORT);
});

process.on("SIGINT", function () {
  console.log("Do something useful here.");
  server.close();
  process.exit();
});
