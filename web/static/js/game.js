let Game = {
  init(canvas, socket) {
    if (!canvas) { return; }

    this.events = [];
    this.messages = [];

    socket.connect();
    this.channel = socket.channel("maze", {});
    let module = this;

    this.channel.on("update", world => this.messages.push(world));
    this.channel.join()
      .receive("error", resp => console.log("Unable to connect to server", resp))
      .receive("ok", world => module.setup(world, canvas));
  },

  setup(world, canvas) {
    window.addEventListener("keydown", e => this.addEvent(e));
    let renderer = this.prepareRenderer(canvas);
    window.requestAnimationFrame(time => this.loop(world, renderer, time));
  },

  loop(world, renderer, time) {
    let newWorld = this.tick(
      this.handleMessages(
        this.handleEvents(world, time), time), time);

    this.render(newWorld, renderer);
    window.requestAnimationFrame(time => this.loop(newWorld, renderer, time));
  },

  prepareRenderer(canvas) {
    let ctx = canvas.getContext("2d");
    return { context: ctx, width: canvas.width, height: canvas.height };
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
      return this.move(world, { x: world.player.x - 1, y: world.player.y });

    case "ArrowRight":
      this.channel.push("move_right");
      return this.move(world, { x: world.player.x + 1, y: world.player.y });

    case "ArrowUp":
      this.channel.push("move_up");
      return this.move(world, { x: world.player.x, y: world.player.y - 1 });

    case "ArrowDown":
      this.channel.push("move_down");
      return this.move(world, { x: world.player.x, y: world.player.y + 1 });

    default:
      return world;
    }
  },

  move(world, newPosition) {
    if (this.canMoveTo(world, newPosition)) {
      return {
        rows: world.rows,
        columns: world.columns,
        grid: world.grid,
        player: newPosition
      };
    } else {
      return world;
    }
  },

  canMoveTo(world, position) {
    let index = this.index(world, position);
    return world.grid[index] == 0;
  },

  tick(world, time) {
    return world;
  },

  render(world, renderer) {
    const CELL_WIDTH = 24;

    let ctx = renderer.context;
    ctx.clearRect(0, 0, renderer.width, renderer.height);

    let playerX = world.player.x * CELL_WIDTH;
    let playerY = world.player.y * CELL_WIDTH;

    let xOffset = (renderer.width / 2) - playerX;
    let yOffset = (renderer.height / 2) - playerY;

    for (let row = 0; row < world.rows; row++) {
      for (let col = 0; col < world.columns; col++) {
        let index = row * world.columns + col;
        let cell = world.grid[index];

        let color = cell == 1 ? "gray" : "green";
        let x = col * CELL_WIDTH;
        let y = row * CELL_WIDTH;

        ctx.fillStyle = color;
        ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
      }
    }

    ctx.fillStyle = "red";
    ctx.fillRect(playerX + xOffset, playerY + yOffset, CELL_WIDTH, CELL_WIDTH);
  },

  index(world, position) {
    return (position.x * world.columns) + position.y;
  }
};

export default Game;
