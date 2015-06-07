require! \chalk
exports = module.exports = (dabble, plugin-name) ->
  plugin = dabble.plugins[plugin-name.to-lower-case!]

  return console.log chalk.red "Error: the plugin `#{plugin-name}` is not installed!\nRun command `list` to see available plugins!" unless plugin?

  output = [chalk.magenta "#{plugin-name}:"]

  lines = [
    [\description, plugin.description],
    [\version, plugin.version],
    ['match site', plugin.origin]
  ]

  n = 0
  for line in lines
    if line[0].length > n
      n = line[0].length
  for line in lines
    str = line[0]
    while str.length < n
      str = str + ' '
    output.push "   #{str}     #{chalk.grey line[1]}"

  output.push ''

  output.push chalk.blue 'Options:'

  lines = []
  for flag in plugin.flags
    f = flag.slice(0, flag.length - 2).join ', '
    h = flag[flag.length - 1]
    lines.push [f, h]
  if lines.length == 0
    output.pop!
    output.pop!
  else
    for line in lines
      if line[0].length > n
        n = line[0].length
    for line in lines
      str = line[0]
      while str.length < n
        str = str + ' '
      output.push "   #{str}     #{chalk.grey line[1]}"

  output.push ''

  output.push chalk.blue 'Dependencies:'

  lines = []
  for dep of plugin.deps
    v = plugin.deps[dep]
    lines.push [dep, v]
  if lines.length == 0
    output.pop!
    output.pop!
  else
    for line in lines
      if line[0].length > n
        n = line[0].length
    for line in lines
      str = line[0]
      while str.length < n
        str = str + ' '
      output.push "   #{str}     #{chalk.grey line[1]}"

  output.push ''

  console.log output.join '\n'
