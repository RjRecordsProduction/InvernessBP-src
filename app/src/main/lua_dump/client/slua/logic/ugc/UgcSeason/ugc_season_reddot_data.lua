local ugc_season_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {Wow_SeasonNewReward = 1}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCSeason,
    types = {
      newCount = 0,
      [RedDotType.Wow_SeasonNewReward] = {
        newCount = 0,
        isDynamic = true,
        category = Category.Receive,
        subID = RedDotType.Wow_SeasonNewReward
      }
    }
  }
  return data
end
function ugc_season_reddot_data.InitData()
  if bIsInited then
    return
  end
  bIsInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if RedDot == nil then
    RedDot = super_data.CreateSuperData(data)
  end
  local RedDotManager = require("client.slua.logic.reddot.reddot_manager")
  RedDotManager:Regist(RedDot)
end
function ugc_season_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
end
function ugc_season_reddot_data.GetData()
  if not RedDot then
    RedDot = ugc_season_reddot_data.InitData()
  end
  return RedDot
end
function ugc_season_reddot_data.GetPlayData()
  if RedDot then
    return RedDot.types[RedDotType.WOW].pages[RedDotType.Play]
  end
end
function ugc_season_reddot_data.UpdateWOWCount(count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.WOW].newCount = count
  end
end
function ugc_season_reddot_data.UpdatePlayDataCount(count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.WOW].pages[RedDotType.Play].newCount = count
  end
end
function ugc_season_reddot_data.GetWowSeasonRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.Wow_SeasonNewReward]
  end
end
function ugc_season_reddot_data.UpdateWowSeasonRedCount(_reddotType, Count)
  if RedDot and RedDot.types[RedDotType.Wow_SeasonNewReward] then
    RedDot.types[RedDotType.Wow_SeasonNewReward].new  end
end
function ugc_season_reddot_data.OnLogin()
  log(bWriteLog and "ugc_playlevel_reddot_data OnLogin")
  ugc_season_reddot_data.InitData()
end
function ugc_season_reddot_data.OnLogout()
  log(bWriteLog and "ugc_playlevel_reddot_data OnLogout")
  ugc_season_reddot_data.DestroyData()
end
ugc_season_reddot_data.ReddotType = RedDotType
return ugc_season_reddot_data