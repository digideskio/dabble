require! <[ fs path mkdirp request async ./deps ./dabble ]>

class PluginHost
  VERSION: @VERSION = \1
  (folder, @engine) ->
    try
      @VERSION = PluginHost.VERSION

      @manifest = require path.resolve folder, "plugin.json"

      @name        = @manifest.name
      @description = @manifest.description
      @version     = @manifest.version
      @origin      = @manifest.origin
      throw new Error "Missing required keys in #{require path.resolve folder, "plugin.json"}" unless @name? and @version? and @origin?

      if @origin[0] == "/" and @origin.substr(-1) == "/"
        @origin = new RegExp(@origin)

      @entry      = path.resolve folder, @manifest.entry || "#{@name}.js"
      @flags      = @manifest.flags || []
      @deps       = @manifest.deps
      @module-dir = void
      @queue      = async.queue (task, callback) ~>
        @process task, callback
      @queue.concurrent = 1
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
    @sane!
    path.resolve @module-dir, "#{@name}-#{@version}"
  require: (...) ->
    @sane!
    module.paths.unshift @modules!
    delayed = void
    resp    = void
    try
      resp = require.apply this, arguments
    catch
      delayed = e
    finally
      if module.paths[0] == @modules!
        module.paths.shift!
      if delayed?
        throw delayed
      resp
  save: (destination, data, encoding, callback) ->
    @sane!
    out = require.resolve @engine.output, destination
    mkdirp out, (e) ->
      callback e if e?
      fs.write-file out, data, encoding, callback
  save-sync: (destination, data, encoding) ->
    @sane!
    out = require.resolve @engine.output, destination
    mkdirp.sync out
    fs.write-file-sync out, data, encoding
  process: (task, callback) !->
    @sane!
    switch task.type
      case \download
        @download task.options, task.path, callback
      case \border
        callback!
  download: (options, stream, callback) ->
    @sane!
    request(options).pipe(stream)
    stream.on \close, callback
    stream.on \end, callback
  download-file: (options, destination, callback) ->
    @sane!
    destination = require.resolve @engine.output, destination
    console.log "Downloading #{options.url || options} to #{path}..."
    @download options, fs.create-write-stream(path), callback
  downlaod-buffer: (options, callback) ->
    @sane!
    console.log "Loading #{options.url || options}..."
    options.encoding = null
    request options, (e, im, r) ->
      callback e, r
  stage: (options, destination) ->
    @sane!
    destination = require.resolve @engine.output, destination
    @queue.resume! if @queue.paused
    @queue.push {type: \download, options: options, path: destination}, ->
  border: (callback) ->
    @sane!
    @queue.resume! if @queue.paused
    @queue.push {type: \border}, ->
      @queue.pause!
      callback
  pause: ->
    @sane!
    @queue.pause!
  resume: ->
    @sane!
    @queue.resume!
  exists: (destination, callback) ->
    @sane!
    out = require.resolve @engine.output, destination
    fs.exists out, callback
  exists-sync: (destination) ->
    @sane!
    out = require.resolve @engine.output, destination
    fs.exists-sync out
  install: (@module-dir, options, callback) ->
    @sane!
    deps @manifest, @module-dir, options, callback

exports = module.exports = PluginHost
