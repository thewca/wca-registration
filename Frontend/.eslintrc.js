const { configure, presets } = require('eslint-kit')

module.exports = configure({
  mode: 'only-errors',
  presets: [
    presets.imports(),
    presets.prettier(),
    presets.node(),
    presets.react(),
    presets.typescript(),
  ],
  extend: {
    rules: {
      'import/no-default-export': 'off',
      'react/jsx-uses-vars': 'error',
      'react/jsx-uses-react': 'error',
    },
  },
})
