sample = ->
    alert "coffee"

$('.inbtn').click (e)->
  e.preventDefault()
  $.ajax
    dataType: "json"
    url: '/api/in' 
    data: (date) -> 
    success: (data, status, jqXHR) ->
      alert 'in'
    error: (jqXHR, status, errorString) ->
      alert errorString

$('.outbtn').click (e)->
  e.preventDefault()
  $.ajax
    dataType: "json"
    url: '/api/out' 
    data: (date) -> 
    success: (data, status, jqXHR) ->
      alert 'out'
    error: (jqXHR, status, errorString) ->
      alert errorString


