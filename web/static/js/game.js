let Game = {
  init(canvas, world) {
    if (!canvas) { return; }

    this.events = [];

    window.addEventListener("keydown", e => this.addEvent(e));
    let renderer = this.prepareRenderer(canvas);
    window.requestAnimationFrame(time => this.loop(world, renderer, time));
  },

  loop(world, renderer, time) {
    let newWorld = this.tick(this.handleEvents(world, time), time);
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
      return this.move(world, { x: world.player.x - 1, y: world.player.y });

    case "ArrowRight":
      return this.move(world, { x: world.player.x + 1, y: world.player.y });

    case "ArrowUp":
      return this.move(world, { x: world.player.x, y: world.player.y - 1 });

    case "ArrowDown":
      return this.move(world, { x: world.player.x, y: world.player.y + 1 });

    default:
      return world;
    }
  },

  move(world, newPosition) {
    return {
      rows: world.rows,
      columns: world.columns,
      grid: world.grid,
      player: newPosition
    };
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
  }
};

export default Game;
