const path = require('path')

const statsPlugin = () => ({
  name: 'stats',
  setup(build) {
    build.onStart(() => {
      // eslint-disable-next-line no-console
      console.time('build time')
    })
    build.onEnd((result) => {
      if (result.metafile) {
        Object.entries(result.metafile.outputs).forEach(([file, { bytes }]) => {
          const relPath = path.relative(
            process.cwd(),
            path.resolve(__dirname, file),
          )

          const i = Math.floor(Math.log(bytes) / Math.log(1024))
          const humanBytes =
            Number((bytes / 1024 ** i).toFixed(2)) +
            ['B', 'kB', 'MB', 'GB', 'TB'][i]
          console.info(relPath, humanBytes)
        })
      } else if ('errors' in result) {
        console.info(
          `build failed with ${result.errors.length} errors, ${result.warnings.length} warnings`,
        )
        console.info(result)
      } else {
        console.error(result)
      }
      // eslint-disable-next-line no-console
      console.timeEnd('build time')
    })
  },
})

module.exports = statsPlugin
