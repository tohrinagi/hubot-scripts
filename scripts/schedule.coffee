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

  new cron('0 0 1 * * *',
    () ->
      if robot.brain.get "goodnight" || !robot.brain.get "stay"
         return
      robot.send {room: "#life"}, random [
        "@tohrinagi 1:00 ですよ！そろそろ寝なさーい",
        "@tohrinagi 寝る時間だよー。夜更かしは辛いよ…"
      ]
    , null, true, 'Asia/Tokyo').start()

  new cron('0 */10 1-3 * * *',
    () ->
      if robot.brain.get "goodnight" || !robot.brain.get "stay"
        return
      d = new Date
      robot.send {room: "#life"}, random [
        "@tohrinagi もう #{d.getHours()}:#{d.getMinutes()} だよ！",
        "@tohrinagi こらっ！寝なさい！",
        "@tohrinagi 夜更かしすると辛いよ！"
      ]
    , null, true, 'Asia/Tokyo').start()
