import * as React from "react";

const SvgToggleLgOn = (props) => (
  <svg
    viewBox="0 0 44 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <g clipPath="url(#toggle-lg-on_svg__a)">
      <rect width={44} height={24} rx={12} fill="#628342" />
      <g filter="url(#toggle-lg-on_svg__b)">
        <circle cx={32} cy={12} r={10} fill="#fff" />
      </g>
    </g>
    <defs>
      <clipPath id="toggle-lg-on_svg__a">
        <rect width={44} height={24} rx={12} fill="#fff" />
      </clipPath>
      <filter
        id="toggle-lg-on_svg__b"
        x={19}
        y={0}
        width={26}
        height={26}
        filterUnits="userSpaceOnUse"
        colorInterpolationFilters="sRGB"
      >
        <feFlood floodOpacity={0} result="BackgroundImageFix" />
        <feColorMatrix
          in="SourceAlpha"
          values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          result="hardAlpha"
        />
        <feOffset dy={1} />
        <feGaussianBlur stdDeviation={1} />
        <feColorMatrix values="0 0 0 0 0.0627451 0 0 0 0 0.0941176 0 0 0 0 0.156863 0 0 0 0.06 0" />
        <feBlend
          in2="BackgroundImageFix"
          result="effect1_dropShadow_324_18680"
        />
        <feColorMatrix
          in="SourceAlpha"
          values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          result="hardAlpha"
        />
        <feOffset dy={1} />
        <feGaussianBlur stdDeviation={1.5} />
        <feColorMatrix values="0 0 0 0 0.0627451 0 0 0 0 0.0941176 0 0 0 0 0.156863 0 0 0 0.1 0" />
        <feBlend
          in2="effect1_dropShadow_324_18680"
          result="effect2_dropShadow_324_18680"
        />
        <feBlend
          in="SourceGraphic"
          in2="effect2_dropShadow_324_18680"
          result="shape"
        />
      </filter>
    </defs>
  </svg>
);

export default SvgToggleLgOn;
