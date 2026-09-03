local IslandConfig = {}
function IslandConfig:GetMapAboutConfig(AreaID)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType2 = GameMainConfig.GetMapType()
  if ModeType2 and self[AreaID] and self[AreaID][ModeType2] then
    return self[AreaID][ModeType2]
  else
    return nil
  end
end
function IslandConfig:IsInIsLandArea(Areaid)
  return self[Areaid]
end
function IslandConfig:DsGetCurrentIsLandPawnNum(Areaid, Object)
  local MapAboutConfig = self:GetMapAboutConfig(Areaid)
  if MapAboutConfig and MapAboutConfig.POIGeneralAreaPath then
    local BP_IsLand = slua.loadClass(MapAboutConfig.POIGeneralAreaPath)
    local OutList = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
    local UGameplayStatics = import("GameplayStatics")
    OutList = UGameplayStatics.GetAllActorsOfClass(Object, BP_IsLand, OutList)
    local nLen = OutList:Num()
    local BackNum = 0
    if 0 < nLen then
      for _, uActor in pairs(OutList) do
        if slua.isValid(uActor) and uActor.GetPlayerCount and uActor:GetPlayerCount() then
          BackNum = BackNum + uActor:GetPlayerCount()
        end
      end
    end
    return BackNum
  else
    return 0
  end
end
return IslandConfig