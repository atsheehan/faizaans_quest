import React, { Component, PropTypes } from 'react';
import { Presence } from 'phoenix';

import GameList from './GameList';
import PlayerList from './PlayerList';

const presenceToUser = (id, { metas: [first, ...rest] }) => {
  return { id, username: first.username };
}

class Lobby extends Component {
  componentDidMount() {
    const { store, socket } = this.context;

    this.unsubscribe = store.subscribe(() =>
      this.forceUpdate()
    );

    this.channel = socket.channel("lobby", {});
    this.presence = {};

    this.channel.on('presence_state', state => {
      this.presence = Presence.syncState(this.presence, state);
      store.dispatch({
        type: 'RECEIVE_USER_LIST',
        users: Presence.list(this.presence, presenceToUser)
      });
    });

    this.channel.on('presence_diff', diff => {
      this.presence = Presence.syncDiff(this.presence, diff);
      store.dispatch({
        type: 'RECEIVE_USER_LIST',
        users: Presence.list(this.presence, presenceToUser)
      });
    });

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
        <PlayerList players={state.players} />
      </div>
    );
  }
}

Lobby.contextTypes = {
  store: PropTypes.object,
  socket: PropTypes.object
};

export default Lobby;
