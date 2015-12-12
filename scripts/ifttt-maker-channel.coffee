# Description:
#   trigger IFTTT Maker Channel
#
# Commands:
#   hubot ifttt $(event) trigger ifttt event.

HUBOT_IFTTT_TOKEN=process.env.HUBOT_IFTTT_TOKEN || "test"
module.exports = (robot) ->

  robot.respond /ifttt (.*)/i, (msg) ->
    if !HUBOT_IFTTT_TOKEN
      msg.send "please set HUBOT_IFTTT_TOKEN"
      return
    msg.http( "https://maker.ifttt.com/trigger/#{msg.match[1]}/with/key/#{HUBOT_IFTTT_TOKEN}" )
      .get() (err, res, body) ->
        if err
          msg.send "error! IFTTT Maker Channel not triggered!"
          return
        msg.send "#{body}"
