local logic_roleinfo_carte_frame = {
  params = {DefaultSkinID = 61100001}
}
function logic_roleinfo_carte_frame:RegistEvents()
end
function logic_roleinfo_carte_frame:OnLogOut()
end
function logic_roleinfo_carte_frame:GetCarteFrameList()
  local carteFrameList = {}
  if self.CarteFrameList and next(self.CarteFrameList) then
    for _, v in ipairs(self.CarteFrameList) do
      table.insert(carteFrameList, v)
    end
  end
  return carteFrameList
end
function logic_roleinfo_carte_frame:SortCarteFrameList()
  if not self.CarteFrameMap then
    return
  end
  self.CarteFrameList = {}
  for index, frame_data in pairs(self.CarteFrameMap) do
    if frame_data.bLock and not frame_data.bRed and frame_data.SubList then
      for _, v in ipairs(frame_data.SubList) do
        if v.bRed then
          frame_data.bRed = true
          break
        end
      end
    end
    table.insert(self.CarteFrameList, frame_data)
  end
  local CurSelectID = self.params.DefaultSkinID
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.carte_frame_equip_id then
    CurSelectID = SocialCardSystem.SocialCard.carte_frame_equip_id
  end
  table.sort(self.CarteFrameList, function(a, b)
    if a.config.SkinID == CurSelectID then
      return true
    elseif b.config.SkinID == CurSelectID then
      return false
    elseif a.bRed == b.bRed then
      if a.bLock == b.bLock then
        return tonumber(a.config.ShowIndex) < tonumber(b.config.ShowIndex)
      else
        return b.bLock
      end
    else
      return a.bRed
    end
  end)
end
function logic_roleinfo_carte_frame:GetSkinPath(frame_id)
  local effect_bp_path = ""
  local roleinfo_bp_path = ""
  local skin_path = ""
  local bLoopAnim = false
  if not frame_id then
    return effect_bp_path, skin_path, roleinfo_bp_path, bLoopAnim
  end
  local SkinCfg = CDataTable.GetTableData("CarteFrameConfig", frame_id)
  if not SkinCfg then
    log(bWriteLog and "[logic_roleinfo_carte_frame] nil skin config for id: " .. tostring(frame_id))
    return effect_bp_path, skin_path, roleinfo_bp_path
  end
  if SkinCfg.EffectBP and SkinCfg.EffectBP ~= "" then
    effect_bp_path = SkinCfg.EffectBP
  end
  if SkinCfg.SkinPath and SkinCfg.SkinPath ~= "" then
    skin_path = SkinCfg.SkinPath
  end
  if SkinCfg.RoleInfoEffectBP and SkinCfg.RoleInfoEffectBP ~= "" then
    roleinfo_bp_path = SkinCfg.RoleInfoEffectBP
  end
  bLoopAnim = SkinCfg.bLoopAnim
  return effect_bp_path, skin_path, roleinfo_bp_path, bLoopAnim
end
function logic_roleinfo_carte_frame:GetDefaultSkinID()
  return self.params.DefaultSkinID
end
function logic_roleinfo_carte_frame:IsCanShow(frame_id)
  local config = CDataTable.GetTableData("CarteFrameConfig", frame_id)
  return self:IsCanShowByCfg(config)
end
function logic_roleinfo_carte_frame:IsCanShowByCfg(config)
  if config and config.SourceShowTime and config.bShow then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local SourceShowTime = tonumber(TimeUtil.TimeStringToUnixstamp(config.SourceShowTime))
    if nowTime >= SourceShowTime then
      return true
    end
  end
  return false
end
function logic_roleinfo_carte_frame:IsHaveCarteFrame(id)
  if not self.CarteFrameMap then
    return false
  end
  return not self.CarteFrameMap[id].bLock
end
function logic_roleinfo_carte_frame:HasCarteFrame(id, forever)
  if not self.CarteFrameMap or not id then
    return false
  end
  local data = self.CarteFrameMap[id]
  if forever then
    return not data.bLock and data.expire_ts == 0
  else
    return not data.bLock
  end
end
function logic_roleinfo_carte_frame:GetCurrentCrateFrameBGID()
  local logic_social_card = require("client.slua.logic.lobby.Left.logic_social_card")
  return logic_social_card.SocialCard.carte_frame_equip_id
end
function logic_roleinfo_carte_frame:GetCurrentCrateFrameBGCfg()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local profile = LobbySocialSystem.GetProfileByUID(RoleInfoSystem.CurShowPlayerInfoUid)
  if not profile then
    return
  end
  local logic_social_card = require("client.slua.logic.lobby.Left.logic_social_card")
  local SocialCardBGInfo = CDataTable.GetTableData("CarteFrameConfig", logic_social_card.GetCarteFrameEquipIdByProfile(profile))
  return SocialCardBGInfo
end
function logic_roleinfo_carte_frame:GetCrateFrameBGCfg(id)
  local SocialCardBGInfo = CDataTable.GetTableData("CarteFrameConfig", id)
  return SocialCardBGInfo
end
function logic_roleinfo_carte_frame:get_carte_frame_list_req()
  log(bWriteLog and "[logic_roleinfo_carte_frame] get_carte_frame_list_req")
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_get_carte_frame_list_req()
end
function logic_roleinfo_carte_frame:InitCarteFrameMap()
  if self.CarteFrameMap then
    return
  end
  self.CarteFrameMap = {}
  local RawCarteFrameConfig = CDataTable.GetTable("CarteFrameConfig")
  if not RawCarteFrameConfig then
    log(bWriteLog and "[logic_roleinfo_carte_frame] nil RawCarteFrameConfig")
    return
  end
  for _, frame_config in pairs(RawCarteFrameConfig) do
    local item_data = {}
    item_data.config = frame_config
    item_data.bLock = true
    item_data.bRed = false
    item_data.expire_ts = 0
    self.CarteFrameMap[frame_config.SkinID] = item_data
  end
end
function logic_roleinfo_carte_frame:get_carte_frame_list_rsp(err_code, active_frame_list, equip_frame_id)
  log(bWriteLog and "[logic_roleinfo_carte_frame] get_carte_frame_list_rsp: " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  if not self.CarteFrameMap then
    self:InitCarteFrameMap()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCarteFrameSkinReddot) or {}
  for frame_id, frame_data in pairs(active_frame_list) do
    if self.CarteFrameMap[frame_id] then
      self.CarteFrameMap[frame_id].bLock = false
      self.CarteFrameMap[frame_id].expire_ts = frame_data.expire_ts or 0
      if not save_data[frame_id] then
        self.CarteFrameMap[frame_id].bRed = true
      end
    end
  end
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard then
    SocialCardSystem.SocialCard.carte_frame_equip_id = equip_frame_id
  end
  self:RefreshAllFrameTime()
  self:SortCarteFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_UPDATE)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARTE_FRAME_REDDOT)
end
function logic_roleinfo_carte_frame:on_notify_carte_frame_update(active_frame_list, new_frame_id)
  log(bWriteLog and "[logic_roleinfo_carte_frame] on_notify_carte_frame_update: " .. tostring(new_frame_id))
  if not self.CarteFrameMap then
    self:InitCarteFrameMap()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCarteFrameSkinReddot) or {}
  for frame_id, frame_data in pairs(active_frame_list) do
    if self.CarteFrameMap[frame_id] then
      self.CarteFrameMap[frame_id].bLock = false
      self.CarteFrameMap[frame_id].expire_ts = frame_data.expire_ts or 0
      if not save_data[frame_id] then
        self.CarteFrameMap[frame_id].bRed = true
      end
    end
  end
  local CurSelectID = self.params.DefaultSkinID
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.carte_frame_equip_id then
    CurSelectID = SocialCardSystem.SocialCard.carte_frame_equip_id
  end
  if CurSelectID == self.params.DefaultSkinID and CurSelectID ~= new_frame_id then
    self:equip_carte_frame_req(new_frame_id, true)
  end
  self:RefreshAllFrameTime()
  self:SortCarteFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_UPDATE)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARTE_FRAME_REDDOT)
end
function logic_roleinfo_carte_frame:equip_carte_frame_req(frame_id, bEquip)
  log(bWriteLog and "[logic_roleinfo_carte_frame] equip_carte_frame_req: " .. tostring(frame_id) .. " with euiq: " .. tostring(bEquip))
  if bEquip and not self:CheckFrameTimeValid(frame_id) then
    log(bWriteLog and "[logic_roleinfo_carte_frame] frame time not valid")
    return
  end
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_equip_carte_frame_req(frame_id, bEquip)
end
function logic_roleinfo_carte_frame:equip_carte_frame_rsp(err_code, frame_id, bEquip)
  log(bWriteLog and "[logic_roleinfo_carte_frame] equip_carte_frame_rsp: " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.SocialCard then
    if bEquip then
      SocialCardSystem.SocialCard.carte_frame_equip_id = frame_id
      ShowNotice(68708)
    else
      SocialCardSystem.SocialCard.carte_frame_equip_id = self.params.DefaultSkinID
    end
  end
  self:SortCarteFrameList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_CHANGE)
end
function logic_roleinfo_carte_frame:RemoveRedDot(frame_id)
  if not frame_id then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCarteFrameSkinReddot) or {}
  save_data[frame_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eCarteFrameSkinReddot)
  if self.CarteFrameMap[frame_id] then
    self.CarteFrameMap[frame_id].bRed = false
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARTE_FRAME_REDDOT)
end
function logic_roleinfo_carte_frame:HaveRed()
  if not self.CarteFrameMap then
    return false
  end
  for _, frame_data in pairs(self.CarteFrameMap) do
    if self:IsCanShowByCfg(frame_data.config) and frame_data.bRed then
      return true
    end
  end
  return false
end
function logic_roleinfo_carte_frame:RefreshAllFrameTime()
  if not self.CarteFrameMap or not next(self.CarteFrameMap) then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local server_ts = TimeUtil.GetServerTimeInSec()
  for _, frame_data in pairs(self.CarteFrameMap) do
    if type(frame_data.expire_ts) == "number" and frame_data.expire_ts ~= 0 then
      frame_data.bLock = server_ts >= frame_data.expire_ts
    end
  end
end
function logic_roleinfo_carte_frame:CheckFrameTimeValid(frame_id)
  if not frame_id then
    return
  end
  local frame_data = self.CarteFrameMap[frame_id]
  if not frame_data then
    log(bWriteLog and "[logic_roleinfo_carte_frame] invalid frame data: " .. tostring(frame_id))
    return
  end
  if frame_data.expire_ts == 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() < frame_data.expire_ts
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleinfo_carte_frame = class(CModuleBase, nil, logic_roleinfo_carte_frame)
return Clogic_roleinfo_carte_frame