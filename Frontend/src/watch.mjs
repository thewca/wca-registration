import * as esbuild from 'esbuild';
import { sassPlugin, postcssModules } from 'esbuild-sass-plugin'
import statsPlugin from './statsplugin.js'
import openapiTS from "openapi-typescript";
import fs from "fs";
const localPath = new URL('../../swagger/v1/swagger.yaml', import.meta.url) // may be YAML or JSON format
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
  sourcemap: true,
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
    // Make sure you are running a version of the Monolith on port 3000 if needed
    // 'process.env.WCA_URL': `"http://localhost:3000"`,
    'process.env.WCA_URL': `"https://staging.worldcubeassociation.org"`,
    'process.env.API_URL': '"http://localhost:3001"',
    'process.env.AUTH_URL': '"http://localhost:3001/test/jwt"',
    'process.env.NODE_ENV': '"development"',
  },
})

// Enable watch mode
await context.watch()

// Enable serve mode
await context.serve({
  port: 3000,
  servedir: "."
})

