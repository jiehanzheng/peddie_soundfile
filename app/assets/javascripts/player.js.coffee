class window.Player

  playing: false
  playedSeconds: 0
  lastPauseSecond: 0
  lastStartedTime: 0

  constructor: (url, @container, params = {}) ->
    AudioContext = AudioContext || webkitAudioContext;
    @audioContext = new AudioContext()

    # download audio data
    @loadSoundFile(url).then (@audioData) => 
      # decode data into a buffer
      @audioContext.decodeAudioData @audioData
      , (@audioBuffer) => 
        @visualizer = new Visualizer @audioContext, @audioBuffer, @container, height: 200
        @ready = true
      , ->
        console.error "Unable to decode downloaded audio data."
      
    , (error) ->
        console.error "Unable to load sound file: " + error


  loadSoundFile: (url) ->
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


  play: =>
    if @playing
      @stop()

    unless @audioBuffer?
      return

    @source = @audioContext.createBufferSource()
    @source.buffer = @audioBuffer
    @source.connect @audioContext.destination
    @source.start 0, @lastPauseSecond  # play now from "" in the buffer
    @lastStartedTime = @audioContext.currentTime
    @playing = true

    @updateVisualizerContinuously()


  pause: =>
    # record pause time
    @lastPauseSecond = @getPlayedSeconds()

    @stopSource()
    @playing = false


  stop: =>
    @stopSource()
    @lastPauseSecond = 0
    @playing = false


  stopSource: ->
    try
      @source.stop()
    catch error
      console.error "Error stopping source: " + error


  getPlayedSeconds: =>
    if @playing
      @lastPauseSecond + (@audioContext.currentTime - @lastStartedTime)
    else
      @lastPauseSecond


  setPlayButton: (element) ->
    @playButton = element
    @playButton.onclick = @play


  setPauseButton: (element) ->
    @pauseButton = element
    @pauseButton.onclick = @pause


  getPlayedPercentage: ->
    @getPlayedSeconds() / @audioBuffer.duration


  updateVisualizerContinuously: =>
    @visualizer.setProgress @getPlayedPercentage()

    if @playing
      requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame
      requestAnimationFrame @updateVisualizerContinuously


$ ->
  playerDivs = $ '.soundfile-player'

  if not playerDivs.length
    console.debug "No player containers found.  Exiting..."
    return

  playerDivs.each (index, playerDiv) ->
    playerDiv = $ playerDiv
    
    container = $('<div>').appendTo(playerDiv)[0]
    player = new Player playerDiv.data('audio-src'), container

    player.setPlayButton $('#play')[0]
    player.setPauseButton $('#pause')[0]
