import * as esbuild from 'esbuild';
import { sassPlugin, postcssModules } from 'esbuild-sass-plugin'
import statsPlugin from './statsplugin.js'

const context = await esbuild.context({
  entryPoints: ['src/index.jsx'],
  bundle: true,
  outfile: 'dist/bundle.js',
  jsxFactory: 'React.createElement',
  jsxFragment: 'React.Fragment',
  metafile: true,
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
    'process.env.API_URL': '"http://localhost:3001"',
  },
})

// Enable watch mode
await context.watch()

// Enable serve mode
await context.serve({
  port: 3000,
  servedir: "."
})

