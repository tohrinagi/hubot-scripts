# Description:
#   おうちハック
#   iftttやhueなどのエイリアスと、slackの発言受け取っての実行
# Commands:
#   hubot ライト - ライトをつけます
#   hubot ライト - ライトを消します
#   hubot エアコン - エアコンつけます
#   hubot エアコン - エアコン消します
#   hubot おやすみ - ライトを消しエアコンを予約状態にします
#   hubot いってきます - エアコンとライトを消します
#   hubot ただいま - エアコンとライトをつけます
#   hubot 家の状況 - 現在の状況を説明します
#   hubot 傘いる？ - 雨が降るか聞きます
#   hubot airconon - エアコンつけます
#   hubot airconoff - エアコン消します
hubotSlack = require 'hubot-slack'
hubot = require 'hubot'

module.exports = (robot) ->

  callCommand = (robot,msgOrg,text) ->
    msg = new hubot.TextMessage msgOrg.user, text, msgOrg.id
    msg.room = msgOrg.room
    robot.receive msg

  getTemprature = (success,error) ->
    Netatmo = require 'netatmo'
    auth =
      client_id: process.env.HUBOT_NETATMO_CLIENT_ID
      client_secret: process.env.HUBOT_NETATMO_CLIENT_SECRET
      username: process.env.HUBOT_NETATMO_USERNAME
      password: process.env.HUBOT_NETATMO_PASSWORD
    api = new Netatmo auth

    options =
      device_id: process.env.HUBOT_NETATMO_DEVICE_ID
      scale: 'max'
      type: ['Temperature']
      date_end: "last"

    api.getMeasure options, (err,measure) ->
      if err
        error()
      else
        temperature = measure[0]['value'][0]
        success(parseInt(temperature))

  needsForUmbrella = (res,reply) ->
    res.http( "http://www.drk7.jp/weather/json/13.js" )
      .get() (err, response, body) ->
        if err
          res.send "http error for drk7"
          return
        processingBody = body.replace(/^.*\(/, "").replace(/\);/, "")
        weather = JSON.parse(processingBody)

        d = new Date
        month = d.getMonth()+1
        date = d.getDate()
        if month < 10
          month = '0' + month
        if date < 10
          date = '0' + date
        dateString = "#{d.getFullYear()}/#{month}/#{date}"
        today = weather.pref.area['東京地方'].info.filter (item, idx, array ) -> item.date == dateString
        today_rainfall = 0
        for val in today[0].rainfallchance.period
          if parseInt(val.content,10) > today_rainfall
            today_rainfall = parseInt(val.content,10)
        if today_rainfall > 30
            res.send "@tohrinagi 今日は降水確率#{today_rainfall}%あるから傘持って来なさい"
        else
          if reply
            res.send "@tohrinagi 今日は降水確率#{today_rainfall}%だから大丈夫！"

  robot.hear /(ライト|電気|light).*(つけて|オン|on)/, (res) ->
    res.send "ライトつけるよ"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"

  robot.hear /(ライト|電気|light).*(消して|けして|オフ|off)/, (res) ->
    res.send "ライト消すよ"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.hear /(エアコン|aircon).*(つけて|オン|on$)/, (res) ->
    getTemprature (temperature)->
      if temperature > 26
        res.send "#{temperature}度だね。冷房エアコンつけるよ"
        callCommand robot, res.message, "#{res.robot.name} ir send message aircon_on_cool for home"
      else if temperature < 19
        res.send "#{temperature}度だね。暖房エアコンつけるよ"
        callCommand robot, res.message, "#{res.robot.name} ir send message airconon for home"
      else
        res.send "#{temperature}度だね。エアコンの必要ないみたい"
    ()->
      res.send "get temperature error"


  robot.hear /(エアコン|aircon).*(消して|けして|オフ|off$)/, (res) ->
    res.send "エアコン消すよ"
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /おやすみ/i, (res) ->
    robot.brain.set "goodnight", true
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.hear /おやすみ/, (res) ->
    robot.brain.set "goodnight", true
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /いってきます/i, (res) ->
    res.send "いってらっしゃい！"
    robot.brain.set "stay", false
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"

  robot.hear /いってきます/, (res) ->
    res.send "いってらっしゃい！"
    robot.brain.set "stay", false
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"
    needsForUmbrella res,false
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /ただいま/i, (res) ->
    res.send "おかえりなさい！"
    robot.brain.set "stay", true
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"
    callCommand robot, res.message, "#{res.robot.name} airconon"

  robot.hear /ただいま/, (res) ->
    res.send "おかえりなさい！"
    robot.brain.set "stay", true
    callCommand robot, res.message, "#{res.robot.name} ir send message airconon for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"

  robot.respond /(家の状況)/, (msg) ->
    stay = if robot.brain.get "stay" then "在宅" else "外出"
    goodnight = if robot.brain.get "goodnight" then "睡眠中" else "起床中"
    msg.reply "現在の状況は…\n在宅状況：#{stay}\n睡眠状況：#{goodnight}"

  robot.respond /傘いる？/, (msg) ->
    needsForUmbrella msg,true


