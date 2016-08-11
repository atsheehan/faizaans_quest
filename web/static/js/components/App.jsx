import React, { Children } from 'react';

import createSocket from '../socket';

// The App initializes the WebSocket connection and makes it available
// to all other components via the context. Not sure if this is the best
// approach for managing the socket, but it is necessary for most
// communication with the server so it should be readily available.

// I copied the structure from the Provider component in react-redux:
// https://github.com/reactjs/react-redux/blob/master/src/components/Provider.js

class App extends React.Component {
  constructor(props, context) {
    super(props, context);
    this.socket = createSocket();
  }

  getChildContext() {
    return { socket: this.socket };
  }

  componentWillMount() {
    this.socket.connect();
  }

  render() {
    return Children.only(this.props.children);
  }
}

App.childContextTypes = {
  socket: React.PropTypes.object
};

export default App;
