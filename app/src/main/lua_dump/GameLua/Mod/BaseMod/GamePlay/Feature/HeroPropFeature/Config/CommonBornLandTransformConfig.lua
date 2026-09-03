require("GameLua.Mod.BaseMod.Common.Core.EnumDefine")
local CommonTransformConfig = {
  CommonBornlandTransformConfig = {
    [UEnums.HeroID.Mecha] = {
      TransformDuration = 15,
      ItemID = 150013,
      ChangeItemID = 604106
    },
    [UEnums.HeroID.Mecha] = {
      TransformDuration = 15,
      ItemID = 150017,
      ChangeItemID = 6041001
    },
    [UEnums.HeroID.Mecha] = {
      TransformDuration = 15,
      ItemID = 15100001,
      ChangeItemID = 6041007
    }
  },
  LeftTimeBeforPlane = 15
}
function CommonTransformConfig:CheckCommonBornlandTransform(CheckHeroID)
  if CommonTransformConfig.CommonBornlandTransformConfig[CheckHeroID] then
    return true
  end
  return false
end
function CommonTransformConfig:GetChangeHeroIDByChangeItemID(ChangeItemID)
  for k, v in pairs(CommonTransformConfig.CommonBornlandTransformConfig) do
    if v.ChangeItemID == ChangeItemID then
      return k
    end
  end
end
function CommonTransformConfig:GetBornLandCanChangeHeroId()
  return {
    UEnums.HeroID.Spirit,
    UEnums.HeroID.Mecha
  }
end
return CommonTransformConfig