fs   = require "fs"
path = require "path"
npm  = require "npm"

const NULLSTREAM = fs.create-write-stream "/dev/null"

exports = module.exports = (plugin-manifest, plugin-modules, force-overwrite, callback) ->
  if not plugin-manifest.deps?
    return process.next-tick callback

  plugin-deps  = path.join plugin-modules, "#{plugin-manifest.name}-#{plugin-manifest.version}"
  dependencies = []

  Object.keys(plugin-manifest.deps).map (key) ->
    if not fs.exists-sync path.resolve(plugin-deps, "node_modules", key) or force-overwrite
      # this is not documented in the npm api docs
      # module@version-tag
      dependencies.push "#{key}@#{plugin-manifest.deps[key]}"

  npm.load do
    loglevel: "silent"
    logstream: NULLSTREAM
    , (err, npm) ->
      if dependencies.length > 0
        npm.commands.install plugin-deps, dependencies, callback
