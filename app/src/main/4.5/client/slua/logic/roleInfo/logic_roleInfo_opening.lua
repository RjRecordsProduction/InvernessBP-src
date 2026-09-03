local logic_roleInfo_opening = {}
function logic_roleInfo_opening:DefineAndResetData()
  self.curEquipedItemID = nil
end
function logic_roleInfo_opening:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_PERSONAL_ITEM, self.OnAddPersonalItem, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_PERSONAL_ITEM, self.OnDeletePersonalItem, self)
end
function logic_roleInfo_opening:OnAddPersonalItem()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OPENING_REDDOT)
end
function logic_roleInfo_opening:OnDeletePersonalItem(_, _, deleteList)
  log_tree(bWriteLog and "logic_roleInfo_opening:OnDeletePersonalItem:", deleteList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePersonalOpeningRedPoint) or {}
  local update = false
  for _, id in ipairs(deleteList) do
    if savedData[id] then
      savedData[id] = nil
      update = true
    end
  end
  if update then
    PlayerPrefsSystem.SaveTableToFile_N(savedData, PlayerPrefsSystem.ePlayerPrefsType.ePersonalOpeningRedPoint)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OPENING_REDDOT)
end
function logic_roleInfo_opening:SetCurrentOpeningItemID(openingItemID)
  self.curEquipedItemID = openingItemID
end
function logic_roleInfo_opening:GetEquipedOpeningID()
  return self.curEquipedItemID
end
function logic_roleInfo_opening:GetOpeningList()
  local openingList = {}
  local PersonalOpeningCfg = CDataTable.GetTable("PersonalOpeningCfg")
  for _, v in pairs(PersonalOpeningCfg) do
    local TimeUtil = require("client.common.time_util")
    if (v.IsShow == true or self:IsHaveOpeningItem(v.ID)) and TimeUtil.CheckAfterTimeStr(v.DisplayTime) then
      local haveRed = self:HasRedDotByID(v.ID)
      local info = {
        ID = v.ID,
        OpeningName = v.OpeningName,
        SortID = v.SortID,
        BPPath = v.BPPath,
        SoundID = v.SoundID,
        IconPath = v.IconPath,
        ObtainDescID = v.ObtainDescID,
        ObtainJumpLink = v.ObtainJumpLink,
        HideJumpTime = v.HideJumpTime,
        bRed = haveRed,
        AnimationTimeWhenFinish = tonumber(v.AnimationTimeWhenFinish)
      }
      table.insert(openingList, info)
    end
  end
  local CurSelectID = self:GetEquipedOpeningID()
  table.sort(openingList, function(a, b)
    if a.ID == CurSelectID then
      return true
    elseif b.ID == CurSelectID then
      return false
    else
      local isHaveA = self:IsHaveOpeningItem(a.ID)
      local isHaveB = self:IsHaveOpeningItem(b.ID)
      if isHaveA == isHaveB then
        if a.bRed ~= b.bRed then
          return a.bRed
        end
        return tonumber(a.SortID) < tonumber(b.SortID)
      else
        return isHaveA
      end
    end
  end)
  return openingList
end
function logic_roleInfo_opening:IsCurrentEquipedOpening(openingItemID)
  if self:GetEquipedOpeningID() == openingItemID then
    return true
  end
  return false
end
function logic_roleInfo_opening:IsHaveOpeningItem(openingItemID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:GetHallDepotItemDataByResID(openingItemID) then
    return true
  else
    return false
  end
end
function logic_roleInfo_opening:GetOpeningExpireTime(openingItemID)
  if not openingItemID then
    return nil
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:HasItem(openingItemID, true) then
    return nil
  end
  local info = WardrobeData:GetHallDepotItemDataByResIDAndTimeliness(openingItemID, true)
  if info then
    return info.expireTS
  else
    return nil
  end
end
function logic_roleInfo_opening:on_notify_social_info_bg(openingItemID)
  self:SetCurrentOpeningItemID(openingItemID)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OPENING_REDDOT)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_OPENING_UPDATE)
  self:CheckAndDownloadOpeningBP(openingItemID)
end
function logic_roleInfo_opening:send_set_social_info_bg_req(openingItemID)
  if self:GetEquipedOpeningID() == openingItemID then
    log(bWriteLog and "logic_roleInfo_opening:send_set_social_info_bg_req equipped")
    return
  end
  if openingItemID and not self:IsHaveOpeningItem(openingItemID) then
    log(bWriteLog and "logic_roleInfo_opening:send_set_social_info_bg_req not have")
  end
  local RoleInfoBGHandler = require("client.network.Protocol.RoleInfoBGHandler")
  RoleInfoBGHandler.send_set_social_info_bg_req(ENUM_ITEM_SUBTYPE.PersonalOpening, openingItemID)
end
function logic_roleInfo_opening:on_set_social_info_bg_rsp(res, bg_id)
  if res ~= 0 then
    ShowNotice(9910101)
    return
  end
  self:SetCurrentOpeningItemID(bg_id)
  if bg_id then
    ShowNotice(27736)
  end
end
function logic_roleInfo_opening:HaveRedDot()
  local PersonalOpeningCfg = CDataTable.GetTable("PersonalOpeningCfg")
  if not PersonalOpeningCfg then
    return false
  end
  for id, _ in pairs(PersonalOpeningCfg) do
    if self:HasRedDotByID(tonumber(id)) then
      return true
    end
  end
  return false
end
function logic_roleInfo_opening:ReadRedDot(openingItemID)
  if not openingItemID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePersonalOpeningRedPoint) or {}
  save_data[openingItemID] = true
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.ePersonalOpeningRedPoint)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OPENING_REDDOT)
end
function logic_roleInfo_opening:HasRedDotByID(openingItemID)
  if not openingItemID then
    return false
  end
  if not self:IsHaveOpeningItem(openingItemID) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePersonalOpeningRedPoint)
  if not save_data or not save_data[openingItemID] then
    return true
  end
  return false
end
function logic_roleInfo_opening:CheckAndDownloadOpeningBP(openingItemID)
  local openingCfg = CDataTable.GetTableData("PersonalOpeningCfg", openingItemID)
  local BPPath = openingCfg and openingCfg.BPPath
  log_format(bWriteLog and "logic_roleInfo_opening:CheckAndDownloadOpeningBP openingItemID:%s BPPath:%s", tostring(openingItemID), BPPath)
  if BPPath and BPPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {BPPath}) ~= PufferConst.ENUM_DownloadState.Done then
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {BPPath})
      return false
    else
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_opening = class(CModuleBase, nil, logic_roleInfo_opening)
return Clogic_roleInfo_opening