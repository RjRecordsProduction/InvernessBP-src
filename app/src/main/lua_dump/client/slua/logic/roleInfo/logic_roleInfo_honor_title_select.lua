local logic_roleInfo_honor_title_select = {}
local Enum_Alias_State_Type = {
  notHave = 0,
  have = 1,
  use = 2
}
function logic_roleInfo_honor_title_select:DefineAndResetData()
  self.SaveSelectAliasList = {}
end
function logic_roleInfo_honor_title_select:get_show_alias_req()
  log(bWriteLog and "[wzp] logic_roleInfo_honor_title_select:get_show_alias_req")
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_get_show_alias_req()
end
function logic_roleInfo_honor_title_select:on_get_show_alias_rsp(list)
  log_tree(bWriteLog and "logic_roleInfo_honor_title_select:on_get_show_alias_rsp:", list)
  self.SaveSelectAliasList = {}
  if list ~= nil then
    for k, v in pairs(list) do
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      if v.expire_ts == 0 or serverTime < v.expire_ts then
        self.SaveSelectAliasList[k] = v
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_GET_SELECT_ALIAS_LIST)
end
function logic_roleInfo_honor_title_select:send_set_show_alias_req(table)
  log(bWriteLog and "[wzp] logic_roleInfo_honor_title_select:send_set_show_alias_req")
  local saveTable = {}
  for key, value in pairs(table) do
    saveTable[value.order_id] = key
  end
  log_tree("logic_roleInfo_honor_title_select:send_set_show_alias_req  saveTable", saveTable)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_set_show_alias_req(saveTable)
end
function logic_roleInfo_honor_title_select:on_set_show_alias_rsp()
  self:get_show_alias_req()
end
function logic_roleInfo_honor_title_select:FilterHavedAliasList()
  local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  local alias_list_info = logic_roleinfo_title.alias_list_info
  local haveAliasList = {}
  for k, v in pairs(alias_list_info) do
    local cfg = CDataTable.GetTableData("AliasCfg", k)
    if cfg ~= nil and v.state ~= Enum_Alias_State_Type.notHave then
      local item = {
        aliasTitle = FuncUtil.Gen_title(k, v.rank, v.ext_info, v.rank_id),
        aliasId = k,
        aliasType = cfg.AliasType,
        aliasNation = v.nation,
        aliasQuality = cfg.AliasQuality,
        aliasDesc = cfg.AliasDesc,
        aliasIconUrl = cfg.AliasIconPath,
        aliasIconUrlBig = cfg.AliasIconPathBig,
        expire_ts = v.expire_ts,
        rank = v.rank,
        rank_id = v.rank_id,
        ext_info = v.ext_info
      }
      table.insert(haveAliasList, item)
    end
  end
  self:SortHavedAliasList(haveAliasList)
  return haveAliasList
end
function logic_roleInfo_honor_title_select:SortHavedAliasList(haveAliasList)
  local SortHaveAliasListFunction = function(a, b)
    local aIsInList, aIndex = self:FindAliasInSvaeAliasIDList(a.aliasId)
    local bIsInList, bIndex = self:FindAliasInSvaeAliasIDList(b.aliasId)
    if aIsInList == bIsInList then
      if aIsInList then
        return aIndex < bIndex
      else
        if a.aliasQuality == b.aliasQuality then
          return a.aliasId > b.aliasId
        end
        return a.aliasQuality > b.aliasQuality
      end
    else
      return aIsInList
    end
  end
  table.sort(haveAliasList, SortHaveAliasListFunction)
end
function logic_roleInfo_honor_title_select:FindAliasInSvaeAliasIDList(AliasID)
  for k, v in pairs(self.SaveSelectAliasList) do
    if AliasID == k then
      return true, v.order_id
    end
  end
  return false, -1
end
function logic_roleInfo_honor_title_select:GetHavedAliasList()
  return self:FilterHavedAliasList()
end
function logic_roleInfo_honor_title_select:GetSaveSelectAliasList()
  return self.SaveSelectAliasList
end
function logic_roleInfo_honor_title_select:GetSaveSelectListCount()
  local count = 0
  if self.SaveSelectAliasList then
    for key, value in pairs(self.SaveSelectAliasList) do
      count = count + 1
    end
  end
  return count
end
function logic_roleInfo_honor_title_select:ClearSelectAliasDataByIndex(index)
  for key, value in pairs(self.SaveSelectAliasList) do
    if index == value.order_id then
      self.SaveSelectAliasList[key] = nil
      return true
    end
  end
  return false
end
function logic_roleInfo_honor_title_select:SaveShowAliasData()
  self:send_set_show_alias_req(self.SaveSelectAliasList)
end
function logic_roleInfo_honor_title_select:ShareShowAliasList()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  Client.DeleteDirectory(Client.ProjectSavedDir() .. "Screenshots/")
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_CLICK_SHARE_ALIAS_LIST_UPDATE_BUTTON, false)
  local ScreenshotMaker = import("ScreenshotMaker")
  local sSharePath = ScreenshotMaker.MakePicture(true)
  local timer_ticker = require("common.time_ticker")
  local timer
  timer = timer_ticker.AddTimerLoop(0, function()
    if ScreenshotMaker.HasCaptured(sSharePath) then
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_CLICK_SHARE_ALIAS_LIST_UPDATE_BUTTON, true)
      local TimeUtil = require("client.common.time_util")
      local cfg = {
        capturePath = sSharePath,
        sceneType = ShareSceneType.ShowAliasListShare,
        otherTLog = TLogEventDefine.PersonSpaceHonor_Alias_Photo_Share,
        campaign = "Honor_Alias",
        share_type = ShareBtnTLogShareTypeDefine.PersonalHonorAlias,
        showFace = false,
        reasonStr = json.encode({
          uid = DataMgr.roleData.uid,
          time = TimeUtil.GetServerTimeInSec()
        }),
        isOld = true
      }
      local Util = require("client.slua_ui_framework.util")
      Util.ShowShare(cfg)
      timer_ticker.RemoveTimer(timer)
    else
      log(bWriteLog and "[wzp]: not yet")
    end
  end, TIMER_INFINITE, 0.1)
end
function logic_roleInfo_honor_title_select:ChangeSelectAliasInList(AliasData, isAdd, index)
  if isAdd then
    if index == -1 then
      local count = 0
      for i = 1, 10 do
        for key, value in pairs(self.SaveSelectAliasList) do
          count = count + 1
          if i == value.order_id then
            count = 0
            break
          end
        end
        if count == self:GetSaveSelectListCount() then
          index = i
          break
        end
      end
    else
      for key, value in pairs(self.SaveSelectAliasList) do
        if index == value.order_id then
          local refIndex = self:GetRefIndex(key)
          self.SaveSelectAliasList[key] = nil
          EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_SELECT_ALIAS_UPDATE_LOOPITEM, refIndex)
          break
        end
      end
    end
    local item = {
      rank = AliasData.rank,
      rank_id = AliasData.rank_id,
      ext_info = AliasData.ext_info,
      nation = AliasData.aliasNation,
      order_id = index,
      expire_ts = AliasData.expire_ts
    }
    self.SaveSelectAliasList[AliasData.aliasId] = item
  else
    if not self.SaveSelectAliasList or not self.SaveSelectAliasList[AliasData.aliasId] then
      log(bWriteLog and "[wzp] logic_roleInfo_honor_title_select:ChangeSelectAliasInList self.Svae_AliasID_List[index] = nil,delete no success")
      return
    end
    self.SaveSelectAliasList[AliasData.aliasId] = nil
  end
end
function logic_roleInfo_honor_title_select:GetRefIndex(AliasID)
  local have_Alias_List = self:GetHavedAliasList()
  for i = 1, #have_Alias_List do
    if have_Alias_List[i].aliasId == AliasID then
      return i
    end
  end
  return -1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_honor_title_select = class(CModuleBase, nil, logic_roleInfo_honor_title_select)
return Clogic_roleInfo_honor_title_select