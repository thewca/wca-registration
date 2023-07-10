const esbuild = require('esbuild')
const process = require('process')
const { sassPlugin, postcssModules } = require('esbuild-sass-plugin')
const statsPlugin = require('./statsplugin')

esbuild
  .build({
    entryPoints: [
      process.env.NODE_ENV === 'production'
        ? 'src/index.jsx'
        : 'src/index.dev.jsx',
    ],
    bundle: true,
    outfile: 'dist/bundle.js',
    metafile: true,
    minify: true,
    jsxFactory: 'React.createElement',
    jsxFragment: 'React.Fragment',
    loader: {
      '.svg': 'file',
      '.woff': 'file',
      '.woff2': 'file',
    },
    publicPath: process.env.ASSET_PATH,
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
      'process.env.AUTH_URL': `"${process.env.AUTH_URL}"`,
      'process.env.NODE_ENV': `"${process.env.NODE_ENV}"`,
    },
  })
  .catch(() => process.exit(1))
