class window.Visualizer

  height: 0

  # logical pixels per second
  zoom: 60

  # audio samples per logical pixel
  sppx: 1


  constructor: (@audioContext, @audioBuffer, @container, params = {}) ->
    console.group "Visualizer init"

    # create wrapper to accomplish scrolling
    @wrapper = document.createElement 'div'
    @wrapper.style.position = 'relative'
    @wrapper.style.width = '100%'
    @wrapper.style.height = @height + 'px'
    @wrapper.style.userSelect = 'none'
    @wrapper.style.overflowX = 'scroll'
    @container.appendChild @wrapper

    # create wave canvas for wave for the file
    @waveCanvas = document.createElement 'canvas'
    @waveCanvas.style.position = 'absolute'
    @waveCanvas.style.zIndex = 1
    @waveCanvas.style.top = '0'
    @waveCanvasContext = @waveCanvas.getContext '2d'
    @wrapper.appendChild @waveCanvas

    # wrapper for progress wave for covering up unplayed part
    @progressWrapper = document.createElement 'div'
    @progressWrapper.style.width = '0'
    @progressWrapper.style.height = @height + 'px'
    @progressWrapper.style.position = 'absolute'
    @progressWrapper.style.top = '0'
    @progressWrapper.style.zIndex = 2
    @progressWrapper.style.overflow = 'hidden'
    @progressWrapper.style.borderRight = '2px solid red'
    @wrapper.appendChild @progressWrapper

    # progress canvas in a different color, visible only after played
    @progressCanvas = document.createElement 'canvas'
    @progressCanvasContext = @progressCanvas.getContext '2d'
    @progressWrapper.appendChild @progressCanvas
    
    @canvases = [@waveCanvas, @progressCanvas]
    @resizeCanvases()
    
    # get audio properties
    @audioDuration = @audioBuffer.duration
    @numberOfSamples = Math.floor(@audioDuration * @zoom * @sppx)
    @sampleSize = Math.floor(@audioBuffer.length / @numberOfSamples)

    # dimensions
    @height = params.height

    @resizeCanvases()
    @draw()

    # set up click handler for click-to-seek
    @wrapper.addEventListener 'mousedown', (e) =>
      if @seekHandler?
        percentageInContainer = e.offsetX / @wrapper.scrollWidth
        if percentageInContainer >= 0 and percentageInContainer <= 1
          @seekHandler percentageInContainer * @audioDuration

    # mouse-following needle events
    @wrapper.addEventListener 'mousemove', (e) =>
      @needle.style.left = e.offsetX + 'px'
      @needleLabel.style.left = (e.offsetX - 12) + 'px'
      @needleLabel.innerHTML = (@audioDuration * (e.offsetX / @wrapper.scrollWidth)).toFixed(2) + 's'

    # mouse-following indicator needle
    @needle = document.createElement 'div'
    @needle.style.width = '1px'
    @needle.style.height = (@height - 20) + 'px'
    @needle.style.position = 'absolute'
    @needle.style.zIndex = 3
    @needle.style.backgroundColor = '#999'
    @needle.style.top = '0'
    @needle.style.left = '-100px'
    @needle.style.pointerEvents = 'none'
    @wrapper.appendChild @needle

    # mouse-following timestamp label
    @needleLabel = document.createElement 'div'
    @needleLabel.style.position = 'absolute'
    @needleLabel.zIndex = 3
    @needleLabel.style.top = (@height - 20) + 'px'
    @needleLabel.style.left = '0px'
    @needleLabel.style.pointerEvents = 'none'
    @wrapper.appendChild @needleLabel

    console.groupEnd "Visualizer init"


  draw: ->
    # consider only left channel for now
    @points = @audioBuffer.getChannelData(0)
    
    console.group "draw"
    console.log "Goal: " + @numberOfSamples + " sample values from " + @points.length + " points"

    @waveCanvasContext.strokeStyle = '#2A2522'
    @waveCanvasContext.beginPath()

    @progressCanvasContext.strokeStyle = '#526D75'
    @progressCanvasContext.beginPath()

    canvasX = 0.5

    # Math.max.apply cannot be used here because of 
    # Uncaught RangeError: Maximum call stack size exceeded 
    console.time "Finding max"
    max = 0
    for i in [0..@points.length]
      if @points[i] > max
        max = @points[i]

    console.timeEnd "Finding max"

    # only allow canvas to be 60% filled
    amplitudeScalingFactor = ((@height / 2) * 0.6) / max
    console.log "max = " + max + ", amplitudeScalingFactor = " + amplitudeScalingFactor

    console.time "Sampling and drawing on canvas"
    # loop through summary @points we want to produce and visualize
    for sampleId in [0...@numberOfSamples]
      # find corresponding start/end positions in audio file for this point
      start = sampleId * @sampleSize
      end = start + @sampleSize

      # find highest absolute value within this range
      pointsInRange = @points.subarray start, end + 1
      pointsInRangeAbs = (Math.abs(x) for x in pointsInRange)
      absMax = Math.max.apply null, pointsInRangeAbs
      
      # if @sppx > 1, only stretch vertically to fit canvas, 
      # since we are plotting more points horizontally
      verticalStretch = @sppx

      # now draw lines
      @waveCanvasContext.moveTo canvasX, (@height/2 - absMax * amplitudeScalingFactor) * verticalStretch
      @waveCanvasContext.lineTo canvasX, (@height/2 + absMax * amplitudeScalingFactor) * verticalStretch
      @progressCanvasContext.moveTo canvasX, (@height/2 - absMax * amplitudeScalingFactor) * verticalStretch
      @progressCanvasContext.lineTo canvasX, (@height/2 + absMax * amplitudeScalingFactor) * verticalStretch

      canvasX++

    @waveCanvasContext.closePath()
    @waveCanvasContext.stroke()

    @progressCanvasContext.closePath()
    @progressCanvasContext.stroke()
    console.timeEnd "Sampling and drawing on canvas"

    console.groupEnd()


  setProgress: (percentage) ->
    @progressWrapper.style.width = @wrapper.scrollWidth * percentage + 'px'


  ensureProgressIndicatorVisibility: =>
    if @progressWrapper.clientWidth < @wrapper.scrollLeft or  # left, off screen
    @progressWrapper.clientWidth > (@wrapper.scrollLeft + @wrapper.clientWidth * 0.8)  # right, off screen
      @wrapper.scrollLeft = @progressWrapper.clientWidth


  resizeCanvases: ->
    # determine properties of ua
    @sppx = window.devicePixelRatio
    console.log "resizeCanvases: height = " + @height + ", sppx = " + @sppx

    @wrapper.style.height = @height + 'px'
    @progressWrapper.style.height = @height + 'px'

    for canvas in @canvases
      # dom dimensions
      canvas.height = @height * @sppx
      canvas.width = @numberOfSamples

      # css dimensions
      canvas.style.height = @height + 'px'
      canvas.style.width = (@numberOfSamples / @sppx) + 'px'


  setSeekHandler: (@seekHandler) ->

