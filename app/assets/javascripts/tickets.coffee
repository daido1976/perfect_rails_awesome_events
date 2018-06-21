# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ajax:success', '#createTicket', (data, status, xhr) ->
  location.reload()

$(document).on 'ajax:error', '#createTicket', (xhr, status, error) ->
  form = $('#new_ticket .modal-body')
  div = $('<div id="createTicketErrors" class="alert alert-danger"></div>')
  ul = $('<ul></ul>')
  xhr.detail[0].messages.forEach (message, i) ->
    li = $('<li></li>').text(message)
    ul.append(li)

  if $('#createTicketErrors')[0]
    $('#createTicketErrors').html(ul)
  else
    div.append(ul)
    form.prepend(div)
