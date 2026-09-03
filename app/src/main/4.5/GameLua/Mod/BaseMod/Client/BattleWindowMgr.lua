BatttleWindowMgr = {}
function BatttleWindowMgr.PreLoadUI(FWindowName)
  log(bWriteLog and "pre load ui" .. FWindowName)
  if UIManager and UIManager.UI_Config_InGame[FWindowName] then
    local window = UIManager.GetUI(UIManager.UI_Config_InGame[FWindowName])
    if window == nil then
      UIManager.ShowUI(UIManager.UI_Config_InGame[FWindowName])
      UIManager.HideUI(UIManager.UI_Config_InGame[FWindowName])
    else
      log(bWriteLog and FWindowName .. "is not nil")
    end
  end
end
function BatttleWindowMgr.ShowUIWhenInBattle()
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  if logic_mode_mgr.IsInPlanZMode() then
    print(bWriteLog and "BatttleWindowMgr.ShowUIWhenInBattle in bp")
    return
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local WithoutMapWindow = ClientGameMain.GetUIOtherSetting("WithoutMapWindow")
  if WithoutMapWindow then
    return
  end
  BatttleWindowMgr.PreLoadUI("EntireMapWindow")
  BatttleWindowMgr.ShowUI("MiniMapWindow")
end
function BatttleWindowMgr.CheckOnlyCollapsed(WindowName)
  if UIManager and UIManager.UI_Config_InGame[WindowName] then
    local Config = UIManager.GetConfigByKey(WindowName)
    if Config and Config.bPermanentDuringThisBattle and Config.zOrder and Config.zOrder > 0 then
      return true
    end
  end
  return false
end
function BatttleWindowMgr.ShowUI(FWindowName, Param)
  if UIManager and UIManager.UI_Config_InGame[FWindowName] then
    if BatttleWindowMgr.CheckOnlyCollapsed(FWindowName) then
      local UIBase = UIManager.GetUI(UIManager.UI_Config_InGame[FWindowName])
      if UIBase then
        UIBase:SelfHitTestInvisible()
      else
        UIManager.ShowUI(UIManager.UI_Config_InGame[FWindowName], Param)
      end
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame[FWindowName], Param)
    end
  end
  log(bWriteLog and "BatttleWindowMgr ShowUI:" .. FWindowName)
end
function BatttleWindowMgr.HideUI(FWindowName)
  if UIManager then
    if BatttleWindowMgr.CheckOnlyCollapsed(FWindowName) then
      local UIBase = UIManager.GetUI(UIManager.UI_Config_InGame[FWindowName])
      if UIBase then
        UIBase:Collapsed()
      end
    else
      UIManager.HideUI(UIManager.UI_Config_InGame[FWindowName])
    end
  end
  log(bWriteLog and "BatttleWindowMgr HideUI:" .. FWindowName)
end
function BatttleWindowMgr.CheckWindowOpen(FWindowName)
  if UIManager then
    local bCurrentWindowOpen = UIManager.IsUIShow(UIManager.UI_Config_InGame[FWindowName])
    return bCurrentWindowOpen
  end
  return false
end
function BatttleWindowMgr.OpenOrHideEntireMap()
  if BatttleWindowMgr.CheckWindowOpen("EntireMapWindow") then
    BatttleWindowMgr.HideUI("EntireMapWindow")
  else
    BatttleWindowMgr.ShowUI("EntireMapWindow")
  end
end
function BatttleWindowMgr.CheckCloseMiniMap()
  if BatttleWindowMgr.CheckWindowOpen("EntireMapWindow") then
    BatttleWindowMgr.HideUI("EntireMapWindow")
    return true
  end
  return false
end