fs     = require "fs"
path   = require "path"
npm    = require "npm"
mkdirp = require 'mkdirp' .sync
spawn  = require 'child_process' .exec-sync

const NULLSTREAM = fs.create-write-stream "/dev/null"

exports = module.exports = (plugin-manifest, plugin-modules, options, callback) ->
  unless plugin-manifest.deps?
    return process.next-tick callback
  unless callback?
    if typeof options == "function"
      callback = options
      options = {}

  plugin-deps  = path.join plugin-modules, "#{plugin-manifest.name}-#{plugin-manifest.version}"
  dependencies = []

  Object.keys(plugin-manifest.deps).map (key) ->
    if not fs.exists-sync path.resolve(plugin-deps, key) or options.force-overwrite
      # this is not documented in the npm api docs
      # module@version-tag

      spawn "rm -rf #{plugin-deps}/#{key} #{plugin-deps}/node_modules/#{key}"
      dependencies.push "#{key}@#{plugin-manifest.deps[key]}"

  plugin-log = if options.output-log?
    options.output-log
  else
    mkdirp path.join plugin-modules, "/.logs"
    path.join plugin-modules, "/.logs/#{plugin-manifest.name}-#{plugin-manifest.version}-install.log"

  mkdirp plugin-deps

  unless options.output-log == false
    log-stream = fs.create-write-stream plugin-log
  else
    log-stream = NULLSTREAM

  npm.load do
    loglevel:   "info"
    logstream:  log-stream
    bin-links:  false
    dev:        false
    global:     false
    production: true
    heading:    ''
    color:      false
    , (err, npm) ->
      if dependencies.length > 0
        console.log "Installing modules for #{plugin-manifest.name}..."

        # NPM uses console.log to write the dependency tree, we don't want to
        # print that, and it doesn't have an option to suppress it.
        # Why am i surprised.
        # Detour console.log
        console-log = console.log
        console.log = ->
          log-stream.write Array::join.call arguments, ' '
          log-stream.write '\n'

        npm.commands.install plugin-deps, dependencies, ->
          npm.commands.dedup ->
            console.log = console-log # restore console.log
            spawn "mv #{plugin-deps}/node_modules/* #{plugin-deps}/"
            spawn "rm -rf #{plugin-deps}/node_modules"
            unless options.output-log == false
              log-stream.end!
            callback plugin-deps
      else
        unless options.output-log == false
          log-stream.end!
        callback plugin-deps
