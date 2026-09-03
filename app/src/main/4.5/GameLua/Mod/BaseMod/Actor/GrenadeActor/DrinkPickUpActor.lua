local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local DrinkPickUpActor = {}
function DrinkPickUpActor:ctor()
  self.nDefineID = 601001
end
function DrinkPickUpActor:ReceiveBeginPlay()
  DrinkPickUpActor.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "DrinkPickUpActor:ReceiveBeginPlay")
  if Client then
    local CISDrinkSystem = SubsystemMgr:Get("CISDrinkSystem")
    local bReplaced = false
    if CISDrinkSystem then
      bReplaced = CISDrinkSystem:ReplaceDrinkMesh(self)
    end
    if not bReplaced then
      local uGameState = GameplayData.GetGameState()
      if uGameState and slua.isValid(uGameState) and uGameState.IsEnableRedirectItemIdToAvatarID and uGameState:IsEnableRedirectItemIdToAvatarID() then
        local AvatarID = uGameState:GetRedirectAvatarID(self.nDefineID)
        print(bWriteLog and "DrinkPickUpActor:ReceiveBeginPlay AvatarID:", AvatarID)
        self.ConsumeAvatarComponent_BP:ChangeItemAvatar(AvatarID, false)
      end
    end
  end
end
function DrinkPickUpActor:ReceiveEndPlay(_)
  print(bWriteLog and "DrinkPickUpActor:ReceiveEndPlay")
  DrinkPickUpActor.__super.ReceiveEndPlay(self, _)
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CDrinkPickUpActor = class(object, nil, DrinkPickUpActor)
return CDrinkPickUpActor