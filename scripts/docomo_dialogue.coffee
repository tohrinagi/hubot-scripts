# Description:
#   bot に雑談を話してもらいます.
#   DOCOMO_DIALOGUE_API_KEY に API_KEY を設定する必要があります
#
# Commands:
#   bot ねぇ <雑談内容> - botと雑談をします.

request = require('request').defaults({
  strictSSL: false
})

DOCOMO_DIALOGUE_API_URL='https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY='

module.exports = (robot) ->
  api = "#{DOCOMO_DIALOGUE_API_URL}#{DOCOMO_DIALOGUE_API_KEY}"

  robot.respond /(ねぇ|ねえ|なぁ|なあ|おい)(.*)/, (msg) ->
    query = msg.match[2]
    request.post(api, body: JSON.stringify({utt: query}), (error, response, body) ->
      msg.reply "#{JSON.parse(body).utt}"
    )
