# Description:
#   ポケモンGOが出たら教えてくれる
cron = require('cron').CronJob

ITUNES_API_URL='https://itunes.apple.com/search?term=pokemon+go&country=jp&media=software&entity=software&lang=ja_jp'

module.exports = (robot) ->

  new cron('0 */1 * * * *',
    () ->
      return if robot.brain.get "pokemon_go"
      request = require('request')
      request
        url: ITUNES_API_URL,
        (error, response, body) ->
          if response.statusCode is 200
            result = JSON.parse(body)
            for data in result['results']
              if 'Niantic, Inc.' == data['sellerName']
                robot.send {room: "#life"}, "@tohrinagi ポケモンGO、ついにリリースされたよ！"
                robot.brain.set "pokemon_go", true
                return

    , null, true, 'Asia/Tokyo').start()

