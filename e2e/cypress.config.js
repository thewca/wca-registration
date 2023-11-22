const { defineConfig } = require("cypress");

module.exports = defineConfig({
  watchForFileChanges: false,
  e2e: {
    baseUrl: "http://127.0.0.1:3002",
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
  video: true
});
