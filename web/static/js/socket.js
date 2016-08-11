import { Socket } from "phoenix";

export default () => {
  return new Socket("/socket", {
    params: {token: window.userToken},
    logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data); }
  });
};
