local LobbyModelCommonActor = {}
function LobbyModelCommonActor:GetRelativeCharacterAvatarComponent2()
  if not Client then
    return nil
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.Social)
  if CoupleAvatar then
    local model = CoupleAvatar:GetModel(1)
    if model then
      return model.CharacterAvatarComp2_BP
    end
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetModel(DataMgr.roleData.uid)
  if avatar and avatar.CharacterAvatarComp2_BP then
    return avatar.CharacterAvatarComp2_BP
  end
  return nil
end
function LobbyModelCommonActor:Sleep()
  if slua.isValid(self.MeshComponent) then
    self.MeshComponent:K2_DestroyComponent(self.MeshComponent)
    self.MeshComponent = nil
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CModelCommonActor = class(CActorBase, nil, LobbyModelCommonActor)
return CModelCommonActor