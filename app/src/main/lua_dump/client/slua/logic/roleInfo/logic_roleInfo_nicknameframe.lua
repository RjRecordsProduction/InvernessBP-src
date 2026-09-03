local logic_roleInfo_nicknameframe = {}
function logic_roleInfo_nicknameframe:DefineAndResetData()
  self.unlockData = nil
  self.friend_nickname_skin_cfg = nil
  self.showDataList = nil
end
function logic_roleInfo_nicknameframe:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_roleInfo_nicknameframe:OnPostSwitchGameStatus pre = " .. tostring(preState) .. ", nextState = " .. tostring(nextState))
  if nextState == GameStatus.Lobby and not self.unlockData then
    local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
    RoleInfoHandler.send_get_friend_nickname_skin_req()
  end
end
function logic_roleInfo_nicknameframe:GetShowDataList()
  return self.showDataList or {}
end
function logic_roleInfo_nicknameframe:HasFrame(id, forever)
  if not self.unlockData or not id then
    return false
  end
  local data = self.unlockData[id]
  if forever then
    return data.expire_ts == 0
  end
  return true
end
function logic_roleInfo_nicknameframe:ProcUnlockData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNickNameFrameRedPoint) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.showDataList = {}
  for id, info in pairs(self.friend_nickname_skin_cfg) do
    local bGetOrDefaultShow = self.unlockData[id] ~= nil or info.is_show == 1
    local displayTime = info.start_display_ts or 0
    local bInShowTime = curTime >= displayTime
    if bGetOrDefaultShow and bInShowTime then
      local cfg = CDataTable.GetTableData("NicknameEffectCfg", id)
      if not cfg then
        log(bWriteLog and "logic_roleInfo_nicknameframe:ProcUnlockData not cfg, id = " .. tostring(id))
      else
        local bRed = false
        if cfg.BPPath ~= "" and self.unlockData[id] ~= nil and not clickData[id] then
          bRed = true
        end
        local frameInfo = {
          ID = cfg.ID,
          BPPath = cfg.BPPath,
          GetDescID = cfg.GetDescID,
          GetJumpUrl = cfg.GetJumpUrl,
          bIsLock = self.unlockData[id] == nil,
          bIsUse = id == DataMgr.roleData.friend_nickname_skin,
          bReddot = bRed,
          expire_ts = self.unlockData[id] and self.unlockData[id].expire_ts,
          display_order = info.display_order,
          access_display_ts = info.access_display_ts,
          levelType = cfg.LevelType,
          level = cfg.Level
        }
        table.insert(self.showDataList, frameInfo)
      end
    end
  end
  local table_util = require("common.table_util")
  local i = 1
  while i <= #self.showDataList do
    if self.showDataList[i].levelType and self.showDataList[i].levelType ~= 0 then
      local itemList = {}
      local levelType = self.showDataList[i].levelType
      local j = i
      while j <= #self.showDataList do
        if self.showDataList[j].levelType == levelType then
          table.insert(itemList, table_util.CopyTable(self.showDataList[j]))
          table.remove(self.showDataList, j)
        else
          j = j + 1
        end
      end
      table.sort(itemList, function(l, r)
        return l.level < r.level
      end)
      local item = table_util.CopyTable(itemList[1])
      item.SubList = itemList
      table.insert(self.showDataList, i, item)
    end
    i = i + 1
  end
  table.sort(self.showDataList, function(a, b)
    local aIsUse = self:IsUsing(a)
    local bIsUse = self:IsUsing(b)
    local aReddot = self:IsReddot(a)
    local bReddot = self:IsReddot(b)
    local aIsLock = self:IsLocked(a)
    local bIsLock = self:IsLocked(b)
    if aIsUse == bIsUse then
      if aReddot == bReddot then
        if aIsLock == bIsLock then
          return a.display_order < b.display_order
        else
          return not aIsLock
        end
      else
        return aReddot
      end
    else
      return aIsUse
    end
  end)
end
function logic_roleInfo_nicknameframe:RemoveRedDot(id, itemIndex)
  log(bWriteLog and "logic_roleInfo_nicknameframe:RemoveRedDot id = " .. tostring(id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNickNameFrameRedPoint) or {}
  clickData[id] = true
  PlayerPrefsSystem.SaveTableToFile_N(clickData, PlayerPrefsSystem.ePlayerPrefsType.eNickNameFrameRedPoint)
  for _, data in ipairs(self.showDataList or {}) do
    if not data.SubList and data.ID == id then
      data.bReddot = false
      break
    elseif data.SubList and next(data.SubList) then
      for _, v in pairs(data.SubList) do
        if v.ID == id then
          v.bReddot = false
          break
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE, nil, true)
end
function logic_roleInfo_nicknameframe:GetShowDataListGetDefaultID()
  return 61300001
end
function logic_roleInfo_nicknameframe:HaveNew()
  local bReddot = false
  for _, data in ipairs(self.showDataList or {}) do
    if data.bReddot then
      bReddot = true
      break
    end
  end
  return bReddot
end
function logic_roleInfo_nicknameframe:GetBPPath(nicknameFrameID)
  if not nicknameFrameID then
    return
  end
  local info = CDataTable.GetTableData("NicknameEffectCfg", nicknameFrameID)
  if not info then
    log(bWriteLog and "logic_roleInfo_nicknameframe:GetBPPath not info, id = " .. tostring(nicknameFrameID))
    return
  end
  if info.BPPath == "" then
    return
  end
  return info.BPPath
end
function logic_roleInfo_nicknameframe:UpdateProfileData(friend_nickname_skin)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if not profile then
    return
  end
  profile.end
function logic_roleInfo_nicknameframe:IsUsing(data)
  if data.SubList then
    for _, v in pairs(data.SubList) do
      if v.bIsUse then
        return v.bIsUse
      end
    end
    return false
  else
    return data.bIsUse
  end
end
function logic_roleInfo_nicknameframe:IsReddot(data)
  if data.SubList then
    for _, v in pairs(data.SubList) do
      if v.bReddot then
        return v.bReddot
      end
    end
    return false
  else
    return data.bReddot
  end
end
function logic_roleInfo_nicknameframe:IsLocked(data)
  if data.SubList then
    for _, v in pairs(data.SubList) do
      if not v.bIsLock then
        return v.bIsLock
      end
    end
    return true
  else
    return data.bIsLock
  end
end
function logic_roleInfo_nicknameframe:ProcNicknameListRsp(friend_nickname_skin_data, friend_nickname_skin_cfg)
  self.unlockData = friend_nickname_skin_data.skins or {}
  DataMgr.roleData.friend_nickname_skin = friend_nickname_skin_data.equip
  self:UpdateProfileData(friend_nickname_skin_data.equip)
  self.friend_nickname_skin_cfg = friend_nickname_skin_cfg or {}
  self:ProcUnlockData()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE)
end
function logic_roleInfo_nicknameframe:ProcUnlockNotify(skin_data, skin_id)
  log_tree("logic_roleInfo_nicknameframe:ProcUnlockNotify skin_data = ", skin_data)
  log(bWriteLog and "logic_roleInfo_nicknameframe:ProcUnlockNotify skin_id = " .. tostring(skin_id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNickNameFrameRedPoint) or {}
  for _, data in ipairs(self.showDataList or {}) do
    if data.SubList then
      for _, v in pairs(data.SubList) do
        if v.ID == skin_id then
          v.bIsUse = true
          v.bReddot = clickData[skin_id] ~= true
          v.bIsLock = false
        else
          v.bIsUse = false
          v.bIsLock = true
        end
      end
    else
      if data.ID == DataMgr.roleData.friend_nickname_skin then
        data.bIsUse = false
      end
      if data.ID == skin_id then
        data.bIsUse = true
        data.bReddot = clickData[skin_id] ~= true
        data.bIsLock = false
      end
    end
  end
  table.sort(self.showDataList or {}, function(a, b)
    local aIsUse = self:IsUsing(a)
    local bIsUse = self:IsUsing(b)
    local aReddot = self:IsReddot(a)
    local bReddot = self:IsReddot(b)
    local aIsLock = self:IsLocked(a)
    local bIsLock = self:IsLocked(b)
    if aIsUse == bIsUse then
      if aIsLock == bIsLock then
        if aReddot == bReddot then
          return a.display_order < b.display_order
        else
          return aReddot
        end
      else
        return not aIsLock
      end
    else
      return aIsUse
    end
  end)
  DataMgr.roleData.friend_nickname_skin = skin_id
  self:UpdateProfileData(skin_id)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE)
end
function logic_roleInfo_nicknameframe:ProcChangeRsp(skin_id)
  log(bWriteLog and "logic_roleInfo_nicknameframe:ProcChangeRsp skin_id = " .. tostring(skin_id))
  if not self.showDataList then
    log(bWriteLog and "logic_roleInfo_nicknameframe:ProcChangeRsp not self.showDataList")
    return
  end
  local bIsChangeFrame = true
  for _, data in ipairs(self.showDataList) do
    if data.SubList then
      for _, v in pairs(data.SubList) do
        v.bIsUse = v.ID == skin_id
      end
    else
      if data.ID == DataMgr.roleData.friend_nickname_skin then
        data.bIsUse = false
      end
      if data.ID == skin_id then
        data.bIsUse = true
      end
    end
  end
  table.sort(self.showDataList, function(a, b)
    local aIsUse = self:IsUsing(a)
    local bIsUse = self:IsUsing(b)
    local aReddot = self:IsReddot(a)
    local bReddot = self:IsReddot(b)
    local aIsLock = self:IsLocked(a)
    local bIsLock = self:IsLocked(b)
    if aIsUse == bIsUse then
      if aIsLock == bIsLock then
        if aReddot == bReddot then
          return a.display_order < b.display_order
        else
          return aReddot
        end
      else
        return not aIsLock
      end
    else
      return aIsUse
    end
  end)
  DataMgr.roleData.friend_nickname_skin = skin_id
  self:UpdateProfileData(skin_id)
  log_tree(bWriteLog and "logic_roleInfo_nicknameframe:ProcChangeRsp self.showDataList", self.showDataList)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE, bIsChangeFrame)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_nicknameframe = class(CModuleBase, nil, logic_roleInfo_nicknameframe)
return Clogic_roleInfo_nicknameframe