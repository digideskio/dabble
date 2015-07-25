require! path

unless String::test?
  String::test = (string) ->
    string.index-of(this) > -1

exports = module.exports = (dabble, args) ->
  if args.plugin == 'auto'
    for plugin of dabble.plugins
      plugin = dabble.plugins[plugin]
      if plugin.origin.test args.urls[0]
        args.plugin = plugin.name
        break
  args.plugin .= to-lower-case!
  plugin = dabble.plugins[args.plugin]
  throw new Error("Could not find plugin #{args.plugin}") unless plugin?
  plugin.nargs = args
  plugin.install path.resolve(__dirname, '..', 'plugin_modules'), (dir) ->
    plugin.load dir
