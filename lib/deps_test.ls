require! "./plugin-host"

host = new plugin-host "../plugins/danbooru"

host.install "../plugin_modules/", false, ->
  console.log arguments
