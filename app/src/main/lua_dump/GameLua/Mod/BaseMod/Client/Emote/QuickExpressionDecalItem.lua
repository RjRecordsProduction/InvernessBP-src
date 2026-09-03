local SI_BattleInterface = require("GameLua.Mod.SocialIsland.GamePlay.SI_BattleInterface")
local Util = require("client.slua_ui_framework.util")
local UIUtil = require("client.common.ui_util")
local ModelUtil = require("client.common.model_util")
local DEFAULT_PATH = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png"
local QuickExpressionDecalItem = {}
function QuickExpressionDecalItem:ctor()
  self.bIsShow = nil
  self.bLoaded = false
  self.bShouldRefreshEmote = false
  self.bShouldRefreshEmoteWhenShow = false
  self.LastTypeSpecificID = -99
  self.TypeSpecificID = -99
  self.LastNumber = -99
  self.Number = -99
  self.IsPetExpression = false
  self.IsLocked = false
  self.OnClickedCallback = nil
  self.UpdateCDTimer = nil
end
function QuickExpressionDecalItem:OnHide()
  QuickExpressionDecalItem.__super.OnClose(self)
end
function QuickExpressionDecalItem:OnClose()
  self.OnClickedCallback = nil
  self:RemoveUpdateCDTimer()
  QuickExpressionDecalItem.__super.OnClose(self)
end
function QuickExpressionDecalItem:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Click, self.OnClickedHandler, self)
end
function QuickExpressionDecalItem:OnPostInitialize()
  self:RefreshData(self.TypeSpecificID, self.Number, self.IsPetExpression, self.IsLocked)
end
function QuickExpressionDecalItem:OnShow()
  QuickExpressionDecalItem.__super.OnShow(self)
  self:UpdateCDInfo()
end
function QuickExpressionDecalItem:RefreshData(TypeSpecificID, Number, IsPetExpression, IsLocked)
  if bWriteLog then
    print("QuickExpressionDecalItem:RefreshData", TypeSpecificID, Number, IsPetExpression, IsLocked)
  end
  self.  self.  self.  self.  if self:IsAsyncLoading() then
    return
  end
  self:UpdateCDInfo()
  self:SetImageColor(FLinearColor(1, 1, 1, 1))
  self.UIRoot.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.TypeSpecificID == -1 then
    self.UIRoot.CanvasPanel_none:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_show:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(self.UIRoot.Panel_Download, false)
  else
    self.UIRoot.CanvasPanel_none:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_show:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.LastNumber ~= self.Number then
      self.LastNumber = self.Number
      if self.Number >= 0 then
        self.UIRoot.TextBlock_0:SetText(tostring(self.Number))
      else
        self.UIRoot.TextBlock_0:SetText("")
      end
    end
    if self.LastTypeSpecificID ~= self.TypeSpecificID then
      self.LastTypeSpecificID = self.TypeSpecificID
      if self.IsPetExpression then
        local PetActionData = CDataTable.GetTableData("PetActionTable", self.TypeSpecificID)
        if PetActionData and PetActionData.PetActionIcon then
          local PetActionID = PetActionData.PetActionID
          local icon, bHasAddKnownMissing, isDefaultIcon = UIUtil.GetItemSmallIcon(PetActionID, self.UIRoot.Image_spray)
          if bWriteLog then
            print("QuickExpressionDecalItem:RefreshData TypeSpecificID", PetActionID, icon, bHasAddKnownMissing, isDefaultIcon)
          end
          if isDefaultIcon then
            self:SetTexture(self.UIRoot.Image_spray, DEFAULT_PATH, {sync = false})
          else
            local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
            self:SetTexture(self.UIRoot.Image_spray, icon, params)
          end
          if self.IsLocked then
            self:SetImageColor(FLinearColor(1, 1, 1, 0.5))
            self.UIRoot.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            return
          end
        end
      else
        self:RefreshBrush()
      end
      local common_download_handler = require("client.slua.common.common_download_handler")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
        self.TypeSpecificID
      }, self.UIRoot.Panel_Download)
    end
  end
end
function QuickExpressionDecalItem:RefreshBrush()
  local ItemSmallIconPath, bHasAddKnownMissing, isDefaultIcon = UIUtil.GetItemSmallIcon(self.TypeSpecificID)
  print(bWriteLog and "QuickExpressionDecalItem:RefreshBrush", self.TypeSpecificID, ItemSmallIconPath, bHasAddKnownMissing, isDefaultIcon)
  if isDefaultIcon then
    self:SetTexture(self.UIRoot.Image_spray, DEFAULT_PATH, {sync = false})
  else
    local params = {sync = false, bMatchSize = true}
    Util.SetTexture(self.UIRoot.Image_spray, ItemSmallIconPath, params)
  end
end
function QuickExpressionDecalItem:SetData(OnClickedCallback, Index)
  self.  self.UIRoot.TextBlock_Index:SetText(tostring(Index))
end
function QuickExpressionDecalItem:OnClickedHandler()
  print(bWriteLog and "QuickExpressionDecalItem:OnClickedHandler", self.TypeSpecificID)
  if self.OnClickedCallback and SI_BattleInterface.SocialIslandEmoteCheck() then
    self.OnClickedCallback(self.TypeSpecificID)
  end
  local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
  ClientTLogUtil.ReportCommonTLogDataByBRPhase(214, 214, tostring(self.TypeSpecificID), 1)
end
function QuickExpressionDecalItem:SetImageColor(Color)
  self.UIRoot.Image_spray:SetColorAndOpacity(Color)
end
function QuickExpressionDecalItem:UpdateCDInfo()
  log(bWriteLog and "QuickExpressionDecalItem:UpdateCDInfo. ")
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if self.TypeSpecificID == logic_emote.PetExhibitActionID then
    log(bWriteLog and "QuickExpressionDecalItem:UpdateCDInfo. is pet exhibit emote")
    if not self.UpdateCDTimer then
      self.UpdateCDTimer = self:AddTimerLoop(0, function()
        self:UpdateCDInfoInternal()
      end, TIMER_INFINITE, 1)
    end
  else
    self:RemoveUpdateCDTimer()
  end
end
function QuickExpressionDecalItem:RemoveUpdateCDTimer()
  if self.UpdateCDTimer then
    self:RemoveTimer(self.UpdateCDTimer)
    self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UpdateCDTimer = nil
  end
end
function QuickExpressionDecalItem:UpdateCDInfoInternal()
  if slua.isValid(self.UIRoot) then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    local RemainCD = logic_emote.GetPetExhibitRemainCD()
    if RemainCD <= 0 then
      self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.TextBlock_CD:SetText(tostring(math.floor(RemainCD)))
      self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, QuickExpressionDecalItem)