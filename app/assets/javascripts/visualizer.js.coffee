class window.Visualizer

  # logical pixels per second
  zoom: 8

  # audio samples per logical pixel
  sppx: 1

  # 

  constructor: (@audioContext, @audioData, @container, params = {}) ->
    # dimensions
    @height = params.height
    @width = 1000

    # create wave canvas for wave for the file
    @waveCanvas = document.createElement 'canvas'
    @waveCanvas.style.position = 'absolute'
    @waveCanvas.style.zIndex = 1
    @waveCanvasContext = @waveCanvas.getContext '2d'
    @container.appendChild @waveCanvas

    # wrapper for progress wave for covering up unplayed part
    @progressWrapper = document.createElement 'div'
    @progressWrapper.style.position = 'absolute'
    @progressWrapper.style.zIndex = 2
    @progressWrapper.style.overflow = 'hidden'
    @container.appendChild @progressWrapper

    # progress canvas in a different color, visible only after played
    @progressCanvas = document.createElement 'canvas'
    @progressCanvasContext = @progressCanvas.getContext '2d'
    @progressWrapper.appendChild @progressCanvas
    
    @canvases = [@waveCanvas, @progressCanvas]

    @resizeCanvases()

    # read buffer and get peaks
    @audioContext.decodeAudioData @audioData
    , (@audioBuffer) => 
      @draw()
      @setProgress(0.5)
    , ->
      console.error "Unable to decode downloaded audio data."


  draw: ->
    # get audio properties
    @audioDuration = @audioBuffer.duration
    @numberOfSamples = Math.floor(@audioDuration * @zoom * @sppx)
    sampleSize = Math.floor(@audioBuffer.length / @numberOfSamples)

    # consider only left channel for now
    @points = @audioBuffer.getChannelData(0)
    
    console.log "Plotting " + @numberOfSamples + " sample values from " + @points.length + " points..."

    @waveCanvasContext.strokeStyle = '#2A2522'
    @waveCanvasContext.beginPath()

    @progressCanvasContext.strokeStyle = '#526D75'
    @progressCanvasContext.beginPath()

    canvasX = 0.5

    # loop through summary @points we want to produce and visualize
    for sampleId in [0...@numberOfSamples]
      # find corresponding start/end positions in audio file for this point
      start = sampleId * sampleSize
      end = start + sampleSize

      # find highest absolute value within this range
      pointsInRange = @points.subarray start, end + 1
      pointsInRangeAbs = (Math.abs(x) for x in pointsInRange)  # fast absolute value (it's ok if off by one when negative)
      absMax = Math.max.apply null, pointsInRangeAbs
      
      # if @sppx > 1, only stretch vertically to fit canvas, 
      # since we are plotting more points horizontally
      verticalStretch = @sppx

      # now draw lines
      @waveCanvasContext.moveTo canvasX, @height * verticalStretch
      @waveCanvasContext.lineTo canvasX, (@height - absMax * 300) * verticalStretch
      @progressCanvasContext.moveTo canvasX, @height * verticalStretch
      @progressCanvasContext.lineTo canvasX, (@height - absMax * 300) * verticalStretch

      canvasX++

    @waveCanvasContext.closePath()
    @waveCanvasContext.stroke()

    @progressCanvasContext.closePath()
    @progressCanvasContext.stroke()


  setProgress: (percentage) ->
    @progressWrapper.style.width = @waveCanvas.width * percentage + 'px'
    

  resizeCanvases: ->
    # determine properties of ua
    @sppx = window.devicePixelRatio
    @canvasBackingStorePixelRatio = @waveCanvasContext.backingStorePixelRatio || @waveCanvasContext.webkitBackingStorePixelRatio || 1

    console.log "canvases resize: width = " + @width + ", height = " + @height + ", sppx = " + @sppx

    @container.style.height = @height + 'px'
    @container.style.width = @width + 'px'

    # if desired sppx doesn't match backing store pixel ratio, manually upscale canvas
    rescaleRatio = @sppx/@canvasBackingStorePixelRatio

    for canvas in @canvases
      # dom dimensions
      canvas.height = @height * rescaleRatio
      canvas.width = @width * rescaleRatio

      # css dimensions
      canvas.style.height = @height + 'px'
      canvas.style.width = @width + 'px'
