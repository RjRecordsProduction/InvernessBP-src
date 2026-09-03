local logic_roleInfo_TeamUpFrame = {}
local skinList
local defaultSkinId = 61010001
function logic_roleInfo_TeamUpFrame:RegistEvents()
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CALLBACK_EXCHANGE, self.OnJumpUrl)
end
function logic_roleInfo_TeamUpFrame:OnLogOut()
  skinList = nil
end
function logic_roleInfo_TeamUpFrame:OnJumpUrl(_, url_params)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Integration_Assembly_Exchange_UIBP, true, url_params.itemId)
end
function logic_roleInfo_TeamUpFrame:GetSkinList()
  local TimeUtil = require("client.common.time_util")
  local res_list = {}
  if skinList then
    for _, v in pairs(skinList) do
      if TimeUtil.CheckAfterTimeStr(v.cfg.BeginShowTime) then
        table.insert(res_list, v)
      end
    end
  end
  log_tree(bWriteLog and "logic_roleInfo_TeamUpFrame:GetSkinList res_list:", res_list)
  return res_list
end
function logic_roleInfo_TeamUpFrame:HasSkin(id, forever)
  if not skinList then
    return false
  end
  for _, data in ipairs(skinList) do
    if data.SubList then
      for _, v in pairs(data.SubList) do
        if v.cfg.ID == id then
          if v.bIsLock then
            return false
          end
          if forever then
            return (v.expireTime or 0) == 1
          end
          return true
        end
      end
    elseif data.cfg.ID == id then
      if data.bIsLock then
        return false
      end
      if forever then
        return (data.expireTime or 0) == 1
      end
      return true
    end
  end
  return false
end
function logic_roleInfo_TeamUpFrame:GetSkinDataById(id)
  local config = CDataTable.GetTable("TeamUpPopFrame")
  if not config then
    return
  end
  return config[id]
end
function logic_roleInfo_TeamUpFrame:RemoveRedDot(id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamUpFrameSkinRedPoint) or {}
  redPointData[DataMgr.roleData.uid][id] = nil
  PlayerPrefsSystem.SaveTableToFile_N(redPointData, PlayerPrefsSystem.ePlayerPrefsType.eTeamUpFrameSkinRedPoint)
  for _, data in ipairs(skinList) do
    if not data.SubList and data.cfg.ID == id then
      data.bReddot = false
      break
    elseif data.SubList and next(data.SubList) then
      for _, v in pairs(data.SubList) do
        if v.cfg.ID == id then
          v.bReddot = false
          break
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUP_FRAME_REDDOT)
end
function logic_roleInfo_TeamUpFrame:GetDefaultSkinId()
  return defaultSkinId
end
function logic_roleInfo_TeamUpFrame:HaveNew()
  local bReddot = false
  for _, data in ipairs(skinList or {}) do
    if data.bReddot then
      bReddot = true
      break
    end
  end
  return bReddot
end
function logic_roleInfo_TeamUpFrame:IsUsing(data)
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
function logic_roleInfo_TeamUpFrame:IsReddot(data)
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
function logic_roleInfo_TeamUpFrame:IsLocked(data)
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
function logic_roleInfo_TeamUpFrame:send_get_team_notify_skin_list()
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_get_team_notify_skin_list()
end
function logic_roleInfo_TeamUpFrame:on_get_team_notify_skin_list_rsp(err_code, skin_list, cur_skin_id)
  log(bWriteLog and "RoleInfoHandler.on_get_team_notify_skin_list_rsp err_code = " .. tostring(err_code))
  log_tree(bWriteLog and "RoleInfoHandler.on_get_team_notify_skin_list_rsp skin_list", skin_list)
  log(bWriteLog and "RoleInfoHandler.on_get_team_notify_skin_list_rsp cur_skin_id = " .. tostring(cur_skin_id))
  if err_code ~= 0 then
    return
  end
  DataMgr.roleData.cur_team_notify_skin_id = cur_skin_id
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamUpFrameSkinRedPoint) or {}
  local skinConfig = CDataTable.GetTable("TeamUpPopFrame")
  skinList = {}
  for id, data in pairs(skinConfig) do
    local cfg = {
      ID = data.ID,
      Name = data.Name,
      DefaultDisplay = data.DefaultDisplay,
      Sort = data.Sort,
      Icon = data.Icon,
      Skin = data.Skin,
      DynamicIconPath = data.DynamicIconPath,
      DescTime = data.DescTime,
      DescGet = data.DescGet,
      JumpUrl = data.JumpUrl,
      BeginShowTime = data.BeginShowTime,
      levelType = data.LevelType,
      level = data.Level
    }
    id = tonumber(id)
    local info = {
      cfg = cfg,
      bIsLock = skin_list[id] == nil,
      bIsUse = id == cur_skin_id,
      bIsSelected = id == cur_skin_id,
      bReddot = redPointData[DataMgr.roleData.uid] and redPointData[DataMgr.roleData.uid][id] and skin_list[id] ~= nil,
      expireTime = skin_list[id] ~= nil and skin_list[id].expire_time
    }
    if info.cfg.DefaultDisplay == 0 and info.bIsLock then
    else
      if info.cfg.ID == defaultSkinId then
        info.bIsLock = false
        info.bReddot = false
      end
      table.insert(skinList, info)
    end
  end
  local table_util = require("common.table_util")
  local i = 1
  while i <= #skinList do
    if skinList[i].cfg.levelType and skinList[i].cfg.levelType ~= 0 then
      local itemList = {}
      local levelType = skinList[i].cfg.levelType
      local j = i
      while j <= #skinList do
        if skinList[j].cfg.levelType == levelType then
          table.insert(itemList, table_util.CopyTable(skinList[j]))
          table.remove(skinList, j)
        else
          j = j + 1
        end
      end
      table.sort(itemList, function(l, r)
        return l.cfg.level < r.cfg.level
      end)
      local item = table_util.CopyTable(itemList[1])
      item.SubList = itemList
      table.insert(skinList, i, item)
    end
    i = i + 1
  end
  table.sort(skinList, function(a, b)
    local aIsUse = self:IsUsing(a)
    local bIsUse = self:IsUsing(b)
    local aReddot = self:IsReddot(a)
    local bReddot = self:IsReddot(b)
    local aIsLock = self:IsLocked(a)
    local bIsLock = self:IsLocked(b)
    if aIsUse == bIsUse then
      if aIsLock == bIsLock then
        if aReddot == bReddot then
          return a.cfg.Sort < b.cfg.Sort
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
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUPFRAME)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUP_FRAME_REDDOT)
end
function logic_roleInfo_TeamUpFrame:on_new_team_notify_skin_notify(skin_list, new_item_id)
  log(bWriteLog and "RoleInfoHandler.on_new_team_notify_skin_notify new_item_id = " .. tostring(new_item_id))
  log_tree(bWriteLog and "RoleInfoHandler.on_new_team_notify_skin_notify skin_list", skin_list)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamUpFrameSkinRedPoint) or {}
  local selfData = redPointData[DataMgr.roleData.uid] or {}
  skinList = skinList or {}
  for _, data in ipairs(skinList) do
    if data.cfg.ID == new_item_id then
      data.bReddot = selfData[new_item_id] ~= false
      data.bIsLock = false
      break
    end
  end
  if selfData[new_item_id] == false then
    selfData[new_item_id] = false
  else
    selfData[new_item_id] = true
  end
  redPointData[DataMgr.roleData.uid] = selfData
  PlayerPrefsSystem.SaveTableToFile_N(redPointData, PlayerPrefsSystem.ePlayerPrefsType.eTeamUpFrameSkinRedPoint)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUP_FRAME_REDDOT)
end
function logic_roleInfo_TeamUpFrame:send_change_team_notify_skin(itemId)
  log(bWriteLog and "logic_roleInfo_TeamUpFrame:send_change_team_notify_skin itemId = " .. tostring(itemId))
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_change_team_notify_skin(itemId)
end
function logic_roleInfo_TeamUpFrame:on_change_team_notify_skin_rsp(err_code, cur_skin_id)
  log(bWriteLog and "logic_roleInfo_TeamUpFrame:on_change_team_notify_skin_rsp err_code = " .. tostring(err_code))
  log(bWriteLog and "logic_roleInfo_TeamUpFrame:on_change_team_notify_skin_rsp cur_skin_id = " .. tostring(cur_skin_id))
  if err_code ~= 0 then
    return
  end
  for _, data in ipairs(skinList) do
    if data.SubList then
      for _, v in pairs(data.SubList) do
        v.bIsUse = v.cfg.ID == cur_skin_id
      end
    else
      if data.cfg.ID == DataMgr.roleData.cur_team_notify_skin_id then
        data.bIsUse = false
      end
      if data.cfg.ID == cur_skin_id then
        data.bIsUse = true
      end
    end
  end
  DataMgr.roleData.cur_team_notify_skin_id = cur_skin_id
  table.sort(skinList, function(a, b)
    local aIsUse = self:IsUsing(a)
    local bIsUse = self:IsUsing(b)
    local aReddot = self:IsReddot(a)
    local bReddot = self:IsReddot(b)
    local aIsLock = self:IsLocked(a)
    local bIsLock = self:IsLocked(b)
    if aIsUse == bIsUse then
      if aIsLock == bIsLock then
        if aReddot == bReddot then
          return a.cfg.Sort < b.cfg.Sort
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
  log_tree(bWriteLog and "logic_roleInfo_TeamUpFrame:on_change_team_notify_skin_rsp skinList", skinList)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHANGE_TEAMUPFRAME)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicTeamUpFrameModule = class(CModuleBase, nil, logic_roleInfo_TeamUpFrame)
return CLogicTeamUpFrameModule