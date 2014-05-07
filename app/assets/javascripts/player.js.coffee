class window.Player

  queuedFragments: []
  currentFragment: null
  resumeSecond: 0
  playing: false

  constructor: (url, @container, params = {}) ->
    console.group "Player init"

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
          console.log @annotations
          # TODO: visualize annotations

    console.groupEnd "Player init"


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
    console.group "Queuing fragments from " + start

    @queuedFragments = []

    console.log "List of annotations:"
    console.log @annotations
    unqueuedAnnotations = @annotations[..]

    # sort annotations in time order
    unqueuedAnnotations.sort (a, b) ->
      a.end_second - b.end_second

    cursor = start

    while unqueuedAnnotations.length
      annotation = unqueuedAnnotations.shift()

      if cursor > annotation.end_second
        continue  # if already past cursor, ignore this annotation
      else if cursor == annotation.end_second
        fragment = new Fragment annotation.audioBuffer, cursor, 0, null
        fragment.setAnnotation annotation
        @queuedFragments.push fragment
      else
        fragment = new Fragment @soundFileAudioBuffer, cursor, cursor, annotation.end_second
        @queuedFragments.push fragment
        unqueuedAnnotations.unshift annotation
        cursor = annotation.end_second

    # queue the rest of the audio file
    @queuedFragments.push new Fragment @soundFileAudioBuffer, cursor, cursor, null

    console.log "Queued fragments:"
    console.log @queuedFragments
    console.groupEnd()


  playNextFragment: =>
    console.group "Playing next unplayed fragment"
    if !@playing
      console.log "State is 'not playing', halting..."
      return

    if @queuedFragments.length
      @currentFragment = @queuedFragments.shift()
      console.log @currentFragment
      @currentFragment.play @audioContext, @playNextFragment
    else
      console.log 'No more fragments to play.'
      @resumeSecond = 0
      @playing = false

    console.groupEnd()

  play: =>
    console.group 'In play()'
    @queueFragments @resumeSecond
    # debugger
    @playing = true
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
    @playing = false

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
    console.debug "seek: " + second

    @stopSource()


    # XXX dirty work around--
    # I don't understand why adding the timeout would make it work
    setTimeout =>
      @resumeSecond = second
      @play()
    , 100


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
      @source.start 0, @start, (@end - @start)

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
    # console.debug "No player containers found.  Exiting..."
    return

  playerDivs.each (index, playerDiv) ->
    playerDiv = $ playerDiv

    container = $('<div>').appendTo(playerDiv)[0]
    player = new Player playerDiv.data('audio-src'), container, 
      annotationList: playerDiv[0].dataset.annotationListSrc

    player.setPlayButton $('#play')[0]
    player.setPauseButton $('#pause')[0]
