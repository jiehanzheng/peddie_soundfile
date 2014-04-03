class window.Player
  constructor: (url, @container, params = {}) ->
    AudioContext = AudioContext || webkitAudioContext;
    @audioContext = new AudioContext()

    # decode audio data to a buffer
    loadSoundFile(url).then (@audioData) => 
      @visualizer = new Visualizer @audioContext, @audioData, @container,
        height: 200
      
    , (error) ->
        console.error "Unable to load sound file: " + error


  loadSoundFile = (url) ->
    return new Promise (resolve, reject) ->
      req = new XMLHttpRequest()
      req.open 'GET', url, true
      req.responseType = "arraybuffer";

      req.onload = ->
        if req.status is 200
          resolve req.response
        else
          reject Error req.statusText

      req.onerror = ->
        reject Error "Network error."

      req.send()


$ ->
  playerDivs = $ '.soundfile-player'

  if not playerDivs.length
    console.debug "No player containers found.  Exiting..."
    return

  playerDivs.each (index, playerDiv) ->
    playerDiv = $ playerDiv
    
    container = $('<div>').appendTo(playerDiv)[0]
    visualizer = new Player playerDiv.data('audio-src'), container
