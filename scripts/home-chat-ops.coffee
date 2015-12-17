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
hubotSlack = require 'hubot-slack'
hubot = require 'hubot'
jsonpClient = require 'jsonp-client';

module.exports = (robot) ->

  callCommand = (robot,msgOrg,text) ->
    msg = new hubot.TextMessage msgOrg.user, text, msgOrg.id
    msg.room = msgOrg.room
    robot.receive msg

  robot.hear /(ライト|電気|light).*(つけて|オン|on)/, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"

  robot.hear /(ライト|電気|light).*(消して|けして|オフ|off)/, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.hear /(エアコン|aircon).*(つけて|オン|on$)/, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconon for home"

  robot.hear /(エアコン|aircon).*(消して|けして|オフ|off$)/, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /おやすみ/i, (res) ->
    robot.brain.set "goodnight", true
    callCommand robot, res.message, "#{res.robot.name} ir send message airconreserve for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.hear /おやすみ/, (res) ->
    robot.brain.set "goodnight", true
    callCommand robot, res.message, "#{res.robot.name} ir send message airconreserve for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /いってきます/i, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.hear /いってきます/, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /おかえり！/i, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconon for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /いってらっしゃい！/i, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"
