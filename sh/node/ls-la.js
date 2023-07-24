const shell = require('shelljs');

const result = shell.exec('ls -la');

console.log(result.stdout);
