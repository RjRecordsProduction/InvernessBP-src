local GodTrialAIConsentPopup = require("GameLua.Mod.GodTrial.Client.UI.Popup.GodTrialAIConsentPopup")
local ClientLogic = {bCustomGameReuslt = false}
function ClientLogic:OnPostEnter(status)
  ClientLogic.__super.OnPostEnter(self, status)
end
function ClientLogic:OnControllerBeginPlay()
  ClientLogic.__super.OnControllerBeginPlay(self)
end
function ClientLogic:OnInitModeUI()
  print(bWriteLog and "ClientLogic:OnInitModeUI")
  GodTrialAIConsentPopup.TryShow()
  ClientLogic.__super.OnInitModeUI(self)
end
function ClientLogic:OnPreExit(status)
  ClientLogic.__super.OnPreExit(self, status)
end
function ClientLogic:OnGameResult(tBattleResult)
  ClientLogic.__super.OnGameResult(self, tBattleResult)
end
function ClientLogic:ShowCustomGameResult()
  ClientLogic.__super.ShowCustomGameResult(self)
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Client.ClientLogicEntry")
local CClientLogic = class(object, nil, ClientLogic)
return CClientLogic