# Description:
#   cron などスケジュール関係
cron = require('cron').CronJob
random = require('hubot').Response::random

module.exports = (robot) ->

  new cron('0 30 9 * * *',
    () ->
      robot.brain.set "goodnight", false
      goodnight = if robot.brain.get "goodnight" then "睡眠中" else "起床中"
      robot.send {room: "#life"}, "#{goodnight}"
    , null, true, 'Asia/Tokyo').start()

  new cron('0 */10 1-3 * * *',
    () ->
      stay = robot.brain.get "stay"
      goodnight = robot.brain.get "goodnight"
      if goodnight || !stay
        return
      d = new Date
      robot.send {room: "#life"}, random [
        "@tohrinagi もう #{d.getHours()}:#{d.toLocaleTimeString()} だよ！",
        "@tohrinagi こらっ！寝なさい！",
        "@tohrinagi 夜更かしすると辛いよ！"
      ]
    , null, true, 'Asia/Tokyo').start()
