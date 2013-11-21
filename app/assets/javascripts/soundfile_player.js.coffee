$ ->
  playerDiv = $('.soundfile-player')

  if not playerDiv.length
    console.debug "No player containers found.  Exiting..."
    return

  audioElements = playerDiv.find('audio')
  if audioElements.length != 1
    console.error "Player container does not contain exactly 1 audio element."
    debugger

  audioElement = $(audioElements.get(0))

  # test currentTime
  audioElement.on 'timeupdate', (e) ->
    audio_element_dom = e.currentTarget
    console.debug "currentTime = " + audio_element_dom.currentTime

  # load list of annotations
  annotationListSrc = playerDiv.data 'annotation-list-src'
  console.log annotationListSrc
  if annotationListSrc.length
    $.getJSON annotationListSrc, (data) ->
      console.log data
