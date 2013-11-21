$ ->
  playerDivs = $('.soundfile-player')

  if not playerDivs.length
    console.debug "No player containers found.  Exiting..."
    return

  playerDivs.each (index, playerDiv) ->
    playerDiv = $ playerDiv

    audioElements = playerDiv.find('audio:not(.play-this-first)')
    if audioElements.length != 1
      console.error "Player container does not contain exactly 1 audio element."
      debugger

    audioElement = $(audioElements.get(0))

    # load "play this first" clip, if specified
    playThisFirst = $ playerDiv.data('play-this-first')
    if playThisFirst.length == 1
      playThisFirst = $ playThisFirst.get(0)

      playThisFirstPlayed = false
      
      audioElement.on 'play', (e) ->
        if playThisFirstPlayed
          return

        audioElement.get(0).pause()
        playThisFirst.get(0).currentTime = playerDiv.data('play-this-first-start')
        playThisFirst.get(0).play()

        playThisFirstStopCheck = (e) ->
          if playThisFirst.get(0).currentTime > playerDiv.data('play-this-first-end')
            playThisFirstPlayed = true
            playThisFirst.get(0).pause()
            playThisFirst.get(0).currentTime = 0
            audioElement.get(0).play()
            playThisFirst.off 'timeupdate', playThisFirstStopCheck

        playThisFirst.on 'timeupdate', playThisFirstStopCheck

    # TODO: draw controls

    # test currentTime
    audioElement.on 'timeupdate', (e) ->
      audio_element_dom = e.currentTarget
      console.debug "currentTime = " + audio_element_dom.currentTime

    # load list of annotations
    annotationListSrc = playerDiv.data 'annotation-list-src'
    if annotationListSrc && annotationListSrc.length
      $.getJSON annotationListSrc, (data) ->
        console.log data
