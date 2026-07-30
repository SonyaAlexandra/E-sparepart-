/** @type {import('tailwindcss').Config} */
module.exports = {
  // Tell Tailwind where to look for class names (all Go templates)
  content: [
    "../web/templates/**/*.html",
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors — referenced in templates via CSS vars too
        'sidebar': '#0B2D59',
        'brand-green': '#568C20',
        'brand-blue': '#669EBF',
        'brand-blue-light': '#96C6D6',
        'brand-olive': '#81A64B',
      },
    },
  },
  plugins: [
    require('daisyui'),
    require('@tailwindcss/typography'),
  ],
  daisyui: {
    themes: ["light"],   // only light theme to keep bundle small
    base: true,
    styled: true,
    utils: true,
  },
}
