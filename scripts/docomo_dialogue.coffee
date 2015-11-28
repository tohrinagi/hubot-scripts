# Description:
#   bot に雑談を話してもらいます.
#   DOCOMO_DIALOGUE_API_KEY に API_KEY を設定する必要があります
#
# Commands:
#   bot ねぇ <雑談内容> - botと雑談をします.


DOCOMO_DIALOGUE_API_URL='https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY='
DOCOMO_DIALOGUE_API_KEY=process.env.DOCOMO_DIALOGUE_API_KEY
DOCOMO_DIALOGUE_FORGOTTON_MSEC=process.env.DOCOMO_DIALOGUE_FORGOTTON_MSEC || 300

module.exports = (robot) ->
  api = "#{DOCOMO_DIALOGUE_API_URL}#{DOCOMO_DIALOGUE_API_KEY}"

  robot.respond /(ねぇ|ねえ|なぁ|なあ|おい)(.*)/, (msg) ->
    query = msg.match[2]

    request = require('request').defaults({
      strictSSL: false
    })

    context = robot.brain.get "docomo-dialogue-context" || ''
    prev_msec = robot.brain.get "docomo-dialogue-msec" || 0
    now_msec = new Date().getTime()
    diff_msec = now_msec - prev_msec
    if DOCOMO_DIALOGUE_FORGOTTON_MSEC < diff_msec
      context = ''

    request.post(api, body: JSON.stringify({utt: query, context: context}), (error, response, body) ->
      robot.brain.set "docomo-dialogue-context", body.context
      robot.brain.set "docomo-dialogue-msec", new Date().getTime()
      msg.reply "#{JSON.parse(body).utt}"
    )
