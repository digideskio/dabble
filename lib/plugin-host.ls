require! <[ fs path mkdirp request async ./deps ./dabble ]>

const CURSOR_UP  = '\x1b[1A',
      ERASE_LINE = '\x1b[2K'

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
      @nargs      = {}
    catch
      @manifest = void
      throw e
  sane: ->
    throw new Error "Plugin is not valid" unless @manifest?
  match: (url) ->
    @sane!
    url.match @origin
  # format [switch, switch, switch..., type, help]
  args: ->
    flags = ^^@flags
    args = {}
    while flags.length
      flag = flags.shift!
      flag.pop! # last index is always the help string

      type = flag.pop!to-lower-case!
      f = flag
      value = void
      for i of f
        l = f[i]
        while l[0] == '-'
          l = l.substr(1)
          value = @nargs[l] if @nargs[l]?
        f[i] = l

      if value?
        value = switch type
          case \number
            parse-int v
          case \flag
            if ['yes', 'true', 'on', '1', 'one'].index-of(value.to-lower-case!) > -1
              true
            else
              false
          default
            value
        z = f[f.length - 1].split /\-/
        for x of z
          if x > 0
            z[x] = z[x].substr(0, 1).to-upper-case! + z[x].substr(1)
        z .= join ''
        args[z] = value
    @args = args
    args
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
    @log options.url || options, path
    @download options, fs.create-write-stream(path), ~>
      @progress!
      callback ...
  download-buffer: (options, callback) ->
    @sane!
    @log void, void, "Loading #{options.url || options}..."
    options.encoding = null
    request options, (e, im, r) ->
      callback e, r
  print: (text) ->
    if @prog?
      if @prog.total > @prog.current
        process.stdout.write '\r'
        process.stdout.write ERASE_LINE + CURSOR_UP + ERASE_LINE
        process.stdout.write "#{text}\n\n"
        @print-progress!
        return
      process.stdout.write '\n'
    process.stdout.write "#{text}\n"
  progress: ->
    @prog ||= do
      total:   1
      current: 0
      active:  false

    @prog.current++

    @print-progress!
  clear-progress: ->
    process.stdout.write '\n'
    @prog = void
  print-progress: (header) ->
    if @prog.active
      process.stdout.write '\r'
      process.stdout.write ERASE_LINE + CURSOR_UP + ERASE_LINE
    @prog.active = true

    tail  = "](#{@prog.current}/#{@prog.total})"
    width = process.stdout.get-window-size![0] - tail.length - 1
    if @prog.current > @prog.total
      @prog.current = @prog.total

    each = Math.floor width / @prog.total
    if each == 0
      @prog.total   -= @prog.current
      @prog.current  = 0
      @prog.active   = false
      return @print-progress!

    pos = 0
    for i from 0 til @prog.current
      pos += each

    pos = Math.floor pos

    unless header?
      header = @prog.last || 'Teapot'
    @prog.last = header

    process.stdout.write "\r#{header}\n["

    for i from 0 til pos
      process.stdout.write '='
    for i from pos til width
      process.stdout.write ' '

    process.stdout.write tail
  log: (url, destination, print) ->
    if print?
      return @print print

    @prog ||= do
      total:   0
      current: 0
      active:  false

    @prog.total++

    @print-progress url
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
