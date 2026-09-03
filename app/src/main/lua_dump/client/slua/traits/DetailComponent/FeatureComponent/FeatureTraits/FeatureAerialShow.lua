local FeatureAerialShow = {}
local Trait = require("common.trait")
local TFeatureAerialShow = Trait(Trait.TraitPrototype, nil, FeatureAerialShow)
function FeatureAerialShow:PlayAerialShow(data)
  local LogicAerialShow = require("client.slua.logic.glider.logic_aerial_show")
  if not LogicAerialShow:CanPlayAerialShow() then
    return
  end
  local AvatarAnimInst = LogicAerialShow:GetAvatarAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if AvatarAnimInst then
    local Montage = LogicAerialShow:GetAvatarAnimMontage(self.curFeaturesItemID)
    if Montage then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      AvatarAnimInst:Montage_Play(Montage, 1, EMontagePlayReturnType.Duration, 0)
    end
  end
  local GliderAnimInst = LogicAerialShow:GetGliderAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if GliderAnimInst then
    local Montage = LogicAerialShow:GetGliderAnimMontage(self.curFeaturesItemID)
    if Montage then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      GliderAnimInst:Montage_Play(Montage, 1, EMontagePlayReturnType.Duration, 0)
    end
  end
end
function FeatureAerialShow:StopAerialShow()
  local LogicAerialShow = require("client.slua.logic.glider.logic_aerial_show")
  local AvatarAnimInst = LogicAerialShow:GetAvatarAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if AvatarAnimInst then
    local Montage = LogicAerialShow:GetAvatarAnimMontage(self.curFeaturesItemID)
    if Montage and AvatarAnimInst:Montage_IsPlaying(Montage) then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      AvatarAnimInst:Montage_Stop(0, Montage)
    end
  end
  local GliderAnimInst = LogicAerialShow:GetGliderAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if GliderAnimInst then
    local Montage = LogicAerialShow:GetGliderAnimMontage(self.curFeaturesItemID)
    if Montage and GliderAnimInst:Montage_IsPlaying(Montage) then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      GliderAnimInst:Montage_Stop(0, Montage)
    end
  end
end
return TFeatureAerialShow