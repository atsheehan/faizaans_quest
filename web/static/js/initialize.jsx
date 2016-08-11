import React from 'react';
import { render } from 'react-dom';
import { createStore } from 'redux';

import Root from './components/Root';
import reducer from './reducers';

export default (element) => {
  let store = createStore(reducer);

  render(
    <Root store={store} />,
    element
  );
};
