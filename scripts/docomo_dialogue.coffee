# Description:
#   bot に雑談を話してもらいます.
#   DOCOMO_DIALOGUE_API_KEY に API_KEY を設定する必要があります
#
# Commands:


DOCOMO_DIALOGUE_API_URL='https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY='
DOCOMO_DIALOGUE_API_KEY=process.env.DOCOMO_DIALOGUE_API_KEY
DOCOMO_DIALOGUE_FORGOTTON_MSEC=process.env.DOCOMO_DIALOGUE_FORGOTTON_MSEC || 600000

module.exports = (robot) ->
  api = "#{DOCOMO_DIALOGUE_API_URL}#{DOCOMO_DIALOGUE_API_KEY}"

  is_defined_cmd = (msg) ->
    cmds = []
    for help in robot.helpCommands()
      cmd = help.split(' ')[1]
      cmds.push(cmd) if cmds.indexOf(cmd) == -1
    cmd = msg.match[1].split(' ')[0]
    cmds.indexOf(cmd) != -1

  robot.respond /(\S+)/, (msg) ->
    return if is_defined_cmd(msg)

    request = require('request').defaults({
      strictSSL: false
    })

    DOCOMO_DIALOGUE_CONTENT_KEY = "docomo-dialogue-context" + msg.message.room
    DOCOMO_DIALOGUE_MSEC_KEY = "docomo-dialogue-msec" + msg.message.room
    context = robot.brain.get DOCOMO_DIALOGUE_CONTENT_KEY || ''
    prev_msec = robot.brain.get DOCOMO_DIALOGUE_MSEC_KEY || 0
    now_msec = new Date().getTime()
    diff_msec = now_msec - prev_msec
    if DOCOMO_DIALOGUE_FORGOTTON_MSEC < diff_msec
      context = ''

    request.post(api, body: JSON.stringify({utt: msg.match[1], context: context}), (error, response, body) ->
      robot.brain.set DOCOMO_DIALOGUE_CONTENT_KEY, JSON.parse(body).context
      robot.brain.set DOCOMO_DIALOGUE_MSEC_KEY, new Date().getTime()
      msg.reply "#{JSON.parse(body).utt}"
    )
