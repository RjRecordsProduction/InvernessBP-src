local CoupleAvatarMiniTV = {}
function CoupleAvatarMiniTV:_CreateMiniTV(avatar, uid)
  log(bWriteLog and "CoupleAvatarPet _CreateMiniTV avatar:" .. tostring(avatar) .. " uid " .. tostring(uid))
  if not avatar or not uid then
    return
  end
  if not self:CanShowMiniTv() then
    return
  end
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local minitvDressID = BasicDataAvatarWearInfo:GetMiniTVDressID(uid)
  avatar:UpdateOrCreateMiniTV(minitvDressID)
end
function CoupleAvatarMiniTV:UpdateOrCreateMiniTV(avatar, dressItemID)
  if not avatar then
    return
  end
  if not self:CanShowMiniTv() then
    return
  end
  avatar:UpdateOrCreateMiniTV(dressItemID)
end
function CoupleAvatarMiniTV:_AdjustMiniTVLocation(AvatarType)
  log(bWriteLog and "CoupleAvatarMiniTV _AdjustMiniTVLocation AvatarType" .. tostring(AvatarType))
  local avatar = self:GetAvatar(AvatarType)
  if not avatar then
    log(bWriteLog and "CoupleAvatarMiniTV _AdjustMiniTVLocation not avatar")
    return
  end
  local miniTVActor = avatar:GetMiniTVActor()
  if miniTVActor then
    local Pose = self:GetSelfPoseID()
    local PoseType = self:GetStandType(AvatarType)
    miniTVActor:AdjustAttachLocationForCoupleAvatar(self.pawnContainer, Pose, PoseType, self:IsTwoPerson())
  end
end
function CoupleAvatarMiniTV:CanShowMiniTv()
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MINI_TV_REV) then
    return false
  end
  local bCanShow = true
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  local SwitchKey = "ShowMiniTvInSocial"
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.Social)
  if self.sceneType ~= CoupleAvatarSystem.ESceneType.Social then
    SwitchKey = "ShowMiniTvInRank"
  end
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) then
      log(bWriteLog and "CoupleAvatarMiniTV:CanShowMiniTv SwitchKey:" .. tostring(SwitchKey) .. " bCanShow:" .. tostring(bCanShow))
      bCanShow = uSettingConfig[SwitchKey]
    end
  end
  return bCanShow
end
local Trait = require("common.trait")
local TCoupleAvatarMiniTV = Trait(Trait.TraitPrototype, nil, CoupleAvatarMiniTV)
return TCoupleAvatarMiniTV