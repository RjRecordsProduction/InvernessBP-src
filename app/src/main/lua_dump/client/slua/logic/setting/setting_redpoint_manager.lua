local LobbySettingCatalog = require("client.logic.NewSetting.SettingCatalog")
local setting_redpoint_manager = {}
local SimpleReddotData = {
  NetOptimizationOpen = {
    "LanguageAndNet",
    "Net"
  },
  bQuickSignDoubleRing = {
    "Game",
    "Game_Advanced"
  },
  GromeLinkOpen = {
    "LanguageAndNet",
    "Net"
  }
}
local SimpleReddotData_Runtime
function setting_redpoint_manager.RequestServerData()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_setting_label_req()
end
function setting_redpoint_manager.OnGetRedPointCfg(data)
  local TableUtil = require("common.table_util")
  if not SimpleReddotData_Runtime then
    SimpleReddotData_Runtime = TableUtil.FastCopyTable(SimpleReddotData)
  end
  if data and type(data[1]) == "table" then
    for key, status in pairs(data[1]) do
      if status then
        SimpleReddotData_Runtime[key] = nil
      end
    end
  end
  for Key, _ in pairs(SimpleReddotData_Runtime) do
    if not setting_redpoint_manager.CheckVisibility(Key) then
      SimpleReddotData_Runtime[Key] = nil
    end
  end
  LobbySystem.UpdateSettingRedPoint()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_RED_POINT)
end
function setting_redpoint_manager.CusumeReddot(OptionKey)
  print(bWriteLog and "setting_redpoint_manager.CusumeReddot " .. OptionKey)
  local settingHandle = require("client.network.Protocol.SettingHandler")
  settingHandle.send_update_setting_label_req(1, OptionKey)
  local Path = SimpleReddotData_Runtime[OptionKey]
  SimpleReddotData_Runtime[OptionKey] = nil
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_RED_POINT)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_CONSUME_RED_POINT, OptionKey, Path)
end
function setting_redpoint_manager.HasReddot()
  if GameStatus.IsInFightingStatus() and (Client.IsWindowOB() or DataMgr.anchor == 1) then
    print(bWriteLog and "setting_redpoint_manager no RED_DOT in ob or in fight")
    return false
  end
  return SimpleReddotData_Runtime and next(SimpleReddotData_Runtime) ~= nil
end
function setting_redpoint_manager.GetReddotPathTable()
  local Result = {}
  if not SimpleReddotData_Runtime or not next(SimpleReddotData_Runtime) then
    return Result
  end
  for OptionKey, Path in pairs(SimpleReddotData_Runtime) do
    if Path and Path[1] then
      local pageKey = Path[1]
      if not Result[pageKey] then
        Result[pageKey] = {}
      end
      if Path[2] then
        local catKey = Path[2]
        if not Result[pageKey][catKey] then
          Result[pageKey][catKey] = {}
        end
        Result[pageKey][catKey][OptionKey] = true
      else
        Result[pageKey][OptionKey] = true
      end
    end
  end
  return Result
end
function setting_redpoint_manager.CheckVisibility(OptionKey)
  local Path = SimpleReddotData_Runtime[OptionKey]
  if not Path or not Path[1] then
    return false
  end
  local TargetPage
  for _, Page in ipairs(LobbySettingCatalog) do
    if Page.Key == Path[1] then
      Target      break
    end
  end
  if not TargetPage or TargetPage.VisibilityFunc and not TargetPage.VisibilityFunc() then
    return false
  end
  local TargetStack
  if Path[2] then
    if not TargetPage.Category then
      return false
    end
    for _, Category in ipairs(TargetPage.Category) do
      if Category.Key == Path[2] then
        if Category.VisibilityFunc and not Category.VisibilityFunc() then
          return false
        end
        TargetStack = Category.Stack
        break
      end
    end
  else
    TargetStack = TargetPage.Stack
  end
  if not TargetStack then
    return false
  end
  for _, Option in ipairs(TargetStack) do
    if Option.Key == OptionKey then
      return not Option.VisibilityFunc or Option.VisibilityFunc()
    end
  end
  return true
end
return setting_redpoint_manager