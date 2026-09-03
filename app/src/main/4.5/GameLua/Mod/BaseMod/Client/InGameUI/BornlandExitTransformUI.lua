local CommonTransformConfig = require("GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.Config.CommonBornLandTransformConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local BornlandExitTransformUI = {}
function BornlandExitTransformUI:OnInitialize()
  print(bWriteLog and "BornlandExitTransformUI_Debug_Msg:OnInitialize")
  self:OnHeroIDChanged()
end
function BornlandExitTransformUI:OnShow()
  print(bWriteLog and "BornlandExitTransformUI_Debug_Msg:OnShow")
  self:OnHeroIDChanged()
end
function BornlandExitTransformUI:OnClose()
  print(bWriteLog and "BornlandExitTransformUI_Debug_Msg:OnClose")
end
function BornlandExitTransformUI:RegistEvents()
  print(bWriteLog and "BornlandExitTransformUI_Debug_Msg: RegistEvents")
  if EVENTTYPE_ROLEPLAY_NORMAL and EVENTID_LOCAL_HERO_ID_CHANGED then
    self:AddCommonEvent(EVENTTYPE_ROLEPLAY_NORMAL, EVENTID_LOCAL_HERO_ID_CHANGED, self.OnHeroIDChanged, self)
  end
  self:AddOnClickedEventByControl(self.UIRoot.Button_ExitTransform, self.OnClickedExitTransform, self)
end
function BornlandExitTransformUI:OnPostInitialize()
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if not slua.isValid(ShootingUIPanel) then
    return
  end
  if ShootingUIPanel and ShootingUIPanel.CanvasPanel_Root then
    ShootingUIPanel.CanvasPanel_Root:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
function BornlandExitTransformUI:OnHeroIDChanged()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(PlayerCharacter) or not PlayerCharacter.HeroPropFeature then
    print(bWriteLog and "BornlandExitTransformUI_Debug_Msg:OnHeroIDChanged HeroPropFeature is nil")
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local CurrentHeroID = PlayerCharacter.HeroPropFeature:GetCurrentHeroID()
  if CommonTransformConfig:CheckCommonBornlandTransform(CurrentHeroID) then
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BornlandExitTransformUI:OnClickedExitTransform()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not (Game:IsValid(PlayerCharacter) and PlayerCharacter.CommonBornlandTransformFeature) or not PlayerCharacter.CommonBornlandTransformFeature.RPC_Server_DoTransfrom then
    print(bWriteLog and "BornlandExitTransformUI:OnClickedExitTransform CommonBornlandTransformFeature is nil")
    return
  end
  PlayerCharacter.CommonBornlandTransformFeature:RPC_Server_DoTransfrom(false)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, BornlandExitTransformUI)