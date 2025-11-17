import * as React from "react";

const SvgTrash = (props) => (
  <svg
    viewBox="0 0 20 20"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <path
      d="M2.5 5h1.667m0 0H17.5M4.167 5v11.667a1.666 1.666 0 0 0 1.666 1.666h8.334a1.667 1.667 0 0 0 1.666-1.666V5H4.167Zm2.5 0V3.333a1.667 1.667 0 0 1 1.666-1.666h3.334a1.667 1.667 0 0 1 1.666 1.666V5"
      stroke="#101828"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export default SvgTrash;
