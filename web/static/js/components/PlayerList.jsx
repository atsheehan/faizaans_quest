import React from 'react';

export default ({
  players
}) => {
  let playerIds = Object.keys(players);

  return (
    <div className="player-list">
      <h2>Players</h2>

      <ul>
        {playerIds.map(id => <li key={id}>{players[id].username}</li>)}
      </ul>
    </div>
  );
};
