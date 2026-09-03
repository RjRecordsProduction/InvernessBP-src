local SuperCoreRedDotData = {}
local redPoint
local bInit = false
local RedDotType = {SuperCoreEntry = 1}
local GenerateData = function()
  local redDot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = redDot_macro.Category
  local data = {
    newCount = 0,
    desc = redDot_macro.SystemName.SuperStar,
    types = {
      newCount = 0,
      [RedDotType.SuperCoreEntry] = {
        newCount = 0,
        category = Category.Other,
        subID = 1,
        desc = redDot_macro.SystemName.SuperStar
      }
    }
  }
  return data
end
function SuperCoreRedDotData.InitData()
  if bInit then
    return
  end
  bInit = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redPoint == nil then
    redPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      redPoint[k] = v
    end
  end
  local redDot_manager = require("client.slua.logic.reddot.reddot_manager")
  redDot_manager:Regist(redPoint)
end
function SuperCoreRedDotData.OnLogin()
  SuperCoreRedDotData.InitData()
end
function SuperCoreRedDotData.OnLogout()
  log(bWriteLog and "[YY]SuperCoreRedDotData==OnLogout=" .. tostring(GameStatus.GetGameStatus()))
  SuperCoreRedDotData.DestroyData()
end
function SuperCoreRedDotData.DestroyData()
  redPoint = nil
  bInit = false
end
function SuperCoreRedDotData.GetSuperCoreEntryRedPointData()
  if redPoint then
    return redPoint.types[RedDotType.SuperCoreEntry]
  end
end
function SuperCoreRedDotData.UpdateSuperCoreEntryCount(count)
  if redPoint then
    redPoint.types[RedDotType.SuperCoreEntry].newCount = count
  end
end
function SuperCoreRedDotData.GetData()
  if redPoint then
    return redPoint.types[RedDotType.SuperCoreEntry]
  end
end
function SuperCoreRedDotData.IsShowArrowRedDot()
  local CommunityHandler = require("client.network.Protocol.CommunityHandler")
  if CommunityHandler.red_type_new and CommunityHandler.red_type_new == 106 then
    return true
  end
  return false
end
function SuperCoreRedDotData.GetDescription(subID)
  local msg = ""
  if subID == 1 then
    msg = LocUtil.GetLocalizeResStr(23574)
  end
  return msg
end
return SuperCoreRedDotData