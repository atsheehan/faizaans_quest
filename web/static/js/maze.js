let Maze = {
  init(canvas) {
    if (!canvas) { return; }

    let ctx = canvas.getContext("2d");

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.fillStyle = "black";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    let maze = {
      rows: 4,
      columns: 4,
      grid: [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1]
    };

    this.renderMaze(ctx, maze);
  },

  renderMaze(ctx, maze) {
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
  }
};

export default Maze;
