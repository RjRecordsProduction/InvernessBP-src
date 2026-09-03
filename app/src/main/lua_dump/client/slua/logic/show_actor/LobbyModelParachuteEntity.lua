local LobbyModelParachuteEntity = {}
function LobbyModelParachuteEntity:OnShowModel(ItemID, BPID)
end
function LobbyModelParachuteEntity:RegistAsyncEvent()
  self:AddControlEvent(self.ModelActor, "OnCommonActorLoaded", self.OnAsyncReady, self)
end
function LobbyModelParachuteEntity:OnAsyncReady()
  LobbyModelParachuteEntity.__super.OnAsyncReady(self)
  if slua.isValid(self.ModelActor.MeshComponent) then
    self:RefreshTextureMipmapImmediately(self.ModelActor.MeshComponent)
  end
end
function LobbyModelParachuteEntity:ChangeAvatar()
  local ItemDefineID = self:MakeItemDefineID(4, self.ItemID)
  local Handle = self:CreateBattleItemHandle(ItemDefineID, self.ModelActor, true)
  if not slua.isValid(Handle) then
    ItemDefineID = self:MakeItemDefineID(4, 703001)
    Handle = self:CreateBattleItemHandle(ItemDefineID, self.ModelActor, true)
  end
  self.ModelActor:ShowByHandle(Handle, false)
end
function LobbyModelParachuteEntity:OnAsyncFinish()
  self.OwnerActor:UpdateCapsuleSize(500, 500)
end
local class = require("class")
local BaseModel = require("client.slua.logic.show_actor.LobbyModelBaseEntity")
local CLobbyModelParachuteEntity = class(BaseModel, nil, LobbyModelParachuteEntity)
return CLobbyModelParachuteEntity