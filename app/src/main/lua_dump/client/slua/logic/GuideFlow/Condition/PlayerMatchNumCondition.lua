local PlayerMatchNumCondition = {}
function PlayerMatchNumCondition.Check(conditionId, matchNum1, matchNum2)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.newbieTotalGameCnt
  log(bWriteLog and "[qintong] PlayerMatchNumCondition.Check = " .. tostring(enter_game_num) .. "  matchNum1 = " .. tostring(matchNum1) .. "  matchNum2 = " .. tostring(matchNum2) .. type(matchNum2))
  if not matchNum1 or matchNum1 == "" then
    return false
  end
  if not matchNum2 or matchNum2 == "" then
    return false
  end
  if enter_game_num and enter_game_num >= tonumber(matchNum1) and enter_game_num <= tonumber(matchNum2) then
    return true
  else
    return false
  end
end
return PlayerMatchNumCondition