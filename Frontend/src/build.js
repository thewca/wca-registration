const esbuild = require('esbuild')
const process = require('process')
const fs = require('fs')
const { sassPlugin, postcssModules } = require('esbuild-sass-plugin')
const statsPlugin = require('./statsplugin')

// Clear old bundle
fs.writeFile('dist/bundle.css', '', () => {})

esbuild
  .build({
    entryPoints: ['src/index.jsx'],
    bundle: true,
    outfile: 'dist/bundle.js',
    metafile: true,
    jsxFactory: 'React.createElement',
    jsxFragment: 'React.Fragment',
    plugins: [
      sassPlugin({
        filter: /\.module\.scss$/,
        transform: postcssModules({ localsConvention: 'camelCaseOnly' }),
      }),
      sassPlugin({
        filter: /\.scss$/,
      }),
      statsPlugin(),
    ],
    define: {
      'process.env.API_URL': `"${process.env.API_URL}"`,
    },
  })
  .catch(() => process.exit(1))
