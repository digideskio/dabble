require! <[ path fs ./plugin-host ]>
class dabble
  (@output = path.resolve __dirname, "out") ->
    @plugins = {}
    @plugin-dir = path.resolve __dirname, "..", "plugins"

    p = fs.readdir-sync @plugin-dir
    while p.length
      try
        plugin = new plugin-host path.join(@plugin-dir, p.shift!), this
        @plugins[plugin.name] = plugin
    p = void

exports = module.exports = dabble
