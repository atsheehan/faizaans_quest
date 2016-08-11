import { combineReducers } from 'redux';

const games = (state = [], action) => {
  switch (action.type) {
  case 'RECEIVE_GAMES':
    return action.games;
  default:
    return state;
  }
};

const world = (state = {}, action) => {
  switch (action.type) {
  case 'RECEIVE_WORLD':
    return action.world;
  default:
    return state;
  }
};

export default combineReducers({
  games,
  world
});
