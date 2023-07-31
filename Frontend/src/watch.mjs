import * as esbuild from 'esbuild';
import { sassPlugin, postcssModules } from 'esbuild-sass-plugin'
import statsPlugin from './statsplugin.js'
import openapiTS from "openapi-typescript";
import fs from "fs";
const localPath = new URL('/swagger/v1/swagger.yaml', import.meta.url) // may be YAML or JSON format
const output = await openapiTS(localPath, {
  transform(schemaObject) {
    if ('format' in schemaObject && schemaObject.format === 'EventId') {
      return schemaObject.nullable ? 'EventId | null' : 'EventId'
    }
  },
})

fs.writeFileSync('src/api/schema.d.ts', output)

const context = await esbuild.context({
  entryPoints: ['src/index.dev.jsx'],
  bundle: true,
  outfile: 'dist/bundle.js',
  jsxFactory: 'React.createElement',
  jsxFragment: 'React.Fragment',
  metafile: true,
  loader: {
    '.svg': "file",
    '.woff': "file",
    '.woff2': "file"
  },
  publicPath: '/dist',
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
    'process.env.API_URL': '"http://localhost:3001/api/v1"',
    'process.env.AUTH_URL': '"http://localhost:3001/jwt"',
    'process.env.NODE_ENV': '"development"',
    'process.env.STRIPE_PUBLISHABLE_KEY': '"pk_test_N0KdZIOedIrP8C4bD5XLUxOY"',
  },
})

// Enable watch mode
await context.watch()

// Enable serve mode
await context.serve({
  port: 3000,
  servedir: "."
})

