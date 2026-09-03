local GameGuideUIUtil = {}
function GameGuideUIUtil.GetGuideCheckData()
  local GameGuideConfig = GameGuideUIUtil.GetGameGuideConfig()
  if not GameGuideConfig then
    print(bWriteLog and "GameGuideUIMain_Debug_Msg: GameGuideUIUtil.GetGuideCheckData GameGuideConfig is nil")
    return
  end
  local ResultData = {}
  local insert = table.insert
  for _, Tabs in pairs(GameGuideConfig) do
    local TabsConfig = Tabs.TabsConfig or {}
    for _, Tab in pairs(TabsConfig) do
      if Tab.GuideCheckItemID then
        insert(ResultData, Tab.GuideCheckItemID)
      end
    end
  end
  return ResultData
end
function GameGuideUIUtil.GetGameGuideConfig()
  local GameGuideUIConfigSubsystem = SubsystemMgr:Get("GameGuideUIConfigSubsystem")
  if GameGuideUIConfigSubsystem then
    return GameGuideUIConfigSubsystem:GetGameGuideConfig()
  end
  return nil
end
function GameGuideUIUtil.GetNewTextID()
  return 64753
end
function GameGuideUIUtil.OpenGuideTargetTab(TargetTabName)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) then
    MainControlBaseUI:ShowEntireMapWindow()
    local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
    local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
    if EntireMapUI then
      if TargetTabName then
        EntireMapUI.TargetNameID = TargetTabName
        EntireMapUI.BeginGuide = true
      end
      EntireMapUI:SelectGameGuide(true)
      local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
      if GameGuideUIMain and TargetTabName then
        GameGuideUIMain:OnSetGuideTarget(nil, nil, TargetTabName)
      end
    end
  end
end
return GameGuideUIUtil