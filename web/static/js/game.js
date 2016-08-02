let Game = {
  init(screen, socket, mazeId) {
    if (!screen.canvas || !screen.playerList) { return; }

    this.events = [];
    this.messages = [];

    socket.connect();
    this.channel = socket.channel(`mazes:${mazeId}`, {});
    let module = this;

    this.channel.on("update", world => this.messages.push(world));
    this.channel.join()
      .receive("error", resp => console.log("Unable to connect to server", resp))
      .receive("ok", world => module.setup(world, screen));
  },

  setup(world, screen) {
    window.addEventListener("keydown", e => this.addEvent(e));
    let renderer = this.prepareRenderer(screen);
    window.requestAnimationFrame(time => this.loop(world, renderer, time));
  },

  loop(world, renderer, time) {
    let newWorld = this.tick(
      this.handleMessages(
        this.handleEvents(world, time), time), time);

    this.render(world, newWorld, renderer);
    window.requestAnimationFrame(time => this.loop(newWorld, renderer, time));
  },

  prepareRenderer(screen) {
    let ctx = screen.canvas.getContext("2d");
    return {
      context: ctx,
      width: screen.canvas.width,
      height: screen.canvas.height,
      playerList: screen.playerList
    };
  },

  addEvent(event) {
    switch (event.key) {
    case "ArrowLeft":
    case "ArrowRight":
    case "ArrowUp":
    case "ArrowDown":
      this.events.push(event);
      break;

    default:
      break;
    }
  },

  handleMessages(world, time) {
    let message = this.messages.pop();

    if (message === undefined) {
      return world;
    } else {
      return message;
    }
  },

  handleEvents(world, time) {
    let event = this.events.pop();

    if (event === undefined) {
      return world;
    } else {
      return this.handleEvents(this.handleEvent(world, event, time));
    }
  },

  handleEvent(world, event, time) {
    switch (event.key) {
    case "ArrowLeft":
      this.channel.push("move_left");
      return world;

    case "ArrowRight":
      this.channel.push("move_right");
      return world;

    case "ArrowUp":
      this.channel.push("move_up");
      return world;

    case "ArrowDown":
      this.channel.push("move_down");
      return world;

    default:
      return world;
    }
  },

  tick(world, time) {
    return world;
  },

  render(oldWorld, world, renderer) {
    const CELL_WIDTH = 24;

    let ctx = renderer.context;
    ctx.fillStyle = "black";
    ctx.fillRect(0, 0, renderer.width, renderer.height);

    let player = this.findPlayer(world.players, world.player_id);
    let playerX = player.position.x * CELL_WIDTH;
    let playerY = player.position.y * CELL_WIDTH;

    let xOffset = (renderer.width / 2) - playerX;
    let yOffset = (renderer.height / 2) - playerY;

    let cells = world.cells;
    let cellCount = cells.length;

    for (let i = 0; i < cellCount; i += 3) {
      let row = cells[i];
      let col = cells[i + 1];
      let cell = cells[i + 2];

      let color = cell == 1 ? "gray" : "green";
      let x = col * CELL_WIDTH;
      let y = row * CELL_WIDTH;

      ctx.fillStyle = color;
      ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
    }

    ctx.fillStyle = "red";

    for (let player of world.players) {
      let x = player.position.x * CELL_WIDTH;
      let y = player.position.y * CELL_WIDTH;

      ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
    }

    this.renderPlayerList(oldWorld.players, world.players, renderer.playerList);
  },

  renderPlayerList(oldPlayers, newPlayers, playerList) {
    let oldNames = oldPlayers.map(player => player.username);
    let newNames = newPlayers.map(player => player.username);

    if (!playerList.hasChildNodes() || !this.arraysEqual(oldNames, newNames)) {
      while (playerList.firstChild) {
        playerList.removeChild(playerList.firstChild);
      }

      newNames.forEach(username => {
        let li = document.createElement("li");
        li.appendChild(document.createTextNode(username));
        playerList.appendChild(li);
      });
    }
  },

  arraysEqual(a, b) {
    if (a.length != b.length) {
      return false;
    }

    for (let i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  },

  findPlayer(players, playerId) {
    return players.find(player => {return player.id == playerId; });
  }
};

export default Game;
