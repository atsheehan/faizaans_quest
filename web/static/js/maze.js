let Maze = {
  init(canvas) {
    if (!canvas) { return; }

    let maze = {
      rows: 4,
      columns: 4,
      grid: [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      player: { x: 1, y: 1 }
    };

    let ctx = canvas.getContext("2d");
    let screen = { context: ctx, width: canvas.width, height: canvas.height };

    this.renderMaze(maze, screen);

    window.onkeydown = e => {
      switch (e.key) {
      case "ArrowLeft":
        maze.player.x--;
        this.renderMaze(maze, screen);
        break;

      case "ArrowRight":
        maze.player.x++;
        this.renderMaze(maze, screen);
        break;

      case "ArrowUp":
        maze.player.y--;
        this.renderMaze(maze, screen);
        break;

      case "ArrowDown":
        maze.player.y++;
        this.renderMaze(maze, screen);
        break;

      default: break;
      }
    };
  },

  renderMaze(maze, screen) {
    let ctx = screen.context;

    ctx.clearRect(0, 0, screen.width, screen.height);

    let cellWidth = 24;

    for (let row = 0; row < maze.rows; row++) {
      for (let col = 0; col < maze.columns; col++) {
        let index = row * maze.columns + col;
        let cell = maze.grid[index];

        let color = cell == 1 ? "gray": "green";
        let x = col * cellWidth;
        let y = row * cellWidth;

        ctx.fillStyle = color;
        ctx.fillRect(x, y, cellWidth, cellWidth);
      }
    }

    let playerX = maze.player.x * cellWidth;
    let playerY = maze.player.y * cellWidth;

    ctx.fillStyle = "red";
    ctx.fillRect(playerX, playerY, cellWidth, cellWidth);
  }
};

export default Maze;
