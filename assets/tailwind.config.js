// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin');

module.exports = {
  content: [
    './js/**/*.js',
    './js/**/*.jsx',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      fontFamily: {
        'gantari': ['Gantari']
      },
      fontSize: {
        'base': '16px',
        'small': '0.6875rem',
        'caption': '0.75rem',
        'body-2': '0.875rem',
        'body-1': '1rem',
        'subtitle': '0.875rem',
        'title': '1rem',
        'heading-6': '1.125rem',
        'heading-5': '1.25rem',
        'heading-4': '1.5rem',
        'heading-3': '1.75rem',
        'heading-2': '2rem',
        'heading-1': '2.5rem',
        'display-4': '3rem',
        'display-3': '3.5rem',
        'display-2': '4rem',
        'display-1': '4.5rem',
        'button': '1rem',
        'button-sm': '0.875rem',
      },
      height: {
        'cover-height-2xl': '380px',
        'cover-height-xl': '300px',
        'cover-height': '200px',
      },
      colors: {
        transparent: 'transparent',
        inherit: 'inherit',
        current: 'currentColor',
        'white': '#ffffff',
        'black': '#000000',
        'blue-link': "#4266FC",
        'link': '#4266FC',
        "gray": {
          "50": "#f9fafb",
          "100": "#f2f4f7",
          "200": "#e4e7ec",
          "300": "#d0d5dd",
          "400": "#98a2b3",
          "500": "#667085",
          "600": "#475467",
          "700": "#344054",
          "800": "#1d2939",
          "900": "#101828"
        },
        "primary": {
  "50": "#eae6f0",
  "100": "#cbbfd9",
  "200": "#ac98c3",
  "300": "#8d70ac",
  "400": "#6e4896",
  "500": "#4f207f",
  "600": "#300160",
  "700": "#2a0054",
  "800": "#240048",
  "900": "#1e003c",
  "a11y": "#17002d"
},
        "secondary": {
  "50": "#e6f5f4",
  "100": "#c0e4e2",
  "200": "#98d3d0",
  "300": "#70c2be",
  "400": "#48b1ac",
  "500": "#209f9a",
  "600": "#36928a",
  "700": "#2f7d75",
  "800": "#296860",
  "900": "#23534b"
},
        "success": {
          "50": "#edf3eb",
          "100": "#d6e4d3",
          "200": "#c0d4ba",
          "300": "#acc5a1",
          "400": "#98b589",
          "500": "#85a471",
          "600": "#73945a",
          "700": "#628342",
          "800": "#486b33",
          "900": "#305125"
        },
        "danger": {
          "50": "#fef3f2",
          "100": "#fee4e2",
          "200": "#fecdca",
          "300": "#fda29b",
          "400": "#f97066",
          "500": "#f04438",
          "600": "#d92d20",
          "700": "#b42318",
          "800": "#912018",
          "900": "#7a271a"
        },
        "warning": {
          "50": "#fffaeb",
          "100": "#fef0c7",
          "200": "#fedf89",
          "300": "#fec84b",
          "400": "#fdb022",
          "500": "#f79009",
          "600": "#dc6803",
          "700": "#b54708",
          "800": "#93370d",
          "900": "#7a2e0e"
        },
        "blue-gray": {
          "100": "#EAECF5",
        },
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
    require('@headlessui/tailwindcss'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &'])),
    require('tw-elements/dist/plugin')
  ]
    
}
