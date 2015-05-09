fs   = require "fs"
path = require "path"
npm  = require "npm"

exports = module.exports = (plugin-manifest, plugin-modules, force-overwrite, callback) ->
  if not plugin-manifest.deps?
    return process.next-tick callback

  plugin-deps  = path.join plugin_modules, "#{plugin-manifest.name}-#{plugin-manifest.version}"
  dependencies = []

  Object.keys(plugin-manifest.deps).map (key) ->
    if not fs.exists-sync path.resolve(plugin-deps, "node_modules", key) or force-overwrite
      # this is not documented in the npm api docs
      # module@version-tag
      dependencies.push "#{key}@#{plugin-manifest.deps[key]}"

  npm.load (err, npm) ->
    if dependencies.length > 0
      # npm.commands.install writes to stdout, idk why but whatever.
      # npm has a shitty api.
      # TODO figure out a way to block stdout
      npm.commands.install plugin-deps, dependencies, callback
