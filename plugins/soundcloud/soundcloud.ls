try
  secrets = require './secrets.json'
catch
  secrets = {client_id: void}

const BASE_URI    = 'https://api.soundcloud.com'
const RESOLVE_URI = BASE_URI + '/resolve?url='

download = (host, tracks) ->
  tracks.for-each (track) !->
    return unless track?
    name = "#{track.user.permalink}/#{track.title}.#{track.original_format}"
    host.prog
    host.stage {url: track.download_url || "#{track.stream_url}?client_id=#{secrets.client_id}"}, name

exports = module.exports = (host) ->
  secrets.client_id ||= host.get-args!client-id

  unless secrets.client_id?
    console.log "Please provide a client id by supplying the --client-id variable."
    process.exit(1)
    return

  next = (urls) ->
    return if urls.length == 0
    url = urls.shift!
    host.download-buffer "#{RESOLVE_URI}#{encode-URI-component url}&client_id=#{secrets.client_id}", (error, data) ->
      data = JSON.parse data
      if 'errors' of data and data.errors.length > 1
        data.errors.for-each (error) !->
          host.log void, void, "#{url} #{error.error_message}"
      else
        if data.kind == 'track'
          download host, [data]
        else if 'tracks' of data
          download host, data.tracks
        else if 'track' of data
          download host, [data.track]
      host.border ->
        next urls
  next host.get-urls!
