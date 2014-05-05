class window.Player

  queuedFragments: []
  currentFragment: null
  resumeSecond: 0
  playing: false

  constructor: (url, @container, params = {}) ->
    AudioContext = window.AudioContext || window.webkitAudioContext || window.mozAudioContext;
    @audioContext = new AudioContext()

    # download audio data
    @loadSoundFile(url).then (@soundFileAudioData) =>
      # decode data into a buffer
      @audioContext.decodeAudioData @soundFileAudioData
      , (@soundFileAudioBuffer) => 
        @visualizer = new Visualizer @audioContext, @soundFileAudioBuffer, @container, height: 200
        @visualizer.setSeekHandler @seek
      , ->
        console.error "Unable to decode downloaded audio data."
      
    , (error) ->
      console.error "Unable to load sound file: " + error

    # load annotations
    if params.annotationList?
      @loadJSON(params.annotationList).then (@annotations) =>
        if @annotations?
          console.log @annotations
          console.log "Found " + @annotations.length + " annotation(s)."

        for annotation in @annotations
          do (annotation) =>
            annotation.audioBufferPromise = @loadSoundFile(annotation.sound_file).then (annotationAudioData) =>
              @audioContext.decodeAudioData annotationAudioData
              , (annotationAudioBuffer) =>
                annotation.audioBuffer = annotationAudioBuffer
              , ->
                console.error "Unable to decode annotation recording."
          

        Promise.all(@annotations.map (a) -> a.audioBufferPromise).then =>
          console.log "annotations loaded"
          console.log @annotations
          # visualize annotations


  loadJSON: (url) ->
    @loadResource url, 'json'

  loadSoundFile: (url) ->
    @loadResource url, 'arraybuffer'

  loadResource: (url, responseType) ->
    return new Promise (resolve, reject) ->
      req = new XMLHttpRequest()
      req.open 'GET', url, true
      req.responseType = responseType

      req.onload = ->
        if req.status is 200
          resolve req.response
        else
          reject Error req.statusText

      req.onerror = ->
        reject Error "Network error."

      req.send()


  queueFragments: (start) ->
    console.group "Queuing fragments:"
    console.log "List of annotations:"
    console.log @annotations
    unqueuedAnnotations = @annotations[..]

    # sort annotations in time order
    unqueuedAnnotations.sort (a, b) ->
      a.end_second - b.end_second

    while unqueuedAnnotations.length
      annotation = unqueuedAnnotations.shift()

      if start > annotation.end_second
        continue  # if already past start, ignore this annotation
      else if start == annotation.end_second
        fragment = new Fragment annotation.audioBuffer, start, 0, null
        fragment.setAnnotation annotation
        @queuedFragments.push fragment
      else
        fragment = new Fragment @soundFileAudioBuffer, start, start, annotation.end_second
        @queuedFragments.push fragment
        unqueuedAnnotations.unshift annotation
        start = annotation.end_second

    # queue the rest of the audio file
    @queuedFragments.push new Fragment @soundFileAudioBuffer, start, start, null

    console.log "Queued fragments:"
    console.log @queuedFragments
    console.groupEnd()


  playNextFragment: =>
    console.groupCollapsed "Playing next unplayed fragment"

    if @queuedFragments.length
      @currentFragment = @queuedFragments.shift()
      console.log @currentFragment
      @currentFragment.play @audioContext, @playNextFragment
      @playing = true
    else
      console.log 'No more fragments to play.'
      @resumeSecond = 0
      @playing = false

    console.groupEnd()

  play: =>
    console.group 'In play()'

    @queueFragments @resumeSecond

    debugger

    @playNextFragment()

    if @visualizer?
      @updateVisualizerContinuously()

    console.groupEnd()


  pause: =>
    @resumeSecond = @currentFragment.getCurrentTimeInSoundfile()
    console.log "Going to resume at " + @currentFragment.getCurrentTimeInSoundfile()
    @stopSource()

  stop: =>
    @resumeSecond = 0
    @stopSource()

  stopSource: =>
    @currentFragment.stop()
    @queuedFragments = []

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
    @currentFragment.getCurrentTimeInSoundfile() / @soundFileAudioBuffer.duration


  updateVisualizerContinuously: =>
    @visualizer.setProgress @getPlayedPercentage()

    if @playing
      requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame
      requestAnimationFrame @updateVisualizerContinuously


  seek: (second) =>
    @stopSource()
    @resumeSecond = second
    @play()


class Fragment
  timeStarted: 0

  constructor: (@audioBuffer, @startTimeInSoundfile, @start, @end) ->

  setAnnotation: (@annotation) ->

  play: (@audioContext, callback) ->
    @source = @audioContext.createBufferSource()
    @source.buffer = @audioBuffer
    @source.connect @audioContext.destination
    @source.onended = callback

    console.log "Playing"
    console.log @source
    console.log "from " + @start + " to " + @end

    if @end == null
      @source.start 0, @start
    else
      @source.start 0, @start, @end - @start

    @timeStarted = @audioContext.currentTime

  stop: ->
    try
      @source.stop()
    catch error
      console.error "Error stopping source: " + error

  getTimeElapsed: ->
    @audioContext.currentTime - @timeStarted

  getCurrentTimeInSoundfile: ->
    if @annotation?
      @startTimeInSoundfile
    else
      @startTimeInSoundfile + @getTimeElapsed()


$ ->
  playerDivs = $ '.soundfile-player'

  if not playerDivs.length
    console.debug "No player containers found.  Exiting..."
    return

  playerDivs.each (index, playerDiv) ->
    playerDiv = $ playerDiv

    container = $('<div>').appendTo(playerDiv)[0]
    player = new Player playerDiv.data('audio-src'), container, 
      annotationList: playerDiv[0].dataset.annotationListSrc

    player.setPlayButton $('#play')[0]
    player.setPauseButton $('#pause')[0]
