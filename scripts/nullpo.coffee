# Description:
#   bot がガッをしてくれる
#
# Commands:

module.exports = (robot) ->

  robot.hear /ぬるぽ/, (msg) ->
    msg.send """
```
   Λ＿Λ     ＼＼
（  ・∀・）  | | ｶﾞｯ
 と     ）  | |
  Ｙ /ノ     人
   / ）    < >   _Λ  ∩
＿/し'   ／／  Ｖ｀Д´）/
（＿フ彡             / ←>> @#{msg.message.user.name}
```
  """
