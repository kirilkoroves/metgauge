import * as React from "react";

const SvgHome = (props) => (
  <svg
    className="custom-color"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <path
      fillRule="evenodd"
      clipRule="evenodd"
      d="m12 2.34 9.5 5.588V21.5h-19V7.928L12 2.34ZM11 19.5h2V15h-2v4.5Zm4 0V13H9v6.5H4.5V9.072L12 4.66l7.5 4.412V19.5H15Z"
      fill="#475467"
    />
  </svg>
);

export default SvgHome;
