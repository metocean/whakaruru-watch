whakaruru = require 'whakaruru/verbose'
chokidar = require 'chokidar'
debounce = require 'debounce'
cluster = require 'cluster'

module.exports = (paths, cb) ->
  whakaruru cb
  return if cluster.isWorker

  restart = -> process.kill process.pid, 'SIGHUP'
  restart = debounce restart, 500

  console.log "#{process.pid} Tāti mātaki"
  watch = chokidar.watch paths,
    persistent: yes
    ignoreInitial: yes
    cwd: process.cwd()
  watch.on 'add', (file) ->
    console.log "#{process.pid} Tāpiri #{file}"
    restart()
  watch.on 'change', (file) ->
    console.log "#{process.pid} Kōrure #{file}"
    restart()

  shutdown = ->
    console.log "#{process.pid} Kati mātaki"
    watch.close()
  process.on 'SIGINT', shutdown
  process.on 'SIGTERM', shutdown
