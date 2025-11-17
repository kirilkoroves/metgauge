import * as React from "react";

const SvgCheckCircle = (props) => (
  <svg
    viewBox="0 0 56 96"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <path
      d="M28 18c-5.5 0-10 4.5-10 10s4.5 10 10 10 10-4.5 10-10-4.5-10-10-10Zm-2 15-5-5 1.41-1.41L26 30.17l7.59-7.59L35 24l-9 9Z"
      fill="#D0D5DD"
    />
    <path
      d="M28 58c-5.5 0-10 4.5-10 10s4.5 10 10 10 10-4.5 10-10-4.5-10-10-10Zm-2 15-5-5 1.41-1.41L26 70.17l7.59-7.59L35 64l-9 9Z"
      fill="#628342"
    />
    <rect
      x={0.5}
      y={0.5}
      width={55}
      height={95}
      rx={4.5}
      stroke="#9747FF"
      strokeDasharray="10 5"
    />
  </svg>
);

export default SvgCheckCircle;
