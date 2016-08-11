import React from 'react';
import { Link } from 'react-router';

const ListEntry = ({ game }) => (
  <Link to={`/app/maze/${game.id}`}>{game.id}</Link>
);

export default ({
  games
}) => {
  return (
    <ul>
      {games.map(game => <li key={game.id}><ListEntry game={game} /></li>)}
    </ul>
  );
};
