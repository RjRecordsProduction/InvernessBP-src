local logic_roleInfo_socialcardframe = {}
local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
local DefaultFrame = 62410001
function logic_roleInfo_socialcardframe:DefineAndResetData()
  self.frames = {}
  self.curEquipFrame = DefaultFrame
  self.FrameMap = nil
  self.FrameList = nil
  self.bDataReady = false
end
function logic_roleInfo_socialcardframe:GetDefaultSkinID()
  return DefaultFrame
end
function logic_roleInfo_socialcardframe:IsFeatureOpen()
  return LobbySystem.CheckOpen(BP_ENUM_SKIN_PERSONALIZATION_SOCIALCARD_FRAME_ID)
end
function logic_roleInfo_socialcardframe:GetCurrentEquipID()
  return self.curEquipFrame or DefaultFrame
end
function logic_roleInfo_socialcardframe:getCurSocialCardFrame()
  return self.curEquipFrame or DefaultFrame
end
function logic_roleInfo_socialcardframe:InitFrameMap()
  if self.FrameMap then
    return
  end
  self.FrameMap = {}
  local RawConfig = CDataTable.GetTable("SocialCardFrameConfig")
  if not RawConfig then
    log(bWriteLog and "[logic_roleInfo_socialcardframe] nil SocialCardFrameConfig")
    return
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, frame_config in pairs(RawConfig) do
    local item_data = {}
    item_data.config = frame_config
    if frame_config.SkinID == DefaultFrame or WardrobeData:GetHallDepotItemDataByResID(frame_config.SkinID) then
      item_data.bLock = false
    else
      item_data.bLock = true
    end
    item_data.bRed = false
    item_data.expire_ts = 0
    self.FrameMap[frame_config.SkinID] = item_data
  end
end
function logic_roleInfo_socialcardframe:RefreshAllFrameTime()
  if not self.FrameMap or not next(self.FrameMap) then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local server_ts = TimeUtil.GetServerTimeInSec()
  for _, frame_data in pairs(self.FrameMap) do
    if type(frame_data.expire_ts) == "number" and frame_data.expire_ts ~= 0 then
      frame_data.bLock = server_ts >= frame_data.expire_ts
    end
  end
end
function logic_roleInfo_socialcardframe:CheckFrameTimeValid(frame_id)
  if not frame_id then
    return false
  end
  local frame_data = self.FrameMap and self.FrameMap[frame_id]
  if not frame_data then
    log(bWriteLog and "[logic_roleInfo_socialcardframe] invalid frame data: " .. tostring(frame_id))
    return false
  end
  if frame_data.expire_ts == 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() < frame_data.expire_ts
end
function logic_roleInfo_socialcardframe:SortFrameList()
  if not self.FrameMap then
    return
  end
  self.FrameList = {}
  for _, frame_data in pairs(self.FrameMap) do
    if frame_data.bLock and not frame_data.bRed and frame_data.SubList then
      for _, v in ipairs(frame_data.SubList) do
        if v.bRed then
          frame_data.bRed = true
          break
        end
      end
    end
    table.insert(self.FrameList, frame_data)
  end
  local CurSelectID = self.curEquipFrame or DefaultFrame
  table.sort(self.FrameList, function(a, b)
    if a.config.SkinID == CurSelectID then
      return true
    elseif b.config.SkinID == CurSelectID then
      return false
    elseif a.bRed == b.bRed then
      if a.bLock == b.bLock then
        return tonumber(a.config.DispalySortInfo) < tonumber(b.config.DispalySortInfo)
      else
        return b.bLock
      end
    else
      return a.bRed
    end
  end)
end
function logic_roleInfo_socialcardframe:GetFrameList()
  if not self.FrameList then
    self:InitFrameMap()
    if self.FrameMap and next(self.FrameMap) then
      self:SortFrameList()
    end
  end
  local frameList = {}
  if self.FrameList and next(self.FrameList) then
    for _, v in ipairs(self.FrameList) do
      table.insert(frameList, v)
    end
  end
  return frameList
end
function logic_roleInfo_socialcardframe:IsHaveFrame(frame_id)
  if not frame_id then
    return false
  end
  if frame_id == DefaultFrame then
    return true
  end
  if self.FrameMap and self.FrameMap[frame_id] then
    return not self.FrameMap[frame_id].bLock
  end
  return false
end
function logic_roleInfo_socialcardframe:GetSkinPath(frame_id)
  local personalPreviewUMG = ""
  local chatPreviewUMG = ""
  local socialCardPreviewUMG = ""
  local personInfoFrameUMG = ""
  local socialCardFrameUMG = ""
  local bLoopAnim = false
  if not frame_id then
    return personalPreviewUMG, chatPreviewUMG, socialCardPreviewUMG, personInfoFrameUMG, socialCardFrameUMG, bLoopAnim
  end
  local SkinCfg = CDataTable.GetTableData("SocialCardFrameConfig", frame_id)
  if not SkinCfg then
    log(bWriteLog and "[logic_roleInfo_socialcardframe] nil skin config for id: " .. tostring(frame_id))
    return personalPreviewUMG, chatPreviewUMG, socialCardPreviewUMG, personInfoFrameUMG, socialCardFrameUMG, bLoopAnim
  end
  if SkinCfg.PersonalPreviewUMG and SkinCfg.PersonalPreviewUMG ~= "" then
    personalPreviewUMG = SkinCfg.PersonalPreviewUMG
  end
  if SkinCfg.ChatPreviewUMG and SkinCfg.ChatPreviewUMG ~= "" then
    chatPreviewUMG = SkinCfg.ChatPreviewUMG
  end
  if SkinCfg.SocialCardPreviewUMG and SkinCfg.SocialCardPreviewUMG ~= "" then
    socialCardPreviewUMG = SkinCfg.SocialCardPreviewUMG
  end
  if SkinCfg.PersonInfoFrameUMG and SkinCfg.PersonInfoFrameUMG ~= "" then
    personInfoFrameUMG = SkinCfg.PersonInfoFrameUMG
  end
  if SkinCfg.SocialCardFrameUMG and SkinCfg.SocialCardFrameUMG ~= "" then
    socialCardFrameUMG = SkinCfg.SocialCardFrameUMG
  end
  bLoopAnim = SkinCfg.CanLoop and SkinCfg.CanLoop == 1
  return personalPreviewUMG, chatPreviewUMG, socialCardPreviewUMG, personInfoFrameUMG, socialCardFrameUMG, bLoopAnim
end
function logic_roleInfo_socialcardframe:IsCanShow(frame_id)
  local config = CDataTable.GetTableData("SocialCardFrameConfig", frame_id)
  return self:IsCanShowByCfg(config)
end
function logic_roleInfo_socialcardframe:IsCanShowByCfg(config)
  if config and config.bShow then
    local startTime = config.StartDisplayTimeOfAcquisitionPath
    if not startTime or startTime == "" then
      return true
    end
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local SourceShowTime = tonumber(TimeUtil.TimeStringToUnixstamp(startTime))
    if nowTime >= SourceShowTime then
      return true
    end
  end
  return false
end
function logic_roleInfo_socialcardframe:RemoveRedDot(frame_id)
  if not frame_id then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameReddot) or {}
  save_data[frame_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameReddot)
  if self.FrameMap and self.FrameMap[frame_id] then
    self.FrameMap[frame_id].bRed = false
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_REDDOT)
end
function logic_roleInfo_socialcardframe:HaveRed()
  local logic_socialcardframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_socialcardframe)
  if not logic_socialcardframe:IsFeatureOpen() then
    return false
  end
  if not self.FrameMap then
    return false
  end
  for _, frame_data in pairs(self.FrameMap) do
    if self:IsCanShowByCfg(frame_data.config) and frame_data.bRed then
      return true
    end
  end
  return false
end
function logic_roleInfo_socialcardframe:get_frame_list_req()
  log(bWriteLog and "[logic_roleInfo_socialcardframe] get_frame_list_req")
  RoleInfoHandler.send_get_social_card_frame_req()
end
function logic_roleInfo_socialcardframe:proc_get_social_card_frame_rsp(allframes)
  log(bWriteLog and "logic_roleInfo_socialcardframe:proc_get_social_card_frame_rsp")
  log_tree(bWriteLog and "logic_roleInfo_socialcardframe:proc_get_social_card_frame_rsp allframes =", allframes)
  if not self.FrameMap then
    self:InitFrameMap()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameReddot) or {}
  if allframes.frames then
    for frame_id, frame_data in pairs(allframes.frames) do
      if self.FrameMap[frame_id] then
        self.FrameMap[frame_id].bLock = false
        self.FrameMap[frame_id].expire_ts = frame_data.expire_ts or 0
        if not save_data[frame_id] then
          self.FrameMap[frame_id].bRed = true
        end
      end
    end
  end
  self.curEquipFrame = allframes.equip or DefaultFrame
  DataMgr.roleData.social_card_frame = self.curEquipFrame
  self.bDataReady = true
  self:RefreshAllFrameTime()
  self:SortFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_INFO)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_REDDOT)
end
function logic_roleInfo_socialcardframe:equip_frame_req(frame_id, bEquip)
  log(bWriteLog and "[logic_roleInfo_socialcardframe] equip_frame_req: " .. tostring(frame_id) .. " equip: " .. tostring(bEquip))
  if bEquip and not self:CheckFrameTimeValid(frame_id) then
    log(bWriteLog and "[logic_roleInfo_socialcardframe] frame time not valid")
    return
  end
  if bEquip then
    RoleInfoHandler.send_set_social_card_frame_req(frame_id)
  else
    RoleInfoHandler.send_set_social_card_frame_req(DefaultFrame)
  end
end
function logic_roleInfo_socialcardframe:send_set_social_card_frame_req(frame_id)
  log(bWriteLog and "logic_roleInfo_socialcardframe:send_set_social_card_frame_req frame_id =" .. tostring(frame_id))
  RoleInfoHandler.send_set_social_card_frame_req(frame_id)
end
function logic_roleInfo_socialcardframe:proc_set_social_card_frame_rsp(frame_id)
  log(bWriteLog and "logic_roleInfo_socialcardframe:proc_set_social_card_frame_rsp frame_id =" .. tostring(frame_id))
  self.curEquipFrame = frame_id
  DataMgr.roleData.social_card_frame = frame_id
  self:SortFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_INFO)
end
function logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_notify(social_card_frame_data, frame_id)
  log(bWriteLog and "logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_ntf frame_id =" .. tostring(frame_id))
  if not self.FrameMap then
    self:InitFrameMap()
  end
  if social_card_frame_data and next(social_card_frame_data) then
    if social_card_frame_data.frames and next(social_card_frame_data.frames) then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSocialCardFrameReddot) or {}
      for fid, fdata in pairs(social_card_frame_data.frames) do
        if self.FrameMap[fid] then
          self.FrameMap[fid].bLock = false
          self.FrameMap[fid].expire_ts = fdata.expire_ts or 0
          if not save_data[fid] then
            self.FrameMap[fid].bRed = true
          end
        end
      end
      if social_card_frame_data.equip then
        self.curEquipFrame = social_card_frame_data.equip
        DataMgr.roleData.social_card_frame = self.curEquipFrame
      else
        log(bWriteLog and "logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_notify equip is nil")
      end
    else
      log(bWriteLog and "logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_notify frames is nil")
    end
  else
    log(bWriteLog and "logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_notify social_card_frame_data is nil")
  end
  if frame_id and self.curEquipFrame == DefaultFrame and frame_id ~= DefaultFrame then
    self:equip_frame_req(frame_id, true)
  end
  self:RefreshAllFrameTime()
  self:SortFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_INFO)
end
function logic_roleInfo_socialcardframe:proc_del_social_card_frame_notify(frame_id)
  log(bWriteLog and "logic_roleInfo_socialcardframe:proc_del_social_card_frame_notify frame_id =" .. tostring(frame_id))
  if self.FrameMap and self.FrameMap[frame_id] then
    self.FrameMap[frame_id].bLock = true
    self.FrameMap[frame_id].bRed = false
    self.FrameMap[frame_id].expire_ts = 0
  end
  if self.curEquipFrame == frame_id then
    self.curEquipFrame = DefaultFrame
    DataMgr.roleData.social_card_frame = DefaultFrame
  end
  self:SortFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIALCARD_FRAME_INFO)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_socialcardframe = class(CModuleBase, nil, logic_roleInfo_socialcardframe)
return Clogic_roleInfo_socialcardframe