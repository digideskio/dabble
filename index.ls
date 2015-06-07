require! "nomnom"
require! "./package.json": pkg
require! "./lib/dabble": Dabble

dabble = new Dabble

plugin-list = require("./commands/list") dabble
nomnom
  ..option 'version', do
      abbr: 'v'
      help: 'print version'
      flag: true
      callback: !->
        return "#{pkg.name} v#{pkg.version}"
  ..script pkg.name
  ..help plugin-list
  ..command 'list'
    ..help 'list plugins'
    ..callback ->
      console.log "\n#{plugin-list}"
  ..command 'info'
    ..option "plugin", do
      position: 0
      required: true
      help: "plugin to show info of"
    ..help 'print info about a plugin'
    ..callback (plugin) !->
      # TODO
      require("./commands/info") dabble plugin
  ..command 'download'
    ..option 'plugin', do
      position: 0
      required: true
      help: "plugin to download with"
      default: "auto"
    ..option 'urls', do
      position: 1
      list: true
      required: true
      help: "list of URLs to download"
    ..option 'out-dir', do
      abbr: 'o'
      help: 'root directory of where to save files to'
    ..option 'dry', do
      abbr: 'n'
      help: 'perform a dry run (does not save files)'
    ..option 'force', do
      abbr: 'f'
      help: 'force install dependencies'
    ..option 'overwrite', do
      abbr: 'F'
      help: 'overwrite over existing files'
    ..option 'downloads', do
      abbr: 'd'
      help: 'max number of concurrent downlods'
    ..help 'download files of given URL'
    ..callback !->
      args = Array::slice.call arguments
      args.unshift dabble
      require("./commands/download").apply null, args

program = nomnom.nom!
