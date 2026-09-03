local CommonTransformConfig = require("GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.Config.CommonBornLandTransformConfig")
local CommonPlayerTransformDataComponent = {}
function CommonPlayerTransformDataComponent:EnterHero(InHeroID)
  print(bWriteLog and "CommonPlayerTransformDataComponent:EnterHero")
  local uCharacter = self:GetCharacter()
  CommonPlayerTransformDataComponent.__super.EnterHero(self, InHeroID)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
  if slua.isValid(self.OwnerActor) and self.OwnerActor.ModTransformMgrFeature and self.OwnerActor.ModTransformMgrFeature.EnterHero then
    return self.OwnerActor.ModTransformMgrFeature:EnterHero(InHeroID)
  end
  if slua.isValid(uCharacter) and CommonFightTransformConfig and CommonFightTransformConfig:CheckFightTransform(InHeroID) and uCharacter.BeComeOtherFigureFeature then
    self.bClearSaveBackpack = true
    self.bResetPawnState = true
    uCharacter.BeComeOtherFigureFeature:EnterHero(InHeroID)
  end
  if slua.isValid(uCharacter) and CommonTransformConfig:CheckCommonBornlandTransform(InHeroID) then
    if not uCharacter.CommonBornlandTransformFeature then
      uCharacter:EnsureDynamicFeature("CommonBornlandTransformFeature")
      print(bWriteLog and "CommonPlayerTransformDataComponent:EnterHero CommonBornlandTransformFeature is nil, EnsureDynamicFeature")
    end
    if uCharacter.CommonBornlandTransformFeature then
      uCharacter.CommonBornlandTransformFeature:EnterHero(InHeroID)
    end
  end
  if Client then
    self.LastClientHeroID = InHeroID
  end
end
function CommonPlayerTransformDataComponent:ExitHero(bForceExit)
  print(bWriteLog and "CommonPlayerTransformDataComponent:ExitHero")
  local LastHeroID = self.OwnerComp:GetHeroID()
  CommonPlayerTransformDataComponent.__super.ExitHero(self, bForceExit)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
  if slua.isValid(self.OwnerActor) and self.OwnerActor.ModTransformMgrFeature and self.OwnerActor.ModTransformMgrFeature.ExitHero then
    return self.OwnerActor.ModTransformMgrFeature:ExitHero(bForceExit)
  end
  local uCharacter = self:GetCharacter()
  if slua.isValid(uCharacter) then
    if Client then
      if CommonTransformConfig:CheckCommonBornlandTransform(self.LastClientHeroID) then
        if not uCharacter.CommonBornlandTransformFeature then
          uCharacter:EnsureDynamicFeature("CommonBornlandTransformFeature")
          print(bWriteLog and "CommonPlayerTransformDataComponent:ExitHero Client CommonBornlandTransformFeature is nil---1, EnsureDynamicFeature")
        end
        if uCharacter.CommonBornlandTransformFeature then
          uCharacter.CommonBornlandTransformFeature:ExitHero(bForceExit)
        else
          print(bWriteLog and "CommonPlayerTransformDataComponent:ExitHero Client CommonBornlandTransformFeature is nil")
        end
      elseif CommonFightTransformConfig and CommonFightTransformConfig:CheckFightTransform(self.LastClientHeroID) and uCharacter.BeComeOtherFigureFeature then
        uCharacter.BeComeOtherFigureFeature:ExitHero(bForceExit, self.LastClientHeroID)
      end
      self.LastClientHeroID = 0
    elseif CommonTransformConfig:CheckCommonBornlandTransform(LastHeroID) then
      if not uCharacter.CommonBornlandTransformFeature then
        uCharacter:EnsureDynamicFeature("CommonBornlandTransformFeature")
        print(bWriteLog and "CommonPlayerTransformDataComponent:ExitHero DS CommonBornlandTransformFeature is nil---1, EnsureDynamicFeature")
      end
      if uCharacter.CommonBornlandTransformFeature then
        uCharacter.CommonBornlandTransformFeature:ExitHero(bForceExit)
      else
        print(bWriteLog and "CommonPlayerTransformDataComponent:ExitHero DS CommonBornlandTransformFeature is nil")
      end
    elseif CommonFightTransformConfig and CommonFightTransformConfig:CheckFightTransform(LastHeroID) and uCharacter.BeComeOtherFigureFeature then
      uCharacter.BeComeOtherFigureFeature:ExitHero(bForceExit, LastHeroID)
    end
  end
end
local class = require("class")
local CTransformDataBaseComponent = require("GameLua.Mod.Library.GamePlay.Component.PlayerTransformDataBaseComponent")
local CCommonPlayerTransformDataComponent = class(CTransformDataBaseComponent, nil, CommonPlayerTransformDataComponent)
return CCommonPlayerTransformDataComponent