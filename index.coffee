whakaruru = require 'whakaruru'
chokidar = require 'chokidar'
debounce = require 'debounce'
cluster = require 'cluster'

module.exports = (paths, cb) ->
  whakaruru cb
  return if cluster.isWorker

  restart = -> process.kill process.pid, 'SIGHUP'
  restart = debounce restart, 200

  watch = chokidar.watch paths,
    persistent: yes
    ignoreInitial: yes
    cwd: process.cwd()
  watch.on 'add', restart
  watch.on 'change', restart

  shutdown = -> watch.close()
  process.on 'SIGINT', shutdown
  process.on 'SIGTERM', shutdown
