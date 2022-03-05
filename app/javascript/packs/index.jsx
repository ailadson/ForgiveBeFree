import React from "react";
import { render } from "react-dom";
import App from "../components/App";

const div = document.createElement("div");
div.classList.add('container')

document.addEventListener("DOMContentLoaded", () => {
  render(
    <App />,
    document.body.appendChild(div)
  );
});
