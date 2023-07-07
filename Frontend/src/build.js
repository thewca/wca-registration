const esbuild = require('esbuild')
const process = require('process')
const { sassPlugin, postcssModules } = require('esbuild-sass-plugin')
const statsPlugin = require('./statsplugin')
const openapiTS = require('openapi-typescript')
const fs = require('fs')
// Generate Types from spec first so we are sure that the build is never out of sync with the spec
const localPath = new URL('../../swagger/v1/swagger.yaml', import.meta.url) // may be YAML or JSON format
openapiTS(localPath, {
  transform(schemaObject) {
    if ('event_id' in schemaObject && schemaObject.format === 'string') {
      return schemaObject.nullable ? 'EventId | null' : 'EventId'
    }
  },
}).then((output) => {
  fs.writeFileSync('./api/schema.d.ts', output)

  if (!process.env.TYPES_ONLY) {
    esbuild
      .build({
        entryPoints: ['src/index.jsx'],
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
  }
})
