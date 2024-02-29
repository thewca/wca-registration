const { configure, presets } = require('eslint-kit')

module.exports = configure({
  root: __dirname,
  mode: 'only-errors',
  presets: [
    presets.imports(),
    presets.prettier(),
    presets.node(),
    presets.react(),
    presets.typescript(),
  ],
  extend: {
    root: true,
    rules: {
      'import/no-default-export': 'off',
      'react/jsx-uses-vars': 'error',
      'react/jsx-uses-react': 'error',
    },
    extends: ['plugin:@tanstack/eslint-plugin-query/recommended'],
    overrides: [
      {
        extends: ['plugin:@typescript-eslint/disable-type-checked'],
        files: ['./**/*.js','./**/*.jsx'],
      },
    ],
  },
})
