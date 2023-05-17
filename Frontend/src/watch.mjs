import * as esbuild from 'esbuild';
import {ScssModulesPlugin} from "esbuild-scss-modules-plugin";

const context = await esbuild.context({
  entryPoints: ['src/index.jsx'],
  bundle: true,
  outfile: 'dist/bundle.js',
  jsxFactory: 'React.createElement',
  jsxFragment: 'React.Fragment',
  plugins: [
    ScssModulesPlugin({
      inject: true,
      minify: true,
    }),
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

