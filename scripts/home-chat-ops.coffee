# Description:
#   おうちハック
#   iftttやhueなどのエイリアスと、slackの発言受け取っての実行
# Commands:
#   hubot ライト ライトをつけます
#   hubot ライト ライトを消します
#   hubot エアコン エアコンつけます
#   hubot エアコン エアコン消します
hubotSlack = require 'hubot-slack'
hubot = require 'hubot'

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

  robot.listeners.push new hubotSlack.SlackBotListener robot, /ただいま！/i, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconon for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_on"

  robot.listeners.push new hubotSlack.SlackBotListener robot, /いってきます！/i, (res) ->
    callCommand robot, res.message, "#{res.robot.name} ir send message airconoff for home"
    callCommand robot, res.message, "#{res.robot.name} ifttt hue_off"
