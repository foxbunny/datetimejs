module.exports = {
  source: {
    include: './src',
    includePattern: '\\.js$',
    excludePattern: '\\.test.js$',
  },
  plugins: [
    "plugins/markdown",
  ],
  opts: {
    readme: './README.md',
    template: 'node_modules/docdash',
    destination: './docs',
  },
};
