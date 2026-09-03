local BlackFridayGunModule = {}
local 
function BlackFridayGunModule:DefineAndResetData()
  self.GunActivityId = nil
  self.dailyActId = nil
  self.scoreActId = nil
  self.ActIdMap = nil
end
function BlackFridayGunModule:HandlePresetData(extraData)
  self.GunActivityId = extraData.gun_activity_id
  self.dailyActId = extraData.gun_group_act_id_daily
  self.scoreActId = extraData.gun_group_act_id_score
  if not self.ActIdMap then
    self.ActIdMap = {}
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local taskActIds = self:GetTaskIds()
  for _, actId in pairs(taskActIds) do
    if actId ~= 0 then
      local activityData = ActivityNewSystem.GetActivityByID(actId)
      if activityData then
        local subTask = activityData.List
        for _, subTaskData in pairs(subTask) do
          self.ActIdMap[subTaskData.ID] = true
        end
      end
      self.ActIdMap[actId] = true
    end
  end
end
function BlackFridayGunModule:GetBlackFridayGunActId()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByType(ActivityType.BlackFriday_Gun)
  return actData and actData.ID
end
function BlackFridayGunModule:ReqOptionalGunBoxData()
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    local actId = self:GetBlackFridayGunActId()
    if actId then
      local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
      SpecialLuckNetWork.send_get_draw_act_info_req(actId)
    end
  end
end
function BlackFridayGunModule:SendOpenWeaponBox(boxItemId, itemId)
  local actId = self:GetBlackFridayGunActId()
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_open_custom_weapon_req(boxItemId, itemId, actId):Then(function(_, item_list)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    log_tree("black_friday_open_custom_weapon:", item_list)
    Logic_CommonItemGet.ShowPanel_DefaultStyle({item_list})
    local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
    local TLogReasonTable = {
      item_id = itemId,
      item_num = item_list.count,
      cost_item_id = boxItemId,
      cost_item_num = 1,
      scene = BlackFridayMacros.CostScene.GunCustomBox
    }
    local BlackFridayMainModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayMainModule)
    BlackFridayMainModule:HandleCostTLog(TLogReasonTable)
  end)
end
function BlackFridayGunModule:GetTaskIds()
  return {
    self.dailyActId,
    self.scoreActId
  }
end
function BlackFridayGunModule:HasAnyAward()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  local awardConfigs = LuckybackActivitySystem.newtotalDrawAwardConfig
  local playerData = LuckybackActivitySystem.playerData
  for _, awardConfig in ipairs(awardConfigs) do
    if not awardConfig.hasGet and playerData.totalDrawTime >= awardConfig.timesCount then
      return true
    end
  end
  local taskActIds = self:GetTaskIds()
  for _, actId in pairs(taskActIds) do
    if actId ~= 0 then
      local activityData = ActivityNewSystem.GetActivityByID(actId)
      if activityData then
        local subTask = activityData.List
        for _, subTaskData in pairs(subTask) do
          if subTaskData.Status == ActivityProgressStatus.Done then
            return true
          end
        end
      end
    end
  end
  return false
end
function BlackFridayGunModule:IsOptionalGunBox(itemId)
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    return false
  end
  local data = BlackFridayGunReceiver.ext_info.optional_chest_info
  if data[itemId] then
    return true
  end
  return false
end
function BlackFridayGunModule:GetOptionalGunBoxData(itemId)
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    return {}
  end
  local data = BlackFridayGunReceiver.ext_info.optional_chest_info
  return data[itemId] or {}
end
function BlackFridayGunModule:GetOptionalGunBoxPreviewData(itemId)
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    return
  end
  local data = BlackFridayGunReceiver.ext_info.optional_chest_info
  local result = {}
  if data[itemId] then
    local boxData = data[itemId]
    for _, value in pairs(boxData) do
      local ele = {
        DropItemID = value.resid,
        item_time_limit = value.valid_hours,
        DropItemNum = value.count,
        DropType = 9,
        DropWeight = 0
      }
      result[#result + 1] = ele
    end
  end
  return result
end
function BlackFridayGunModule:PreviewSingleBox(boxItemId)
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    return
  end
  local boxData = BlackFridayGunReceiver.ext_info.optional_chest_info[boxItemId]
  if not boxData then
    return
  end
  local itemTable = {}
  local defaultItemId, defaultItemValidHours
  for itemId, data in pairs(boxData) do
    table.insert(itemTable, {
      itemID = tonumber(itemId),
      count = data.count,
      validTime = data.valid_hours
    })
    if not defaultItemId then
      defaultItemId = tonumber(itemId)
      defaultItemValidHours = data.valid_hours
    end
  end
  local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  local actType = ItemPreviewSystem.Enum_Preview_Type.EnumType_ThreeColumnPreview
  LobbySystem.PlayItemPreviewAnimation(defaultItemId, false, actType, itemTable, defaultItemValidHours, {fromSpin = true})
end
function BlackFridayGunModule:PreviewAllBox()
  local BlackFridayGunReceiver = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver")
  if not BlackFridayGunReceiver.ext_info then
    return
  end
  local AllBoxData = BlackFridayGunReceiver.ext_info.optional_chest_info
  local detail = {}
  local defaultItemId, defaultItemValidHours
  for _, data in pairs(AllBoxData) do
    for dropItemId, dropData in pairs(data) do
      detail[#detail + 1] = {
        resid = tonumber(dropItemId),
        count = dropData.count,
        valid_hours = dropData.valid_hours
      }
      if not defaultItemId then
        defaultItemId = tonumber(dropItemId)
        defaultItemValidHours = dropData.valid_hours
      end
    end
  end
  local other = {
    fromSpin = true,
    ShowTreeColumnTitle = true,
    TreeColumnTitleText = LocUtil.GetLocalizeResStr(86622)
  }
  local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  local actType = ItemPreviewSystem.Enum_Preview_Type.EnumType_ThreeColumnPreview
  LobbySystem.PlayItemPreviewAnimation(defaultItemId, false, actType, detail, defaultItemValidHours, other)
end
function BlackFridayGunModule:GetGunActId()
  return self.GunActivityId
end
function BlackFridayGunModule:IsGunActId(id)
  if not self.ActIdMap then
    return false
  end
  return self.ActIdMap[id]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayGunModule = class(CModuleBase, nil, BlackFridayGunModule)
return CBlackFridayGunModule