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
      position: 1
      required: true
      help: "plugin to show info of"
    ..help 'print info about a plugin'
    ..callback (args) !->
      require("./commands/info") dabble, args.plugin, args
  ..command 'download'
    ..option 'plugin', do
      position: 1
      required: true
      help: "plugin to download with"
    ..option 'urls', do
      position: 2
      list: true
      required: true
      help: "list of URLs to download"
    ..option 'out-dir', do
      abbr: 'o'
      help: 'root directory of where to save files to'
      type: 'string'
    ..option 'dry', do
      abbr: 'n'
      help: 'perform a dry run (does not save files)'
      flag: true
      defalut: false
    ..option 'force', do
      abbr: 'f'
      help: 'force install dependencies'
      flag: true
      defalut: false
    ..option 'overwrite', do
      abbr: 'F'
      help: 'overwrite over existing files'
      flag: true
      defalut: false
    ..option 'downloads', do
      abbr: 'd'
      help: 'max number of concurrent downlods'
      type: 'number'
      default: 5
    ..help 'download files of given URL'
    ..callback (args) !->
      require("./commands/download") dabble, args

program = nomnom.nom!
