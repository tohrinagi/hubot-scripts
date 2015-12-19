# Description:
#   heroku 無料制限で起きた時、寝る時に発言する
random = require('hubot').Response::random

module.exports = (robot) ->
  ## 起きた時、slack-adapterがつながるのを待って通知
  cid = setInterval ->
    return if typeof robot?.send isnt 'function'
    robot.send {room: "#life"}, "おはようー私、起きたよ"
    clearInterval cid
  , 1000

  ## 寝た時、通知してからexitする
  on_sigterm = ->
    robot.send {room: "#life"}, '私はもう寝る。お休み。'
    setTimeout process.exit, 1000

  if process._events.SIGTERM?
    process._events.SIGTERM = on_sigterm
  else
    process.on 'SIGTERM', on_sigterm
