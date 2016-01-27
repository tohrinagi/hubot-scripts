# Description:
#   決まった時間に github contributes をみて◯日書いてなかったら怒る
cron = require('cron').CronJob
random = require('hubot').Response::random
parser = require('xml2json');

GITHUB_CONTRIBUTION_URL = "https://github.com/users/tohrinagi/contributions"
GITHUB_CONTRIBUTION_INTAVAL = 3

module.exports = (robot) ->
  new cron('0 0 10 * * *',
    () ->
      robot.http(GITHUB_CONTRIBUTION_URL)
        .get() (err, response, body) ->
          if err
            robot.send "http error for github contribution"
            return
          json = JSON.parse( parser.toJson(body) )

          today = new Date()
          previousDay = new Date( today.getTime() - GITHUB_CONTRIBUTION_INTAVAL * 24 * 60 * 60 * 1000)
          contribution = 0
          for g in json.svg.g.g
            for rect in g.rect
              date = new Date(rect['data-date'])
              if previousDay.getTime() <= date.getTime() && date.getTime() <= today.getTime()
                contribution += Number(rect['data-count'])

          if contribution == 0
            robot.send {room: "#life"},  random [
                "@tohrinagi 最近、GitHub にコミットしてないみたいだけど…",
                "@tohrinagi きちんと個人開発しなさい！",
                "@tohrinagi GitHub へのコミット、もう#{GITHUB_CONTRIBUTION_INTAVAL}以上さぼってるよ！"
              ]
    , null, true, 'Asia/Tokyo').start()
