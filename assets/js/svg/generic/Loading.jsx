import * as React from "react";

const SvgLoading = (props) => (
  <svg
    viewBox="0 0 48 48"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <path
      d="M42 24c0 9.941-8.059 18-18 18S6 33.941 6 24 14.059 6 24 6"
      stroke="#4E5969"
      strokeWidth={4}
    />
  </svg>
);

export default SvgLoading;
