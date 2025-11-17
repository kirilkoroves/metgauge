import * as React from "react";

const SvgCalendarClock = (props) => (
  <svg
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <path
      fillRule="evenodd"
      clipRule="evenodd"
      d="M6.5 3.5H4A1.5 1.5 0 0 0 2.5 5v15A1.5 1.5 0 0 0 4 21.5h9v-2H4.5V12h17V5A1.5 1.5 0 0 0 20 3.5h-2.5v-1h-1v1h-9v-1h-1v1Zm10 3v-1h-9v1h-1v-1h-2V10h15V5.5h-2v1h-1Z"
      fill="#475467"
    />
    <path
      fillRule="evenodd"
      clipRule="evenodd"
      d="M18 22a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9Zm.75-4.875V14.5h-1.5v4.125H21v-1.5h-2.25Z"
      fill="#475467"
    />
  </svg>
);

export default SvgCalendarClock;
