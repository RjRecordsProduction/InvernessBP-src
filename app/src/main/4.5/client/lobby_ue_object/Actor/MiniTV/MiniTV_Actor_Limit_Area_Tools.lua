local MiniTV_Actor_Limit_Area_Tools = {Area_Offset_X = 50, Area_Offset_Y = 50}
local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
local ui_util = require("client.common.ui_util")
function MiniTV_Actor_Limit_Area_Tools.GetWidget_1()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    return nil
  end
  local Lobby_Mid_Friend_UIBP = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.Lobby_Mid_Friend_UIBP)
  if not Lobby_Mid_Friend_UIBP then
    return nil
  end
  if not Lobby_Mid_Friend_UIBP.UIRoot.CanvasPanel_Root then
    return nil
  end
  return Lobby_Mid_Friend_UIBP.UIRoot.CanvasPanel_Root, Lobby_Mid_Friend_UIBP.UIRoot.CanvasPanel_Glow
end
function MiniTV_Actor_Limit_Area_Tools.GetWidget_2()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    return nil
  end
  local match_new_entry = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.match_new_entry)
  if not match_new_entry then
    return nil
  end
  if not match_new_entry.UIRoot.CanvasPanel_3 then
    return nil
  end
  return match_new_entry.UIRoot.CanvasPanel_3, match_new_entry.UIRoot.CanvasPanel_Glow
end
function MiniTV_Actor_Limit_Area_Tools.GetWidget_3()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    return nil, nil
  end
  local Lobby_Mid_Banner_UIBP = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.Lobby_Mid_Banner_UIBP)
  if not Lobby_Mid_Banner_UIBP then
    return nil, nil
  end
  if not Lobby_Mid_Banner_UIBP.UIRoot.CanvasPanel_13 then
    return nil, nil
  end
  return Lobby_Mid_Banner_UIBP.UIRoot.CanvasPanel_13, Lobby_Mid_Banner_UIBP.UIRoot.CanvasPanel_Glow
end
function MiniTV_Actor_Limit_Area_Tools.GetWidget_4()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    return nil, nil
  end
  local Lobby_Main_Switch_UIBP = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
  if not Lobby_Main_Switch_UIBP then
    return nil, nil
  end
  if not Lobby_Main_Switch_UIBP.UIRoot.CanvasPanel_Limit then
    return nil, nil
  end
  return Lobby_Main_Switch_UIBP.UIRoot.CanvasPanel_Limit, nil
end
function MiniTV_Actor_Limit_Area_Tools.GetLimitAreaInfo()
  local limitInfo = {
    limitWidgetList = {},
    glowWidgetList = {}
  }
  local limitWidget, glowWidget
  local index = 1
  limitWidget, glowWidget = MiniTV_Actor_Limit_Area_Tools.GetWidget_1()
  if limitWidget then
    limitInfo.limitWidgetList[index] = limitWidget
    limitInfo.glowWidgetList[index] = glowWidget
    index = index + 1
  end
  limitWidget, glowWidget = MiniTV_Actor_Limit_Area_Tools.GetWidget_2()
  if limitWidget then
    limitInfo.limitWidgetList[index] = limitWidget
    limitInfo.glowWidgetList[index] = glowWidget
    index = index + 1
  end
  limitWidget, glowWidget = MiniTV_Actor_Limit_Area_Tools.GetWidget_3()
  if limitWidget then
    limitInfo.limitWidgetList[index] = limitWidget
    limitInfo.glowWidgetList[index] = glowWidget
    index = index + 1
  end
  limitWidget, glowWidget = MiniTV_Actor_Limit_Area_Tools.GetWidget_4()
  if limitWidget then
    limitInfo.limitWidgetList[index] = limitWidget
    limitInfo.glowWidgetList[index] = glowWidget
    index = index + 1
  end
  return limitInfo
end
function MiniTV_Actor_Limit_Area_Tools.UpdateGlowWidget(glowWidgetList, curIndex)
  if glowWidgetList == nil then
    local limitInfo = MiniTV_Actor_Limit_Area_Tools.GetLimitAreaInfo()
    glowWidgetList = limitInfo.glowWidgetList
  end
  for index, widget in pairs(glowWidgetList) do
    if index == curIndex then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function MiniTV_Actor_Limit_Area_Tools.CheckLimitAreaIndex(x, y)
  local limitInfo = MiniTV_Actor_Limit_Area_Tools.GetLimitAreaInfo()
  local curIndex = 0
  for index, widget in pairs(limitInfo.limitWidgetList) do
    local tlViewportPos, tlViewportLayoutPos = ui_util.GetWidgetViewportPosInNormalized(widget, 0, 0)
    local brViewportPos, brViewportLayoutPos = ui_util.GetWidgetViewportPosInNormalized(widget, 1, 1)
    if x >= tlViewportPos.X - MiniTV_Actor_Limit_Area_Tools.Area_Offset_X and x <= brViewportPos.X + MiniTV_Actor_Limit_Area_Tools.Area_Offset_X and y >= tlViewportPos.Y - MiniTV_Actor_Limit_Area_Tools.Area_Offset_Y and y <= brViewportPos.Y + MiniTV_Actor_Limit_Area_Tools.Area_Offset_Y then
      log(bWriteLog and "MiniTV_Actor_Limit_Area_Tools.CheckLimitAreaIndex limit index = " .. index)
      curIndex = index
      break
    end
  end
  MiniTV_Actor_Limit_Area_Tools.UpdateGlowWidget(limitInfo.glowWidgetList, curIndex)
  return curIndex
end
return MiniTV_Actor_Limit_Area_Tools