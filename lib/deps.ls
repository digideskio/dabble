fs   = require "fs"
path = require "path"
npm  = require "npm"

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
    if not fs.exists-sync path.resolve(plugin-deps, "node_modules", key) or options.force-overwrite
      # this is not documented in the npm api docs
      # module@version-tag
      dependencies.push "#{key}@#{plugin-manifest.deps[key]}"

  plugin-log = if options.output-log?
    options.output-log
  else
    path.join plugin-modules, "#{plugin-manifest.name}-#{plugin-manifest.version}-#{Date.now}.log"

  unless options.output-log == false
    log-stream = fs.create-write-stream plugin-log
  else
    log-stream = NULLSTREAM

  npm.load do
    loglevel: "silent"
    logstream: log-stream
    , (err, npm) ->
      if dependencies.length > 0
        npm.commands.install plugin-deps, dependencies, callback
