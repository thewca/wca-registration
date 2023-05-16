const esbuild = require('esbuild');
esbuild
    .build({
        entryPoints: ['src/index.jsx'],
        bundle: true,
        outfile: 'dist/bundle.js',
        jsxFactory: 'React.createElement',
        jsxFragment: 'React.Fragment',
        plugins: [
            require('esbuild-scss-modules-plugin').ScssModulesPlugin({
                inject: true,
                minify: true
            })
        ],
        define: {
            'process.env.NODE_ENV': '"production"',
            'process.env.API_URL': '"localhost:3001"'
        },
    })
    .catch(() => process.exit(1));
