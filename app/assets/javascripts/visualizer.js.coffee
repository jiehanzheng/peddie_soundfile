class window.Visualizer

  width: 0
  height: 0

  # logical pixels per second
  zoom: 60

  # audio samples per logical pixel
  sppx: 1


  constructor: (@audioContext, @audioBuffer, @container, params = {}) ->
    console.group "Visualizer init"

    # create wrapper to accomplish scrolling and mouse event handling
    @wrapper = document.createElement 'wave-visualizer'
    @wrapper.style.display = 'block'
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
    @waveCanvasContext = @waveCanvas.getContext '2d'
    @wrapper.appendChild @waveCanvas

    # wrapper for progress wave for covering up unplayed part
    @progressWrapper = document.createElement 'div'
    @progressWrapper.style.width = '0'
    @progressWrapper.style.height = @height + 'px'
    @progressWrapper.style.position = 'absolute'
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
    @width = @numberOfSamples
    @height = params.height

    @resizeCanvases()
    @draw()

    # set up click handler for click-to-seek or add annotation
    # TODO: add annotation
    @wrapper.addEventListener 'mousedown', (e) =>
      if @seekHandler?
        percentageInContainer = e.offsetX / @width
        if percentageInContainer >= 0 and percentageInContainer <= 1
          @seekHandler percentageInContainer * @audioDuration

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

    console.groupEnd "draw"


  setProgress: (percentage) ->
    @progressWrapper.style.width = @width / @sppx * percentage + 'px'
    

  resizeCanvases: ->
    # determine properties of ua
    @sppx = window.devicePixelRatio
    @canvasBackingStorePixelRatio = @waveCanvasContext.backingStorePixelRatio || @waveCanvasContext.webkitBackingStorePixelRatio || @waveCanvasContext.mozBackingStorePixelRatio || 1

    console.log "resizeCanvases: width = " + @width + ", height = " + @height + ", sppx = " + @sppx

    # if desired sppx doesn't match backing store pixel ratio, manually upscale canvas
    rescaleRatio = @sppx/@canvasBackingStorePixelRatio

    @wrapper.style.height = @height + 'px'
    @progressWrapper.style.height = @height + 'px'

    for canvas in @canvases
      # dom dimensions
      canvas.height = @height * rescaleRatio
      canvas.width = @width * rescaleRatio

      # css dimensions
      canvas.style.height = @height + 'px'
      canvas.style.width = @width + 'px'


  setSeekHandler: (@seekHandler) ->

