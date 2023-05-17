const esbuild = require('esbuild')

// Create a context for incremental builds
const context = await esbuild.context({
  entryPoints: ['src/index.jsx'],
  bundle: true,
  outfile: 'dist/bundle.js',
  jsxFactory: 'React.createElement',
  jsxFragment: 'React.Fragment',
  plugins: [
    require('esbuild-scss-modules-plugin').ScssModulesPlugin({
      inject: true,
      minify: true,
    }),
  ],
  define: {
    'process.env.NODE_ENV': '"production"',
    'process.env.API_URL': '"localhost:3001"',
  },
})

// Enable watch mode
await context.watch()

// Enable serve mode
await context.serve()

// Dispose of the context
context.dispose()
