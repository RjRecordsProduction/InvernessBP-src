local setting_redpoint_manager = {}
local SimpleReddotData_Runtime, CachedCatalog
local BuildReddotData = function(Catalog)
  local version_util = require("client.common.version_util")
  local logic_setting_reddot_data = require("client.slua.umg.setting.logic_setting_reddot_data")
  local result = {}
  if not Catalog then
    return result
  end
  for _, Page in ipairs(Catalog) do
    if Page.Category then
      for _, Cat in ipairs(Page.Category) do
        if Cat.Stack then
          for _, Item in ipairs(Cat.Stack) do
            if Item.OnVersion and version_util.IsMatchVersion(Item.OnVersion) then
              result[Item.Key] = {
                Page = Page.Key,
                Category = Cat.Key,
                Text = Item.Text
              }
              logic_setting_reddot_data.AddReddot(Item.Key)
            end
          end
        end
      end
    elseif Page.Stack then
      for _, Item in ipairs(Page.Stack) do
        if Item.OnVersion and version_util.IsMatchVersion(Item.OnVersion) then
          result[Item.Key] = {
            Page = Page.Key,
            Text = Item.Text
          }
          logic_setting_reddot_data.AddReddot(Item.Key)
        end
      end
    end
  end
  return result
end
function setting_redpoint_manager.Init(Catalog)
  Cached  SimpleReddotData_Runtime = nil
end
function setting_redpoint_manager.RequestServerData()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_setting_label_req()
end
function setting_redpoint_manager.OnGetRedPointCfg(data)
  if not SimpleReddotData_Runtime then
    SimpleReddotData_Runtime = BuildReddotData(CachedCatalog)
  end
  local logic_setting_reddot_data = require("client.slua.umg.setting.logic_setting_reddot_data")
  if data and type(data[1]) == "table" then
    for key, status in pairs(data[1]) do
      if status then
        SimpleReddotData_Runtime[key] = nil
        logic_setting_reddot_data.RemoveReddot(key)
      end
    end
  end
  for Key, _ in pairs(SimpleReddotData_Runtime) do
    if not setting_redpoint_manager.CheckVisibility(Key) then
      SimpleReddotData_Runtime[Key] = nil
      logic_setting_reddot_data.RemoveReddot(Key)
    end
  end
  LobbySystem.UpdateSettingRedPoint()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_RED_POINT)
end
function setting_redpoint_manager.CusumeReddot(OptionKey)
  if not SimpleReddotData_Runtime[OptionKey] then
    return
  end
  print(bWriteLog and "setting_redpoint_manager.CusumeReddot " .. OptionKey)
  local logic_setting_reddot_data = require("client.slua.umg.setting.logic_setting_reddot_data")
  logic_setting_reddot_data.RemoveReddot(OptionKey)
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
function setting_redpoint_manager.GetReddotRawData()
  return SimpleReddotData_Runtime
end
function setting_redpoint_manager.GetSortedReddotList()
  if not (SimpleReddotData_Runtime and next(SimpleReddotData_Runtime)) or not CachedCatalog then
    return nil
  end
  local list = {}
  for _, Page in ipairs(CachedCatalog) do
    if Page.Category then
      for _, Cat in ipairs(Page.Category) do
        if Cat.Stack then
          for _, Item in ipairs(Cat.Stack) do
            if SimpleReddotData_Runtime[Item.Key] then
              local path = SimpleReddotData_Runtime[Item.Key]
              list[#list + 1] = {
                OptionKey = Item.Key,
                PageKey = path.Page,
                CategoryKey = path.Category,
                Text = path.Text
              }
            end
          end
        end
      end
    elseif Page.Stack then
      for _, Item in ipairs(Page.Stack) do
        if SimpleReddotData_Runtime[Item.Key] then
          local path = SimpleReddotData_Runtime[Item.Key]
          list[#list + 1] = {
            OptionKey = Item.Key,
            PageKey = path.Page,
            Text = path.Text
          }
        end
      end
    end
  end
  if #list == 0 then
    return nil
  end
  return list
end
function setting_redpoint_manager.GetReddotPathTable()
  local Result = {}
  if not SimpleReddotData_Runtime or not next(SimpleReddotData_Runtime) then
    return Result
  end
  for OptionKey, Path in pairs(SimpleReddotData_Runtime) do
    if Path and Path.Page then
      local pageKey = Path.Page
      if not Result[pageKey] then
        Result[pageKey] = {}
      end
      if Path.Category then
        local catKey = Path.Category
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
  if not Path or not Path.Page then
    return false
  end
  local TargetPage
  for _, Page in ipairs(CachedCatalog) do
    if Page.Key == Path.Page then
      Target      break
    end
  end
  if not TargetPage or TargetPage.VisibilityFunc and not TargetPage.VisibilityFunc() then
    return false
  end
  local TargetStack
  if Path.Category then
    if not TargetPage.Category then
      return false
    end
    for _, Category in ipairs(TargetPage.Category) do
      if Category.Key == Path.Category then
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