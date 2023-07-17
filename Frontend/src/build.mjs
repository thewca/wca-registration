import * as esbuild from 'esbuild'
import process from 'node:process'
import { sassPlugin, postcssModules } from 'esbuild-sass-plugin'
import statsPlugin from './statsplugin.js'
import openapiTS from "openapi-typescript";
import fs from "fs";
// Generate Types from spec first so we are sure that the build is never out of sync with the spec
const localPath = new URL('../../swagger/v1/swagger.yaml', import.meta.url) // may be YAML or JSON format
const output = await openapiTS(localPath, {
    transform(schemaObject) {
        if ('format' in schemaObject && schemaObject.format === 'EventId') {
            return schemaObject.nullable ? 'EventId | null' : 'EventId'
        }
    },
})
fs.writeFileSync('./src/api/schema.d.ts', output)

if (!process.env.TYPES_ONLY) {
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
}
