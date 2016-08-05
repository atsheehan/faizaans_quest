import Immutable from "immutable";

let Game = {
  init(screen, socket, mazeId) {
    if (!screen.canvas || !screen.playerList) { return; }

    this.events = [];

    socket.connect();
    this.channel = socket.channel(`mazes:${mazeId}`, {});
    let module = this;

    this.channel.on("update", world => this.events.push(["update_world", world]));
    this.channel.join()
      .receive("error", resp => console.log("Unable to connect to server", resp))
      .receive("ok", state => module.setup(module.parseState(state), screen));
  },

  parseState(fromServer) {
    return Immutable.fromJS(fromServer);
  },

  setup(world, screen) {
    window.addEventListener("keydown", e => this.handleKeyDown(e));
    let renderer = this.prepareRenderer(screen);
    window.requestAnimationFrame(time => this.loop(world, renderer, time));
  },

  loop(state, renderer, time) {
    let newState = this.tick(this.handleEvents(state, time), time);

    this.render(state, newState, renderer);
    window.requestAnimationFrame(time => this.loop(newState, renderer, time));
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

  handleKeyDown(event) {
    switch (event.key) {
    case "ArrowLeft":
    case "ArrowRight":
    case "ArrowUp":
    case "ArrowDown":
      this.events.push(["move", event]);
      break;

    default:
      break;
    }
  },

  handleEvents(state, time) {
    let event = this.events.pop();

    if (event === undefined) {
      return state;
    } else {
      let [type, message] = event;
      return this.handleEvents(this.handleEvent(state, type, message, time));
    }
  },

  handleEvent(state, type, message, time) {
    switch (type) {
    case "move":
      this.handleMove(message.key);
      return state;

    case "update_world":
      return this.parseState(message);

    default:
      return state;
    }
  },

  handleMove(key) {
    switch (key) {
    case "ArrowLeft": this.channel.push("move_left"); break;
    case "ArrowRight": this.channel.push("move_right"); break;
    case "ArrowUp": this.channel.push("move_up"); break;
    case "ArrowDown": this.channel.push("move_down"); break;
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

    let player = this.findPlayer(world.get("players"), world.get("player_id"));
    let position = player.get("position");

    let playerX = position.get("x") * CELL_WIDTH;
    let playerY = position.get("y") * CELL_WIDTH;

    let xOffset = (renderer.width / 2) - playerX;
    let yOffset = (renderer.height / 2) - playerY;

    let cells = world.get("cells");
    let cellCount = cells.count();

    for (let i = 0; i < cellCount; i += 3) {
      let row = cells.get(i);
      let col = cells.get(i + 1);
      let cell = cells.get(i + 2);

      let color = cell == 1 ? "gray" : "green";
      let x = col * CELL_WIDTH;
      let y = row * CELL_WIDTH;

      ctx.fillStyle = color;
      ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
    }

    ctx.fillStyle = "red";

    for (let player of world.get("players")) {
      let position = player.get("position");

      let x = position.get("x") * CELL_WIDTH;
      let y = position.get("y") * CELL_WIDTH;

      ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
    }

    this.renderPlayerList(oldWorld.get("players"), world.get("players"), renderer.playerList);
  },

  renderPlayerList(oldPlayers, newPlayers, playerList) {
    let oldNames = oldPlayers.map(player => player.get("username"));
    let newNames = newPlayers.map(player => player.get("username"));

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
    return players.find(player => player.get("id") == playerId);
  }
};

export default Game;
