local PlaneCharacterForShow = {}
local UGameplayStatics = import("GameplayStatics")
function PlaneCharacterForShow:ReceiveBeginPlay()
  print(bWriteLog and "PlaneCharacterForShow:ReceiveBeginPlay")
  PlaneCharacterForShow.__super.ReceiveBeginPlay(self)
  self.PlaneActor = nil
end
function PlaneCharacterForShow:ShowWingman()
  print(bWriteLog and "PlaneCharacterForShow:ShowWingman")
  if slua.isValid(self.PlaneActor) and self.PlaneActor.WingPlaneComponent_BP and self.WingPlaneComponent_BP then
    self.WingPlaneComponent_BP.WingManUserData = self.PlaneActor.WingPlaneComponent_BP.WingManUserData
    self.WingPlaneComponent_BP.XSuitIconFirst = self.PlaneActor.WingPlaneComponent_BP.XSuitIconFirst
    self.WingPlaneComponent_BP.XSuitIconSecond = self.PlaneActor.WingPlaneComponent_BP.XSuitIconSecond
    self.WingPlaneComponent_BP:OnRep_WingManUserData()
    self.WingPlaneComponent_BP:OnRep_XSuitIconFirst()
    return
  end
  print(bWriteLog and "PlaneCharacterForShow:ShowWingman Failed")
end
function PlaneCharacterForShow:ShowPlaneSkin()
  print(bWriteLog and "PlaneCharacterForShow:ShowPlaneSkin Try Get Skin")
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(GameState) and GameState.UpassInfoList:Num() > 0 then
    local TopInfo = GameState.UpassInfoList:Get(0)
    local ItemId = TopInfo and TopInfo.planeAvatarId or 0
    local PlaneAvatarComponentClass = import("PlaneAvatarComponent")
    local PlaneAvatarComponent = self:GetComponentByClass(PlaneAvatarComponentClass)
    local RealAvatarComponent = slua.isValid(self.PlaneActor) and self.PlaneActor:GetComponentByClass(PlaneAvatarComponentClass)
    print(bWriteLog and "PlaneCharacterForShow:ShowPlaneSkin Got Skin", ItemId)
    if slua.isValid(PlaneAvatarComponent) and slua.isValid(RealAvatarComponent) then
      print(bWriteLog and "PlaneCharacterForShow:ShowPlaneSkin Change Skin")
      PlaneAvatarComponent:PreChangePlaneAvatar(ItemId)
      RealAvatarComponent:PreChangePlaneAvatar(ItemId)
      return TopInfo
    end
  end
  print(bWriteLog and "PlaneCharacterForShow:ShowPlaneSkin Failed")
  return nil
end
function PlaneCharacterForShow:GetWingmanAttachComp(Index)
  print(bWriteLog and "PlaneCharacterForShow:GetWingmanAttachComp")
  local uParent = self:GetParentActor()
  if slua.isValid(uParent) and uParent.GetWingmanAttachComp then
    local uComp = uParent:GetWingmanAttachComp(Index)
    return uComp
  end
  return nil
end
function PlaneCharacterForShow:SetRealPlaneActor(uActor)
  print(bWriteLog and "PlaneCharacterForShow:SetRealPlaneActor:", uActor)
  if slua.isValid(uActor) then
    self.PlaneActor = uActor
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPlaneCharacterForShow = class(object, nil, PlaneCharacterForShow)
return CPlaneCharacterForShow