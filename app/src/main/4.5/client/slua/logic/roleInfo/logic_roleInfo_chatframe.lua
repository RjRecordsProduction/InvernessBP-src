local logic_roleInfo_chatframe = {}
function logic_roleInfo_chatframe:DefineAndResetData()
  self.unlockData = nil
  self.chat_bubble_cfg = nil
  self.showDataList = nil
end
function logic_roleInfo_chatframe:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_roleInfo_chatframe:OnPostSwitchGameStatus pre = " .. tostring(preState) .. ", nextState = " .. tostring(nextState))
  if nextState == GameStatus.Lobby and not self.unlockData then
    local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
    RoleInfoHandler.send_get_chat_bubble_req()
  end
end
function logic_roleInfo_chatframe:GetShowDataList()
  return self.showDataList or {}
end
function logic_roleInfo_chatframe:HasChatBubble(nItemId, bForever)
  if not (self.unlockData and nItemId) or not self.unlockData[nItemId] then
    return false
  end
  local unlockData = self.unlockData[nItemId]
  if bForever then
    return unlockData.expire_ts == 0
  end
  return true
end
function logic_roleInfo_chatframe:ProcUnlockData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eChatFrameRedPoint) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.showDataList = {}
  for id, info in pairs(self.chat_bubble_cfg) do
    local bGetOrDefaultShow = self.unlockData[id] ~= nil or info.is_show == 1
    local bInShowTime = curTime >= info.start_display_ts
    if bGetOrDefaultShow and bInShowTime then
      local cfg = CDataTable.GetTableData("ChatEffectCfg", id)
      if not cfg then
        log(bWriteLog and "logic_roleInfo_chatframe:ProcUnlockData not cfg, id = " .. tostring(id))
      else
        local bRed = false
        if cfg.BPPath ~= "" and self.unlockData[id] ~= nil and not clickData[id] then
          bRed = true
        end
        local info = {
          ID = cfg.ID,
          BPPath = cfg.BPPath,
          GetDescID = cfg.GetDescID,
          GetJumpUrl = cfg.GetJumpUrl,
          bIsLock = self.unlockData[id] == nil,
          bIsUse = id == DataMgr.roleData.chat_bubble,
          bReddot = bRed,
          expire_ts = self.unlockData[id] and self.unlockData[id].expire_ts,
          display_order = info.display_order,
          access_display_ts = info.access_display_ts,
          level = cfg.Level,
          levelType = cfg.LevelType
        }
        table.insert(self.showDataList, info)
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
function logic_roleInfo_chatframe:RemoveRedDot(id, itemIndex)
  log(bWriteLog and "logic_roleInfo_chatframe:RemoveRedDot id = " .. tostring(id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eChatFrameRedPoint) or {}
  clickData[id] = true
  PlayerPrefsSystem.SaveTableToFile_N(clickData, PlayerPrefsSystem.ePlayerPrefsType.eChatFrameRedPoint)
  for _, data in ipairs(self.showDataList or {}) do
    if not data.SubList and data.ID == id then
      data.bReddot = false
      break
    elseif data.SubList and next(data.SubList) then
      local bBreak = false
      data.bReddot = false
      for _, v in pairs(data.SubList) do
        if v.ID == id then
          v.bReddot = false
          bBreak = true
        end
        if v.bReddot then
          data.bReddot = true
        end
      end
      if bBreak then
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE, nil, true)
end
function logic_roleInfo_chatframe:GetDefaultID()
  local ChatEffectCfg = CDataTable.GetTable("ChatEffectCfg")
  for k, v in pairs(ChatEffectCfg) do
    if v.BPPath == "" then
      return v.ID
    end
  end
  return 0
end
function logic_roleInfo_chatframe:HaveNew()
  local bReddot = false
  for _, data in ipairs(self.showDataList or {}) do
    if data.bReddot then
      bReddot = true
      break
    end
  end
  return bReddot
end
function logic_roleInfo_chatframe:UpdateProfileData(chat_bubble)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if not profile then
    return
  end
  profile.end
function logic_roleInfo_chatframe:IsUsing(data)
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
function logic_roleInfo_chatframe:IsReddot(data)
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
function logic_roleInfo_chatframe:IsLocked(data)
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
function logic_roleInfo_chatframe:ProcChatListRsp(chat_bubble_data, chat_bubble_cfg)
  self.unlockData = chat_bubble_data.bubbles or {}
  DataMgr.roleData.chat_bubble = chat_bubble_data.equip
  self:UpdateProfileData(chat_bubble_data.equip)
  self.chat_bubble_cfg = chat_bubble_cfg or {}
  self:ProcUnlockData()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE)
end
function logic_roleInfo_chatframe:ProcUnlockNotify(chat_bubble_data, bubble_id)
  log_tree("logic_roleInfo_chatframe:ProcUnlockNotify chat_bubble_data = ", chat_bubble_data)
  log(bWriteLog and "logic_roleInfo_chatframe:ProcUnlockNotify bubble_id = " .. tostring(bubble_id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eChatFrameRedPoint) or {}
  for _, data in ipairs(self.showDataList or {}) do
    if data.ID == DataMgr.roleData.chat_bubble then
      data.bIsUse = false
    end
    if data.ID == bubble_id then
      data.bIsUse = true
      data.bReddot = clickData[bubble_id] ~= false
      data.bIsLock = false
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
  DataMgr.roleData.chat_bubble = bubble_id
  self:UpdateProfileData(bubble_id)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE)
end
function logic_roleInfo_chatframe:ProcChangeRsp(bubble_id)
  log(bWriteLog and "logic_roleInfo_chatframe:ProcChangeRsp bubble_id = " .. tostring(bubble_id))
  if not self.showDataList then
    log(bWriteLog and "logic_roleInfo_chatframe:ProcChangeRsp not self.showDataList")
    return
  end
  local bIsChangeFrame = true
  for _, data in ipairs(self.showDataList) do
    if data.SubList then
      for _, v in pairs(data.SubList) do
        v.bIsUse = v.ID == bubble_id
      end
    else
      if data.ID == DataMgr.roleData.chat_bubble then
        data.bIsUse = false
      end
      if data.ID == bubble_id then
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
  DataMgr.roleData.chat_bubble = bubble_id
  self:UpdateProfileData(bubble_id)
  log_tree(bWriteLog and "logic_roleInfo_chatframe:ProcChangeRsp self.showDataList", self.showDataList)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE, bIsChangeFrame)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_chatframe = class(CModuleBase, nil, logic_roleInfo_chatframe)
return Clogic_roleInfo_chatframe