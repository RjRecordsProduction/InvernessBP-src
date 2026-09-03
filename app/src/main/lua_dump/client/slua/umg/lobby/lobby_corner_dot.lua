local lobby_corner_dot = {}
local NewDotMapping = {}
local BannerWidgetMapping = {}
local RemoveDot = function(key)
  if NewDotMapping[key] then
    NewDotMapping[key]:RemoveFromParent()
    NewDotMapping[key] = nil
  end
end
local GetBannerParent = function()
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Mid_Binner_More_UIBP)
  if ui and ui.UIRoot then
    return ui.UIRoot.LoopScrollBox_0
  else
    return nil
  end
end
function lobby_corner_dot.ClearData()
  for key, value in pairs(NewDotMapping) do
    RemoveDot(key)
  end
  BannerWidgetMapping = {}
end
function lobby_corner_dot.ResetBannerWidgetMapping()
  BannerWidgetMapping = {}
  local GetBannerIndexByModuleId = function(moduleId)
    local indexArray = {}
    if LobbySystem and LobbySystem.activityBtnDisplayList and next(LobbySystem.activityBtnDisplayList) then
      for index, bannerData in pairs(LobbySystem.activityBtnDisplayList) do
        local StringUtil = require("common.string_util")
        local params = StringUtil.ParseURLParams(bannerData.JumpUrl)
        if moduleId == tonumber(params.module) then
          local activityid = tonumber(params.activityid) or 0
          indexArray[activityid] = index - 1
        end
      end
    end
    return indexArray
  end
  local GetBannerWidgetByIndex = function(index)
    if index then
      local bannerList = GetBannerParent()
      if bannerList and bannerList.GetChildAt then
        return bannerList:GetChildAt(index)
      end
    end
  end
  local spinIdArray = {
    BP_ENUM_MODULE_LUCKY_UNBACK,
    BP_ENUM_MODULE_LUCKY_BACK
  }
  for _, moduleId in pairs(spinIdArray) do
    local indexArray = GetBannerIndexByModuleId(moduleId)
    for activityid, index in pairs(indexArray) do
      local widget = GetBannerWidgetByIndex(index)
      if widget then
        BannerWidgetMapping[moduleId] = BannerWidgetMapping[moduleId] or {}
        BannerWidgetMapping[moduleId][activityid] = widget
      end
    end
  end
end
function lobby_corner_dot.GetBannerWidgetByModuleId(moduleId)
  BannerWidgetMapping[moduleId] = BannerWidgetMapping[moduleId] or {}
  local bannerList = GetBannerParent()
  if bannerList and bannerList.HasChild then
    for activityid, bannerWidget in pairs(BannerWidgetMapping[moduleId]) do
      if not bannerList:HasChild(bannerWidget) then
        BannerWidgetMapping[moduleId][activityid] = nil
      end
    end
  end
  return BannerWidgetMapping[moduleId]
end
function lobby_corner_dot.CreateNewDotByRedPoint(redPoint, newImgPath)
  local redPointSlot = redPoint.Slot
  local redPointParent = redPointSlot.Parent
  local ImageClass = import("Image")
  local newImgWidget = ImageClass()
  local uiUtil = require("client.slua_ui_framework.util")
  uiUtil.SetTexture(newImgWidget, newImgPath, {sync = true})
  local newImgSlot = redPointParent:AddChild(newImgWidget)
  local brush = slua.IndexReference(newImgWidget, "Brush"):clone()
  brush.ImageSize = FVector2D(14, 14)
  newImgWidget:SetBrush(brush)
  if newImgSlot.GetZOrder then
    newImgSlot:SetZOrder(redPointSlot:GetZOrder() + 1)
  end
  if newImgSlot.SetAutoSize then
    newImgSlot:SetAutoSize(true)
  end
  if newImgSlot.SetPosition then
    newImgSlot:SetPosition(redPointSlot:GetPosition())
  end
  if newImgSlot.SetAnchors then
    newImgSlot:SetAnchors(redPointSlot:GetAnchors())
  end
  if newImgSlot.SetAlignment then
    newImgSlot:SetAlignment(redPointSlot:GetAlignment())
  end
  if newImgSlot.SetPadding then
    newImgSlot:SetPadding(redPointSlot.Padding)
  end
  if newImgSlot.SetHorizontalAlignment then
    newImgSlot:SetHorizontalAlignment(redPointSlot.HorizontalAlignment)
  end
  if newImgSlot.SetVerticalAlignment then
    newImgSlot:SetVerticalAlignment(redPointSlot.VerticalAlignment)
  end
  if newImgSlot.SetLayer then
    newImgSlot:SetLayer(redPointSlot.Layer + 1)
  end
  newImgWidget:SetRenderTranslation(redPoint.RenderTransform.Translation)
  newImgWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  return newImgWidget
end
function lobby_corner_dot.SetDotVisible(redPoint, visible, key, imgPath, offset)
  if not redPoint then
    return
  end
  local redPointParent = redPoint.Slot.Parent
  if visible then
    if NewDotMapping[key] and redPointParent:HasChild(NewDotMapping[key]) == false then
      RemoveDot(key)
    end
    if not NewDotMapping[key] then
      local newImg = lobby_corner_dot.CreateNewDotByRedPoint(redPoint, imgPath)
      newImg:SetRenderTranslation(newImg.RenderTransform.Translation + offset)
      NewDotMapping[key] = newImg
    end
  else
    RemoveDot(key)
  end
end
function lobby_corner_dot.RefreshDotInBanner(moduleId, visible, imgPath)
  local bannerWidgetArray = lobby_corner_dot.GetBannerWidgetByModuleId(moduleId)
  for activityid, bannerWidget in pairs(bannerWidgetArray) do
    local redPoint = bannerWidget and bannerWidget.Image_RedPoint
    local posOffset = FVector2D(0, 0)
    local key = tostring(moduleId) .. "_BANNER_GIFT_DOT_" .. tostring(activityid)
    lobby_corner_dot.SetDotVisible(redPoint, visible, key, imgPath, posOffset)
  end
end
function lobby_corner_dot.RefreshDotInTopEntrance(moduleId, visible, imgPath)
end
function lobby_corner_dot.RefreshSpinCornerDot()
  local moduleIdArray = {
    BP_ENUM_MODULE_LUCKY_UNBACK,
    BP_ENUM_MODULE_LUCKY_BACK
  }
  local LogicActivityUtil = require("client.slua.logic.lobby.logic_activity_util")
  for _, moduleId in pairs(moduleIdArray) do
    local giftConfig = ActivityGiftConfig[moduleId] or {}
    for _, activityInfo in pairs(giftConfig) do
      local activityType = activityInfo[1]
      local condType = activityInfo[2]
      local cornnerDotVis = LogicActivityUtil.GetActivityAwardIndex(activityType, condType)
      local cornnerDotPath = LogicActivityUtil.GetActivityCornerDotPath(activityType, condType)
      lobby_corner_dot.RefreshDotInBanner(moduleId, cornnerDotVis, cornnerDotPath)
      lobby_corner_dot.RefreshDotInTopEntrance(moduleId, cornnerDotVis, cornnerDotPath)
      log(bWriteLog and "lobby_corner_dot.RefreshSpinCornerDot " .. tostring(cornnerDotVis) .. " " .. tostring(cornnerDotPath))
    end
  end
end
function lobby_corner_dot.RefreshDotByRedPoint(redPointName, visible, imgPath, posOffset)
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not lobbyMain then
    return
  end
  local midShopUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Shop_UIBP)
  if midShopUI then
    local key = "NewDotBy" .. redPointName
    lobby_corner_dot.SetDotVisible(midShopUI[redPointName], visible, key, imgPath, posOffset)
  end
end
function lobby_corner_dot.GetCornnerDotDetial(moduleIDArray)
  local LogicActivityUtil = require("client.slua.logic.lobby.logic_activity_util")
  for _, moduleId in pairs(moduleIDArray) do
    local giftConfig = ActivityGiftConfig[moduleId] or {}
    for _, activityInfo in pairs(giftConfig) do
      local activityType = activityInfo[1]
      local condType = activityInfo[2]
      local cornnerDotVis = LogicActivityUtil.GetActivityAwardIndex(activityType, condType)
      local cornnerDotPath = LogicActivityUtil.GetActivityCornerDotPath(activityType, condType)
      if cornnerDotVis then
        log(bWriteLog and "lobby_corner_dot.GetCornnerDotDetial " .. tostring(activityType) .. " " .. tostring(condType) .. " " .. tostring(cornnerDotVis) .. " " .. tostring(cornnerDotPath))
        return cornnerDotVis, cornnerDotPath
      end
    end
  end
end
function lobby_corner_dot.RefreshDotInRightEntrance()
  local cfgTable = {}
  if FuncUtil.IsPlayerJPKR() then
  else
    table.insert(cfgTable, {
      {
        BP_ENUM_LOBBY_MENU_MALL
      },
      "Store_Reddot_Anchor",
      FVector2D(0, 0)
    })
  end
  for _, cfg in pairs(cfgTable) do
    local moduleIdArray = cfg[1]
    local redPointName = cfg[2]
    local posOffset = cfg[3]
    local cornnerDotVis, cornnerDotPath = lobby_corner_dot.GetCornnerDotDetial(moduleIdArray)
    lobby_corner_dot.RefreshDotByRedPoint(redPointName, cornnerDotVis, cornnerDotPath, posOffset)
  end
end
function lobby_corner_dot.RefreshLobbyCornerDot()
  lobby_corner_dot.RefreshSpinCornerDot()
  lobby_corner_dot.RefreshDotInRightEntrance()
end
return lobby_corner_dot