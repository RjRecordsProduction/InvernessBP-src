local logic_social_card_bg = {DefaultSocialCardBGID = 61200001, CurrentSocialCardBGID = 61200001}
function logic_social_card_bg:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_SOCIAL_CARD_BG, self.OnAddSocialCardBG, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_SOCIAL_CARD_BG, self.OnDeleteSocialCardBG, self)
end
function logic_social_card_bg:OnAddSocialCardBG()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIAL_CARD_REDDOT)
end
function logic_social_card_bg:OnDeleteSocialCardBG(_, _, deleteList)
  log_tree(bWriteLog and "logic_social_card_bg:OnDeleteSocialCardBG:", deleteList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameSkinReddot) or {}
  local update = false
  for _, id in ipairs(deleteList) do
    if save_data[id] then
      save_data[id] = nil
      update = true
    end
  end
  if update then
    PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameSkinReddot)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIAL_CARD_REDDOT)
end
function logic_social_card_bg:GetDefaultSocialCardBGID()
  return logic_social_card_bg.DefaultSocialCardBGID
end
function logic_social_card_bg:GetCurrentSocialCardBGID()
  return logic_social_card_bg.CurrentSocialCardBGID
end
function logic_social_card_bg:GetCurrentSocialCardBG()
  local SocialCardBGInfo = CDataTable.GetTableData("SocialCardBGInfo", logic_social_card_bg.CurrentSocialCardBGID)
  return SocialCardBGInfo
end
function logic_social_card_bg:GetSocialCardBG(currentSkinID)
  local SocialCardBGInfo = CDataTable.GetTableData("SocialCardBGInfo", currentSkinID)
  return SocialCardBGInfo
end
function logic_social_card_bg:GetSocialCardBGList()
  local socialCardBGList = {}
  local SocialCardBGInfo = CDataTable.GetTable("SocialCardBGInfo")
  if not SocialCardBGInfo then
    return socialCardBGList
  end
  local TimeUtil = require("client.common.time_util")
  local redList = {}
  for _, frame_data in pairs(SocialCardBGInfo) do
    local haveRed = false
    if frame_data ~= nil and (frame_data.IsShow == 1 or self:IsHaveCardSkin(frame_data.ID)) and TimeUtil.CheckAfterTimeStr(frame_data.StartDisplayTimeOfAcquisitionPath) then
      local temp_data = {
        ID = frame_data.ID,
        SocialCardBGName = frame_data.SocialCardBGName,
        IsShow = frame_data.IsShow,
        DispalySortInfo = frame_data.DispalySortInfo,
        CanLoop = frame_data.CanLoop,
        Type = frame_data.Type,
        Level = frame_data.Level,
        MainUMG = frame_data.MainUMG,
        PersonInfoBGUMG = frame_data.PersonInfoBGUMG,
        UserTimeInfo = frame_data.UserTimeInfo,
        AcquiSitionMethod = frame_data.AcquiSitionMethod,
        remarks = frame_data.remarks,
        AcquiSitionMethodLink = frame_data.AcquiSitionMethodLink,
        StartDisplayTimeOfAcquisitionPath = frame_data.StartDisplayTimeOfAcquisitionPath
      }
      table.insert(socialCardBGList, temp_data)
      haveRed = self:HasRedDotByID(temp_data.ID)
      if not haveRed and temp_data.SubList then
        for _, v in ipairs(temp_data.SubList) do
          if self:HasRedDotByID(v.ID) then
            haveRed = true
            break
          end
        end
      end
      redList[frame_data.ID] = haveRed
    end
  end
  local CurSelectID = logic_social_card_bg.CurrentSocialCardBGID or logic_social_card_bg.DefaultSocialCardBGID
  table.sort(socialCardBGList, function(a, b)
    if a.ID == CurSelectID then
      return true
    elseif b.ID == CurSelectID then
      return false
    else
      local isHaveA = self:IsHaveCardSkin(a.ID)
      local isHaveB = self:IsHaveCardSkin(b.ID)
      if a.ID == logic_social_card_bg.DefaultSocialCardBGID then
        isHaveA = true
      end
      if b.ID == logic_social_card_bg.DefaultSocialCardBGID then
        isHaveB = true
      end
      if isHaveA == isHaveB then
        if redList[a.ID] ~= redList[b.ID] then
          return redList[a.ID]
        end
        return tonumber(a.DispalySortInfo) < tonumber(b.DispalySortInfo)
      else
        return isHaveA
      end
    end
  end)
  return socialCardBGList
end
function logic_social_card_bg:IsCurrentSocialCardBGID(social_card_bg_id)
  if not social_card_bg_id then
    return false
  end
  if logic_social_card_bg.CurrentSocialCardBGID == social_card_bg_id then
    return true
  end
  return false
end
function logic_social_card_bg:IsDefaultSocialCardBGID(social_card_bg_id)
  if not social_card_bg_id then
    return false
  end
  if logic_social_card_bg.DefaultSocialCardBGID == social_card_bg_id then
    return true
  end
  return false
end
function logic_social_card_bg:GetSocialCardMainBGPath(social_card_bg_id)
  local SocialCardBGItem = CDataTable.GetTableData("SocialCardBGInfo", social_card_bg_id)
  if SocialCardBGItem then
    return SocialCardBGItem.MainUMG
  else
    return ""
  end
end
function logic_social_card_bg:CheckSocialCardCanLoop(social_card_bg_id)
  local SocialCardBGItem = CDataTable.GetTableData("SocialCardBGInfo", social_card_bg_id)
  if SocialCardBGItem.CanLoop == 1 then
    return true
  else
    return false
  end
end
function logic_social_card_bg:GetSocialCardPersonBGPath(social_card_bg_id)
  local SocialCardBGItem = CDataTable.GetTableData("SocialCardBGInfo", social_card_bg_id)
  if SocialCardBGItem then
    return SocialCardBGItem.PersonInfoBGUMG
  else
    return ""
  end
end
function logic_social_card_bg:IsHaveCardSkin(social_card_bg_id)
  if not social_card_bg_id then
    return false
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:GetHallDepotItemDataByResID(social_card_bg_id) then
    return true
  else
    return false
  end
end
function logic_social_card_bg:GetCardSkinTime(social_card_bg_id)
  if not social_card_bg_id then
    return nil
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:HasItem(social_card_bg_id, true) then
    return 0
  end
  local info = WardrobeData:GetHallDepotItemDataByResIDAndTimeliness(social_card_bg_id, true)
  if info then
    return info.expireTS
  else
    return nil
  end
end
function logic_social_card_bg:IsCanShow(skinID)
  local config = CDataTable.GetTableData("SocialCardBGInfo", skinID)
  if config and config.StartDisplayTimeOfAcquisitionPath and config.IsShow then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local StartDisplayTimeOfAcquisitionPath = tonumber(TimeUtil.TimeStringToUnixstamp(config.StartDisplayTimeOfAcquisitionPath))
    if nowTime >= StartDisplayTimeOfAcquisitionPath then
      return true
    end
  end
  return false
end
function logic_social_card_bg:on_notify_social_card_floor(social_card_bg_id)
  logic_social_card_bg.CurrentSocialCardBGID = social_card_bg_id
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIAL_CARD_REDDOT)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SOCIAL_CARD_UPDATE)
end
function logic_social_card_bg:send_set_social_card_floor_req(social_card_bg_id)
  if logic_social_card_bg.CurrentSocialCardBGID == social_card_bg_id then
    log(bWriteLog and "logic_social_card_bg:send_set_social_card_floor_req equipped")
    return
  end
  if not self:IsHaveCardSkin(social_card_bg_id) then
    log(bWriteLog and "logic_social_card_bg:send_set_social_card_floor_req not have")
  end
  local SocialCardBGHandler = require("client.network.Protocol.SocialCardBGHandler")
  SocialCardBGHandler.send_set_social_card_floor_req(social_card_bg_id)
end
function logic_social_card_bg:on_set_social_card_floor_rsp(ret)
  if ret ~= 0 then
    ShowNotice(9910101)
    return
  end
  ShowNotice(27736)
end
function logic_social_card_bg:HaveRedDot()
  local SocialCardBGInfo = CDataTable.GetTable("SocialCardBGInfo")
  if not SocialCardBGInfo then
    return false
  end
  for id, _ in pairs(SocialCardBGInfo) do
    local skinID = tonumber(id)
    if self:HasRedDotByID(skinID) and self:IsCanShow(skinID) then
      return true
    end
  end
  return false
end
function logic_social_card_bg:ReadRedDot(social_card_bg_id)
  if not social_card_bg_id then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameSkinReddot) or {}
  save_data[social_card_bg_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameSkinReddot)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIAL_CARD_REDDOT)
end
function logic_social_card_bg:HasRedDotByID(social_card_bg_id)
  if not social_card_bg_id then
    return false
  end
  if not self:IsHaveCardSkin(social_card_bg_id) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameSkinReddot)
  if not save_data or not save_data[social_card_bg_id] then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_social_card_bg = class(CModuleBase, nil, logic_social_card_bg)
return Clogic_social_card_bg