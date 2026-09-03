local IngamePosOnPlaneItem = {}
local uGameplayStatics = import("GameplayStatics")
local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local uSTExtraUIUtils = import("STExtraUIUtils")
local uAkGameplayStatics = import("AkGameplayStatics")
local uBusinessHelper = import("BusinessHelper")
local uKismetSystemLibrary = import("KismetSystemLibrary")
local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local uEPlayerLiveState = import("ExtraPlayerLiveState")
local uEGameModeType = import("EGameModeType")
local uEFollowState = import("EFollowState")
local uEUAVUseType = import("EUAVUseType")
local uEUAVCharacterMsgType = import("/Script/ShadowTrackerExtra.EUAVCharacterMsgType")
local uEMentorPlayerType = import("EMentorPlayerType")
local uEParachuteInvitationType = import("EParachuteInvitationType")
function IngamePosOnPlaneItem:ctor(_, nIndex, TeamMatePlayerState)
  self.  self.uPlayerState = TeamMatePlayerState
end
function IngamePosOnPlaneItem:OnInitialize()
  IngamePosOnPlaneItem.__super.OnInitialize(self)
  self.UIRoot.TextBlock_TeamIndex:SetText(self.nIndex)
  if TeamPanelConfig.TeamPlayerColorTable[self.nIndex] then
    self.UIRoot.Image_PlayerOffOnlineBG:SetColorAndOpacity(TeamPanelConfig.TeamPlayerColorTable[self.nIndex])
  end
end
function IngamePosOnPlaneItem:OnPostInitialize()
  IngamePosOnPlaneItem.__super.OnPostInitialize(self)
end
function IngamePosOnPlaneItem:Close()
  self.uPlayerState = nil
  IngamePosOnPlaneItem.__super.Close(self)
end
function IngamePosOnPlaneItem:HideWidget()
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngamePosOnPlaneItem:ShowWidget()
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, IngamePosOnPlaneItem)