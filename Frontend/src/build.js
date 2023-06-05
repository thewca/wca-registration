const esbuild = require('esbuild')
const process = require('process')
const { sassPlugin, postcssModules } = require('esbuild-sass-plugin')
const statsPlugin = require('./statsplugin')

esbuild
  .build({
    entryPoints: ['src/index.jsx'],
    bundle: true,
    outfile: 'dist/bundle.js',
    metafile: true,
    jsxFactory: 'React.createElement',
    jsxFragment: 'React.Fragment',
    loader: {
      '.svg': 'file',
      '.woff': 'file',
      '.woff2': 'file',
    },
    publicPath: '/assets',
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
