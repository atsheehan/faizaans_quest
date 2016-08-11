import React, { Component, PropTypes } from 'react';

import GameList from './GameList';

class Lobby extends Component {
  componentDidMount() {
    const { store, socket } = this.context;

    this.unsubscribe = store.subscribe(() =>
      this.forceUpdate()
    );

    this.channel = socket.channel("lobby", {});
    this.channel.join().receive("ok", state => {
      store.dispatch({
        type: 'RECEIVE_GAMES',
        games: state.map(id => ({ id }))
      });
    });
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    const { store } = this.context;
    const state = store.getState();

    return (
      <div id="lobby">
        <h1>Choose a Game</h1>
        <GameList games={state.games} />
      </div>
    );
  }
}

Lobby.contextTypes = {
  store: PropTypes.object,
  socket: PropTypes.object
};

export default Lobby;
