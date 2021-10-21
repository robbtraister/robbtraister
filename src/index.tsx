import { StrictMode } from "react";
import ReactDOM from "react-dom";

import { Pages } from "./pages";

import "./index.scss";

window.document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <StrictMode>
      <Pages />
    </StrictMode>,
    document.getElementById("root")
  );
});
