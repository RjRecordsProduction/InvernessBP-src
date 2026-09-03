local CoupleAvatarSystem = {}
function CoupleAvatarSystem:DefineAndResetData()
  self.CoupleAvatars = {}
  local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
  self.ESceneType = CoupleAvatarConfig.ESceneType
end
function CoupleAvatarSystem:GetOrCreateCoupleAvatar(sceneType)
  log(bWriteLog and "CoupleAvatarSystem GetOrCreateCoupleAvatar sceneType" .. tostring(sceneType))
  if self.CoupleAvatars[sceneType] then
    return self.CoupleAvatars[sceneType]
  end
  local CoupleAvatar = self:_CreateEntity(sceneType)
  self.CoupleAvatars[sceneType] = CoupleAvatar
  return CoupleAvatar
end
function CoupleAvatarSystem:GetCoupleAvatar(sceneType)
  log(bWriteLog and "CoupleAvatarSystem GetCoupleAvatar sceneType" .. tostring(sceneType))
  if self.CoupleAvatars[sceneType] then
    return self.CoupleAvatars[sceneType]
  end
end
function CoupleAvatarSystem:DestoryCoupleAvatar(sceneType)
  log(bWriteLog and "CoupleAvatarSystem DestoryCoupleAvatar sceneType" .. tostring(sceneType))
  if self.CoupleAvatars[sceneType] then
    self.CoupleAvatars[sceneType]:_DestroyCoupleAvatar()
    self.CoupleAvatars[sceneType] = nil
  end
end
function CoupleAvatarSystem:_CreateEntity(sceneType)
  log(bWriteLog and "CoupleAvatarSystem:_CreateEntity sceneType = " .. tostring(sceneType))
  local CoupleAvatar = require("client.logic.avatar.CoupleAvatar")
  local result = CoupleAvatar(sceneType)
  return result
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_couple_avatar = class(CModuleBase, nil, CoupleAvatarSystem)
return Clogic_couple_avatar