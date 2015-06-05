exports = module.exports = (dabble) ->
  plugins = [/* name version description */]
  max     = [6, 9]
  for plugin of dabble.plugins
    plugin = dabble.plugins[plugin]
    plugins.push [plugin.name, plugin.version, plugin.description]
    max[0] = Math.max(max[0], plugin.name.length + 2)
    max[1] = Math.max(max[1], plugin.version.length + 2)

  name        = 'Name'
  version     = 'Version'
  description = 'Description'

  while(name.length < max[0] - 1)
    name += ' '

  while(version.length < max[1] - 1)
    version += ' '

  output = ['\033[0;34mAvailable plugins:\033[0m']

  header = [name, version, description].join ' | '
  output.push "  \033[1m#{header}\033[0m"

  while plugins.length
    plugin = plugins.shift!
    name = plugin[0];
    while(name.length < max[0])
      name += ' '
    version = plugin[1]
    while(version.length < max[1])
      version += ' '
    output.push "  #{[name, version, plugin[2]].join '| '}"
  output.push ''
  output.join '\n'
