local logic_moment_background = {
  defaultBgId = 4700000,
  background_cfg = nil,
  moment_background = nil,
  last_moment_background_id = nil,
  bGetNewBgFlag = false,
  localRedDotFileTb = nil
}
function logic_moment_background.proc_get_moment_background_data_rsp(background_cfg, moment_background, last_moment_background_id)
  logic_moment_background.  logic_moment_background.  logic_moment_background.  local new_background_cfg = {}
  for k, v in pairs(background_cfg) do
    local cfg = CDataTable.GetTableData("FriendMomentBgCfg", k)
    if cfg then
      new_background_cfg[k] = v
    end
  end
  logic_moment_background.background_cfg = new_background_cfg
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_GetInfo)
end
function logic_moment_background.GetSortedCfgList()
  if logic_moment_background.background_cfg == nil then
    log(bWriteLog and "logic_moment_background.GetSortedCfgList no data")
    return nil
  end
  local cfgList = {}
  for k, v in pairs(logic_moment_background.background_cfg) do
    local info = {}
    info.ID = k
    info.svrData = v
    info.cfg = CDataTable.GetTableData("FriendMomentBgCfg", k)
    table.insert(cfgList, info)
  end
  for k, v in pairs(cfgList) do
    v.bInUse = logic_moment_background.IsInUse(v.ID)
    v.ItemCfg = CDataTable.GetTableData("Item", v.ID)
    v.ItemInfo = logic_moment_background.GetItemInfo(v.ID)
  end
  table.sort(cfgList, logic_moment_background.SortCfg)
  table.insert(cfgList, 1, logic_moment_background.GetDefaultInfo())
  return cfgList
end
function logic_moment_background.SortCfg(a, b)
  if a.bInUse then
    return true
  end
  if b.bInUse then
    return false
  end
  if a.ItemInfo and not b.ItemInfo then
    return true
  end
  if not a.ItemInfo and b.ItemInfo then
    return false
  end
  if a.ItemInfo then
    if a.ItemCfg.ItemQuality > b.ItemCfg.ItemQuality then
      return true
    elseif a.ItemCfg.ItemQuality < b.ItemCfg.ItemQuality then
      return false
    end
    if a.ItemInfo.expire_ts < b.ItemInfo.expire_ts then
      return true
    elseif a.ItemInfo.expire_ts > b.ItemInfo.expire_ts then
      return false
    end
    return a.ID < b.ID
  else
    if a.svrData.can_obtain and not b.svrData.can_obtain then
      return true
    end
    if not a.svrData.can_obtain and b.svrData.can_obtain then
      return false
    end
    if a.ItemCfg.ItemQuality > b.ItemCfg.ItemQuality then
      return true
    elseif a.ItemCfg.ItemQuality < b.ItemCfg.ItemQuality then
      return false
    end
    return a.ID < b.ID
  end
end
function logic_moment_background.GetDefaultInfo()
  local info = {
    ID = logic_moment_background.defaultBgId,
    svrData = nil,
    cfg = CDataTable.GetTableData("FriendMomentBgCfg", logic_moment_background.defaultBgId),
    bInUse = logic_moment_background.last_moment_background_id == nil,
    ItemCfg = CDataTable.GetTableData("Item", logic_moment_background.defaultBgId),
    ItemInfo = nil
  }
  return info
end
function logic_moment_background.GetItemInfo(ID)
  if logic_moment_background.moment_background == nil or ID == nil then
    return nil
  end
  return logic_moment_background.moment_background[ID]
end
function logic_moment_background.IsInUse(ID)
  if ID == logic_moment_background.defaultBgId then
    if logic_moment_background.last_moment_background_id == nil then
      return true
    else
      return false
    end
  elseif logic_moment_background.last_moment_background_id == ID then
    return true
  else
    return false
  end
end
function logic_moment_background.proc_set_moment_background_flag_rsp(background_id)
  if logic_moment_background.moment_background == nil then
    return
  end
  for k, v in pairs(logic_moment_background.moment_background) do
    if k == background_id then
      v.is_new = false
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_IsNew_Change)
end
function logic_moment_background.proc_notify_new_moment_background_red_point()
  logic_moment_background.bGetNewBgFlag = true
  logic_moment_background.localRedDotFileTb = {}
  logic_moment_background.SaveLocalRedDotFileTb()
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_GETNEWBG)
end
function logic_moment_background.HasNew()
  if logic_moment_background.bGetNewBgFlag then
    return true
  end
  if logic_moment_background.moment_background == nil then
    return false
  end
  for k, v in pairs(logic_moment_background.moment_background) do
    if v.is_new then
      return true
    end
  end
  return false
end
function logic_moment_background.IsNew(ID)
  if logic_moment_background.moment_background == nil or logic_moment_background.moment_background[ID] == nil then
    return false
  end
  return logic_moment_background.moment_background[ID].is_new
end
function logic_moment_background.SetIsNew(ID, bNew)
  if logic_moment_background.moment_background == nil or logic_moment_background.moment_background[ID] == nil then
    return
  end
  logic_moment_background.moment_background[ID].is_new = bNew
end
function logic_moment_background.ClearNewGetBgFlag()
  logic_moment_background.bGetNewBgFlag = false
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_GETNEWBG)
end
function logic_moment_background.GetLocalRedDotFileTb()
  if logic_moment_background.localRedDotFileTb ~= nil then
    return logic_moment_background.localRedDotFileTb
  end
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  logic_moment_background.localRedDotFileTb = playerprefs.LoadFileToTable_N(PlayerPrefsConfig.MomentBackGroundRedDot)
  if logic_moment_background.localRedDotFileTb == nil then
    logic_moment_background.localRedDotFileTb = {}
  end
  return logic_moment_background.localRedDotFileTb
end
function logic_moment_background.SaveLocalRedDotFileTb()
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  playerprefs.SaveTableToFile_N(logic_moment_background.localRedDotFileTb, PlayerPrefsConfig.MomentBackGroundRedDot)
end
return logic_moment_background