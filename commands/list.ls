require! \chalk
exports = module.exports = (dabble) ->
  plugins = [/* name version description */]
  max     = 0
  for plugin of dabble.plugins
    plugin = dabble.plugins[plugin]
    plugins.push [plugin.name, plugin.description]
    max = Math.max(max, plugin.name.length)

  output = [chalk.magenta 'Available plugins:']

  while plugins.length
    plugin = plugins.shift!
    name = plugin[0];
    while(name.length < max)
      name += ' '
    output.push "  #{[name, chalk.grey plugin[1]].join '    '}"
  output.push ''
  output.join '\n'
