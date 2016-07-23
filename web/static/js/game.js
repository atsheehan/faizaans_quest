let Game = {
  init(canvas, world) {
    if (!canvas) { return; }

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

  handleEvents(world, _time) {
    return world;
  },

  tick(world, time) {
    return world;
  },

  render(world, renderer) {
    let ctx = renderer.context;
    ctx.clearRect(0, 0, renderer.width, renderer.height);

    const CELL_WIDTH = 24;

    for (let row = 0; row < world.rows; row++) {
      for (let col = 0; col < world.columns; col++) {
        let index = row * world.columns + col;
        let cell = world.grid[index];

        let color = cell == 1 ? "gray" : "green";
        let x = col * CELL_WIDTH;
        let y = row * CELL_WIDTH;

        ctx.fillStyle = color;
        ctx.fillRect(x, y, CELL_WIDTH, CELL_WIDTH);
      }
    }

    let playerX = world.player.x * CELL_WIDTH;
    let playerY = world.player.y * CELL_WIDTH;

    ctx.fillStyle = "red";
    ctx.fillRect(playerX, playerY, CELL_WIDTH, CELL_WIDTH);
  }
};

export default Game;
