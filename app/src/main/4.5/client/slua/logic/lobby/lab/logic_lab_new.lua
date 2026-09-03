local GeneralLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
local logic_lab_new = {init = false}
logic_lab_new.ENUM_SYSTEM_ID = {
  GOLDEN_SUIT = 2,
  WEAPON_DIY = 3,
  CHARACTER = 4,
  Vehicle = 5,
  PET = 6
}
logic_lab_new.ENUM_SYSTEM_MAP = {
  [logic_lab_new.ENUM_SYSTEM_ID.WEAPON_DIY] = GeneralLabReddotData.ENUM_LAB_SYSTEMS.Weapon_DIY,
  [logic_lab_new.ENUM_SYSTEM_ID.CHARACTER] = GeneralLabReddotData.ENUM_LAB_SYSTEMS.Character
}
local SystemSortCfg = {
  [logic_lab_new.ENUM_SYSTEM_ID.GOLDEN_SUIT] = 2,
  [logic_lab_new.ENUM_SYSTEM_ID.WEAPON_DIY] = 3,
  [logic_lab_new.ENUM_SYSTEM_ID.CHARACTER] = 4,
  [logic_lab_new.ENUM_SYSTEM_ID.Vehicle] = 5,
  [logic_lab_new.ENUM_SYSTEM_ID.PET] = 6
}
local ExcludeShowNewSystemIDs = {
  [logic_lab_new.ENUM_SYSTEM_ID.GOLDEN_SUIT] = true,
  [logic_lab_new.ENUM_SYSTEM_ID.PET] = true
}
local SystemModuleMap = {
  [logic_lab_new.ENUM_SYSTEM_ID.GOLDEN_SUIT] = "client.slua.logic.XSuit.logic_xsuit",
  [logic_lab_new.ENUM_SYSTEM_ID.WEAPON_DIY] = "client.slua.logic.weapon_diy.logic_weapon_diy",
  [logic_lab_new.ENUM_SYSTEM_ID.CHARACTER] = ModuleManager.LobbyModuleConfig.NewCharacterSystem,
  [logic_lab_new.ENUM_SYSTEM_ID.Vehicle] = "client.network.Protocol.VehicleRefitHandler",
  [logic_lab_new.ENUM_SYSTEM_ID.PET] = ModuleManager.CommonModuleConfig.logic_pet
}
local bannerToShowArray, NewItemData
local InitData = function()
  bannerToShowArray = {}
  local data = {
    newCount = 0,
    systems = {}
  }
  for i, v in pairs(logic_lab_new.ENUM_SYSTEM_ID) do
    if ExcludeShowNewSystemIDs[v] then
    else
      data.systems[v] = {
        newCount = 0,
        items = {}
      }
    end
  end
  return data
end
function logic_lab_new.OnLogin(bRelogin)
  if not bRelogin then
    logic_lab_new.init = false
    NewItemData = nil
    bannerToShowArray = nil
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, logic_lab_new.OnActivityDataInit)
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_STATUS_CHANGE, logic_lab_new.OnLuckyBackInfoChange)
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_RED_DOT_INIT, logic_lab_new.OnLuckyBackInfoChange)
  end
end
local OriginActivityData
function logic_lab_new.OnActivityDataInit()
  OriginActivityData = {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(ActivityType.LabNew)
  for i, v in ipairs(activityData) do
    local itemID = v.List[1].Condition[4]
    local systemsID = v.List[1].Condition[5]
    local activityId = v.List[1].ID
    local rewardStatus = v.List[1].Status
    OriginActivityData[itemID] = {
      system_id = systemsID,
      activity_id = activityId,
      status = rewardStatus
    }
  end
  logic_lab_new._OnGetItemNewData(OriginActivityData)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
end
function logic_lab_new.OnLuckyBackInfoChange()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
end
function logic_lab_new.OnClickNewItem(itemID)
  if NewItemData == nil then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLabNewItem)
  if saveData == nil then
    saveData = {}
  end
  if saveData[tostring(itemID)] == nil then
    saveData[tostring(itemID)] = "1"
  end
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eLabNewItem)
  for i, v in pairs(NewItemData.systems) do
    for ii, vv in pairs(v.items) do
      if vv.id == itemID then
        vv.clicked = true
        if v.newCount and v.newCount > 0 then
          v.newCount = v.newCount - 1
          NewItemData.newCount = NewItemData.newCount - 1
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
end
function logic_lab_new.OnClickVideo(itemID)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLabNewItemVideo)
  if saveData == nil then
    saveData = {}
  end
  if saveData[tostring(itemID)] == nil then
    saveData[tostring(itemID)] = "1"
  end
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eLabNewItemVideo)
  if bannerToShowArray and next(bannerToShowArray) then
    for i, v in ipairs(bannerToShowArray) do
      if v.item_id == itemID then
        table.remove(bannerToShowArray, i)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
end
function logic_lab_new.CheckNeedNew()
  return false
end
function logic_lab_new.CheckNeedNewBySystemID(systems_id)
  if NewItemData == nil then
    return false
  elseif NewItemData.systems[systems_id] and NewItemData.systems[systems_id].newCount > 0 then
    return true
  else
    return false
  end
end
function logic_lab_new.GetVideoBannerData()
  if bannerToShowArray then
    return bannerToShowArray[1]
  else
    return nil
  end
end
function logic_lab_new.JumpToVideo()
end
function logic_lab_new.GetDataBySystemId(systems_id)
  if NewItemData == nil then
    return nil
  else
    return NewItemData.systems[systems_id]
  end
end
function logic_lab_new.GetNewItemsBySystemId(systems_id)
  local items = {}
  if NewItemData == nil or NewItemData.systems == nil then
    return items
  end
  if NewItemData.systems[systems_id] == nil or NewItemData.systems[systems_id].newCount == 0 then
    return items
  end
  for i, v in pairs(NewItemData.systems[systems_id].items) do
    if not v.clicked then
      items[i] = 1
    end
  end
  return items
end
local bPlayingVideo = false
function logic_lab_new.OnClickVideoBanner()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local system_id = bannerToShowArray[1].system_id
  local item_id = bannerToShowArray[1].item_id
  logic_lab_new.OnClickVideo(item_id)
  logic_lab_new.OnClickNewItem(item_id)
  if SystemModuleMap[system_id] and SystemModuleMap[system_id] ~= "" then
    local videoCfg = CDataTable.GetTableData("LabVideoCfg", item_id)
    if videoCfg == nil then
      log(bWriteLog and "UI_WeaponDiy_Control:OnClickVideo No Cfg")
      return
    else
      if type(SystemModuleMap[system_id]) == "string" then
        local systemModule = require(SystemModuleMap[system_id])
        systemModule.JumpToVideo(item_id)
      else
        local systemModule = ModuleManager:GetModule(SystemModuleMap[system_id])
        systemModule:JumpToVideo(item_id)
      end
      if not VideoLibrary.IsCanPlayVideo() then
        log(bWriteLog and "UI_WeaponDiy_Control:OnClickVideo: video has problem , don't play")
        return
      end
      bPlayingVideo = VideoLibrary.PlayVideo(videoCfg.video, {
        time = videoCfg.time,
        bDoNotChangeCameraSetting = true
      })
    end
  end
end
function logic_lab_new.OnVideoPlayEnd(item_id)
  bPlayingVideo = false
  if OriginActivityData == nil or OriginActivityData[item_id] == nil then
    return
  end
  if OriginActivityData[item_id].status == 0 then
    local ActivityHandler = require("client.network.Protocol.ActivityHandler")
    ActivityHandler.send_deal_activity_req(OriginActivityData[item_id].activity_id, 1, 101)
    log(bWriteLog and "send get award")
    ActivityHandler.send_take_activity_award_req(OriginActivityData[item_id].activity_id, 1)
    OriginActivityData[item_id].status = 2
  end
end
function logic_lab_new.GetVideoPlayingStatus()
  return bPlayingVideo
end
function logic_lab_new._CheckHadClickedVideo(itemID)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLabNewItemVideo)
  if saveData == nil then
    return false
  end
  if saveData[tostring(itemID)] == nil then
    return false
  else
    return true
  end
end
function logic_lab_new._CheckHadClickedNew(itemID)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLabNewItem)
  if saveData == nil then
    return false
  end
  if saveData[tostring(itemID)] == nil then
    return false
  else
    return true
  end
end
function logic_lab_new._OnGetItemNewData(itemsArray)
  if logic_lab_new.init then
    return
  end
  logic_lab_new.init = true
  local data = InitData()
  for i, v in pairs(itemsArray) do
    local videoCfg = CDataTable.GetTableData("LabVideoCfg", tonumber(i))
    if videoCfg and logic_lab_new._CheckHadClickedVideo(i) == false then
      table.insert(bannerToShowArray, {
        item_id = i,
        system_id = v.system_id,
        sortIdx = SystemSortCfg[v.system_id]
      })
    end
    if data.systems[v.system_id] == nil then
    else
      local bClicked = true
      if not logic_lab_new._CheckHadClickedNew(i) then
        bClicked = false
        data.systems[v.system_id].newCount = data.systems[v.system_id].newCount + 1
        data.newCount = data.newCount + 1
      end
      data.systems[v.system_id].items[i] = {
        id = tonumber(i),
        system_id = v.system_id,
        clicked = bClicked,
        activity_id = v.activity_id
      }
    end
  end
  local sortFunc = function(a, b)
    if a.sortIdx == b.sortIdx then
      return true
    end
    return a.sortIdx < b.sortIdx
  end
  table.sort(bannerToShowArray, sortFunc)
  log_tree("OnGetItemNewData bannerToShowArray", bannerToShowArray)
  local super_data = require("common.super_data")
  if NewItemData == nil then
    NewItemData = super_data.CreateSuperData(data)
  end
end
return logic_lab_new