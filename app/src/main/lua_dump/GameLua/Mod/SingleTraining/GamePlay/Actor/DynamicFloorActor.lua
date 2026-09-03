local DynamicFloorActor = {}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
function DynamicFloorActor:ctor()
  self.FloorId = 0
  self.LandId = -1
end
function DynamicFloorActor:GetLifetimeReplicatedProps()
  print(bWriteLog and "DynamicFloorActor:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "FloorId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function DynamicFloorActor:ReceiveBeginPlay()
  print(bWriteLog and "DynamicFloorActor:ReceiveBeginPlay")
  DynamicFloorActor.__super.ReceiveBeginPlay(self)
  if self:IsAuthority() then
    self:AddCommonEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_CHANGE_FLOOR_MAT, self.SetFloorId, self)
  end
end
function DynamicFloorActor:SetFloorId(_, _, FloorId, LandId)
  if self.LandId == -1 then
    self.LandId = CGameMode:GetLandscapeId(self:K2_GetActorLocation())
  end
  if self.LandId == LandId then
    self.  end
end
function DynamicFloorActor:OnRep_FloorId()
  printf("DynamicFloorActor:OnRep_FloorId", self.FloorId)
  self:ChangeFloorMaterial(self.FloorId)
end
function DynamicFloorActor:ChangeFloorMaterial(FloorId)
  if FloorId and 0 < FloorId and self.FloorMesh then
    local Util = require("client.slua_ui_framework.util")
    local FloorMaterialPath = SingleTrainingConfig.FloorMaterialCfg[FloorId]
    if FloorMaterialPath then
      Util.GetAssetAsync(FloorMaterialPath, function(LoadObj)
        if slua.isValid(LoadObj) then
          if self.FloorMesh then
            self.FloorMesh:SetMaterial(0, LoadObj)
            print(bWriteLog and "DynamicFloorActor:ChangeFloorMaterial SetMaterial succeed", FloorId)
          else
            print(bWriteLog and "DynamicFloorActor:ChangeFloorMaterial SetMaterial failed")
          end
        end
      end)
    else
      print(bWriteLog and "DynamicFloorActor:ChangeFloorMaterial Cant find material path", FloorId)
    end
  end
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CDynamicFloorActor = class(base, nil, DynamicFloorActor)
return CDynamicFloorActor