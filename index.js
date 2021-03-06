// Generated by CoffeeScript 1.9.2
var chokidar, cluster, debounce, whakaruru;

whakaruru = require('whakaruru');

chokidar = require('chokidar');

debounce = require('debounce');

cluster = require('cluster');

module.exports = function(paths, cb) {
  var restart, shutdown, watch;
  whakaruru(cb);
  if (cluster.isWorker) {
    return;
  }
  restart = function() {
    return process.kill(process.pid, 'SIGHUP');
  };
  restart = debounce(restart, 200);
  watch = chokidar.watch(paths, {
    persistent: true,
    ignoreInitial: true,
    cwd: process.cwd()
  });
  watch.on('add', restart);
  watch.on('change', restart);
  shutdown = function() {
    return watch.close();
  };
  process.on('SIGINT', shutdown);
  return process.on('SIGTERM', shutdown);
};
