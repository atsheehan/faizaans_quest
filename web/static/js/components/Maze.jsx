import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

const CELL_WIDTH = 24;

class Maze extends Component {
  componentDidMount() {
    const { store, socket } = this.context;
    const { mazeId } = this.props.params;

    this.unsubscribe = store.subscribe(() =>
      this.forceUpdate()
    );

    this.channel = socket.channel(`mazes:${mazeId}`, {});
    this.channel.join().receive('ok', state => {
      store.dispatch({
        type: 'RECEIVE_WORLD',
        world: state
      });
    });

    this.channel.on('update', state => {
      store.dispatch({
        type: 'RECEIVE_WORLD',
        world: state
      });
    });

    const channel = this.channel;

    window.addEventListener('keydown', (event) => {
      switch (event.key) {
        case "ArrowLeft":
          channel.push("move_left");
          break;

        case "ArrowRight":
          channel.push("move_right");
          break;

        case "ArrowUp":
          channel.push("move_up");
          break;

        case "ArrowDown":
          channel.push("move_down");
          break;

        default:
          break;
      }
    });

    this.renderWorld();
  }

  componentWillUnmount() {
    this.unsubscribe();
    this.channel.off('update');
    window.removeEventListener('keydown', this.handleKeydown);
  }

  componentDidUpdate() {
    this.renderWorld();
  }

  renderWorld() {
    const { store } = this.context;
    const { world } = store.getState();

    const canvas = ReactDOM.findDOMNode(this);
    const { width, height } = canvas;
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, width, height);

    if (!world.player_id || !world.cells || !world.players) {
      return;
    }

    const { cells, players, player_id: playerId } = world;
    const player = players.find(player => player.id == playerId);

    const playerX = player.position.x * CELL_WIDTH;
    const playerY = player.position.y * CELL_WIDTH;

    const xOffset = (width / 2) - playerX;
    const yOffset = (height / 2) - playerY;

    const cellCount = cells.length;

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

    players.forEach(player => {
      let x = player.position.x * CELL_WIDTH;
      let y = player.position.y * CELL_WIDTH;

      ctx.fillRect(x + xOffset, y + yOffset, CELL_WIDTH, CELL_WIDTH);
    });
  }

  render() {
    return (
      <canvas id="maze" width="500" height="500">
        Can't render the maze.
      </canvas>
    );
  }
}

Maze.contextTypes = {
  store: PropTypes.object,
  socket: PropTypes.object
};

export default Maze;
