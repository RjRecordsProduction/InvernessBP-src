local ban_reddot_data = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local isInited = false
local banSuperReddotData
function ban_reddot_data.SetDefaultData()
  local data = {
    desc = reddot_macro.SystemName.Ban,
    newCount = 0,
    Reward = {
      newCount = 0,
      subID = 3,
      isDynamic = true,
      category = reddot_macro.Category.Receive
    },
    NewTheme = {
      newCount = 0,
      subID = 1,
      isDynamic = true,
      category = reddot_macro.Category.NewArrivals
    },
    Player = {
      newCount = 0,
      isDynamic = true,
      subID = 2,
      category = reddot_macro.Category.Other
    }
  }
  return data
end
function ban_reddot_data.GetData()
  return banSuperReddotData
end
function ban_reddot_data.SetSubData(reddotType)
  local sub_id = 1
  if reddotType == reddot_macro.Category.NewArrivals then
    sub_id = banSuperReddotData.NewTheme.subID or 1
  elseif reddotType == reddot_macro.Category.Receive then
    reddotType = reddot_macro.Category.Other
    sub_id = banSuperReddotData.Reward.subID or 3
  elseif reddotType == reddot_macro.Category.Other then
    sub_id = banSuperReddotData.Player.subID or 2
  end
  local redData = {
    newCount = 0,
    category = reddotType,
    subID = sub_id,
    instanceId = {_isLeaf = true}
  }
  return redData
end
function ban_reddot_data.GetBanSuperData(redId, reddotType)
  if not banSuperReddotData then
    return
  end
  if reddotType == reddot_macro.Category.Receive then
    if banSuperReddotData.Reward[redId] then
      return banSuperReddotData.Reward[redId]
    else
      banSuperReddotData.Reward[redId] = ban_reddot_data.SetSubData(reddotType)
      return banSuperReddotData.Reward[redId]
    end
  elseif reddotType == reddot_macro.Category.NewArrivals then
    if banSuperReddotData.NewTheme[redId] then
      return banSuperReddotData.NewTheme[redId]
    else
      banSuperReddotData.NewTheme[redId] = ban_reddot_data.SetSubData(reddotType)
      return banSuperReddotData.NewTheme[redId]
    end
  elseif reddotType == reddot_macro.Category.Other then
    if banSuperReddotData.Player[redId] then
      return banSuperReddotData.Player[redId]
    else
      banSuperReddotData.Player[redId] = ban_reddot_data.SetSubData(reddotType)
      return banSuperReddotData.Player[redId]
    end
  end
end
function ban_reddot_data.AddReddot(redId, itemId, reddotType)
  if redId == 0 then
    return
  end
  local superData = ban_reddot_data.GetBanSuperData(redId, reddotType)
  if not superData then
    return
  end
  superData.instanceId[itemId] = true
end
function ban_reddot_data.RemoveBanSuperData(redId, itemId, reddotType)
  local superData = ban_reddot_data.GetBanSuperData(redId, reddotType)
  if superData and superData.instanceId then
    superData.instanceId[itemId] = nil
  end
end
function ban_reddot_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local super_data = require("common.super_data")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local data = ban_reddot_data.InitBanConfigData()
  banSuperReddotData = super_data.CreateSuperData(data)
  log(bWriteLog and "[bgp]:InitData Reddot Data")
  reddot_manager:Regist(banSuperReddotData)
  EventSystem:postEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_INIT_SYSTEM_SUPERDATA, BP_ENUM_MODULE_BAN)
end
function ban_reddot_data.InitBanConfigData()
  local superDataStruct = ban_reddot_data.SetDefaultData()
  local reddotConfig = require("client.slua.logic.reddot.reddot_config")
  local rewardData = reddotConfig:GetReddotConfigByName(superDataStruct.desc, 3) or {}
  superDataStruct.Reward.subID = rewardData.SubID or 3
  superDataStruct.Reward.category = rewardData.Category
  local newData = reddotConfig:GetReddotConfigByName(superDataStruct.desc, 1) or {}
  superDataStruct.NewTheme.subID = newData.SubID or 1
  superDataStruct.NewTheme.category = newData.Category
  local otherData = reddotConfig:GetReddotConfigByName(superDataStruct.desc, 2) or {}
  superDataStruct.Player.subID = otherData.SubID or 2
  superDataStruct.Player.category = otherData.Category
  return superDataStruct
end
function ban_reddot_data.DestroyData()
  banSuperReddotData = nil
  isInited = false
end
function ban_reddot_data.OnLogin()
  ban_reddot_data.InitData()
end
function ban_reddot_data.OnLogout()
  ban_reddot_data.DestroyData()
end
return ban_reddot_data