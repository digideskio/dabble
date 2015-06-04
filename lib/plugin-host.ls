fs     = require \fs
path   = require \path
mkdirp = require \mkdirp
deps   = require "./deps"

class PluginHost
  VERSION: @VERSION = \1
  (folder, @global) ->
    try
      @VERSION = PluginHost.VERSION

      @manifest = require path.resolve folder, "plugin.json"

      @name    = @manifest.name
      @version = @manifest.version
      @origin  = @manifest.origin
      throw new Error "Missing required keys in #{require path.resolve folder, "plugin.json"}" unless @name? and @version? and @origin?

      if @origin[0] == "/" and @origin.substr(-1) == "/"
        @origin = new RegExp(@origin)

      @entry      = path.resolve folder, @manifest.entry || "#{@name}.js"
      @flags      = @manifest.flags || []
      @deps       = @manifest.deps
      @module-dir = void
    catch
      @manifest = void
      throw e
  sane: ->
    throw new Error "Plugin is not valid" unless @manifest?
  match: (url) ->
    @sane!
    url.match @origin
  load: (@module-dir) ->
    @sane!
    require @entry @this
  modules: ->
    path.resolve @module-dir, "#{@name}-#{@version}"
  require: (...) ->
    @sane!
    module.paths.unshift @modules!
    delayed = resp = void
    try
      resp = require.apply this, arguments
    catch
      delayed = e
    finally
      module.paths.shift!
      if delayed?
        throw delayed
      resp
  save: (destination, data, encoding, callback) ->
    @sane!
    out = require.resolve @global.output, destination
    mkdirp out, (e) ->
      callback e if e?
      fs.write-file out, data, encoding, callback
  save-sync: (destination, data, encoding) ->
    @sane!
    out = require.resolve @global.output, destination
    mkdirp.sync out
    fs.write-file-sync out, data, encoding
  exists: (destination, callback) ->
    @sane!
    out = require.resolve @global.output, destination
    fs.exists out, callback
  exists-sync: (destination) ->
    @sane!
    out = require.resolve @global.output, destination
    fs.exists-sync out
  install: (@module-dir, options, callback) ->
    @sane!
    deps @manifest, @module-dir, options, callback

exports = module.exports = PluginHost
