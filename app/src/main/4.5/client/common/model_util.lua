local model_util = {}
local local local UKismetSystemLibrary = import("KismetSystemLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local BusinessHelper = import("BusinessHelper")
local local local local local local local local StringUtil = require("common.string_util")
function model_util.GetAssetObjByPath(Path)
  if not Path then
    log(bWriteLog and "model_util.GetAssetObjByPath Path is nil")
    return
  end
  local softObjPath = UKismetSystemLibrary.MakeSoftObjectPath(Path)
  if softObjPath == nil then
    log(bWriteLog and "model_util.GetAssetObjByPath softObjPath is nil" .. tostring(Path))
    return nil
  end
  local AnimAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
  if AnimAsset == nil then
    log(bWriteLog and "model_util.GetAssetObjByPath  AnimAsset is nil:" .. tostring(Path))
    return nil
  end
  return AnimAsset
end
function model_util.IsBattleItemHandleExist(BPTableName, BPID, IsLobby, bForceLobby)
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local HandlePath = UAELoadedClassManager:GetPath(BPTableName, BPID, IsLobby, bForceLobby)
  local UBackpackUtils = import("BackpackUtils")
  return UBackpackUtils.IsBattleItemHandlePathExist(HandlePath)
end
function model_util.GetClass(BPTableName, BPID, IsLobby, IsLowDevice)
  log(bWriteLog and "model_util GetClass ItemId:" .. " BPTableName: " .. tostring(BPTableName) .. " BPID " .. tostring(BPID))
  if not model_util.IsBattleItemHandleExist(BPTableName, BPID, IsLobby, false) then
    log(bWriteLog and "model_util GetClass Handle Is Not Exist BPID:" .. tostring(BPID))
    return nil
  end
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local BPHandleClass = UAELoadedClassManager:GetClass(BPTableName, BPID, IsLobby, IsLowDevice)
  return BPHandleClass
end
function model_util.GetPath(BPTableName, BPID, IsLobby, bForceLobby)
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local HandlePath = UAELoadedClassManager:GetPath(BPTableName, BPID, IsLobby, bForceLobby)
  return HandlePath
end
function model_util.GetBPID(ItemID)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return -1
  end
  return itemCfg.BPID
end
function model_util.ConvertStringToFVector(str)
  local result = StringUtil.Split(str, ";")
  if #result ~= 3 then
    log(bWriteLog and "model_util ConvertStringToVector #result < 3 str" .. tostring(str))
    return FVector(0, 0, 0)
  end
  local X = tonumber(result[1])
  local Y = tonumber(result[2])
  local Z = tonumber(result[3])
  return FVector(X, Y, Z)
end
function model_util.ConvertFVectorToString(Vector)
  local string = "X:" .. string.format("%.2f", Vector.X) .. " Y:" .. string.format("%.2f", Vector.Y) .. " Z:" .. string.format("%.2f", Vector.Z)
  return string
end
function model_util.SpawnActor(ActorPath)
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    log(bWriteLog and "model_util.SpawnActor World is null")
    return
  end
  local ActorClass = import(ActorPath .. "_C")
  local Actor = world:SpawnActor(ActorClass, nil, nil, nil)
  return Actor
end
function model_util.GetComponentByTag(Owner, Class, Tag)
  if not slua.isValid(Owner) or not Class then
    return
  end
  local targetArray = Owner:GetComponentsByTag(Class, Tag)
  if targetArray and targetArray:Num() > 0 and slua.isValid(targetArray:Get(0)) then
    return targetArray:Get(0)
  end
  return
end
local ReplaceMaterialOrder = {
  "NM",
  "NormalMap",
  "Normal",
  "MaskGrayTex",
  "Diffuse",
  "DF",
  "BaseColor",
  "RMA"
}
local ReplaceMaterialSlotName = {
  NM = "Normal",
  Normal = "Normal",
  NormalMap = "Normal",
  MaskGrayTex = "BaseColor",
  BaseColor = "BaseColor",
  Diffuse = "BaseColor",
  DF = "BaseColor",
  RMA = "RMA"
}
function model_util.GetMaterialParent(RawMaterial)
  local Parent = RawMaterial
  if RawMaterial.Parent and slua.isValid(RawMaterial.Parent) then
    return model_util.GetMaterialParent(RawMaterial.Parent)
  end
  return Parent
end
function model_util.ChangeMeshCompFeatureMaterial(meshComp, material)
  if not slua.isValid(meshComp) then
    return
  end
  if meshComp:ComponentHasTag("IgnoreChangeFeatureMaterial") then
    return
  end
  local UAvatarUtils = import("AvatarUtils")
  local KismetMaterialLibrary = import("KismetMaterialLibrary")
  local num = -1
  local materials = meshComp:GetMaterials()
  local Index = meshComp:GetMaterialIndex("Reticle")
  for key, Oldmaterial in pairs(materials) do
    num = num + 1
    if Index ~= key then
      if Oldmaterial and slua.isValid(Oldmaterial) then
        local ParentMaterial = model_util.GetMaterialParent(Oldmaterial)
        local ParentMaterialName = UAvatarUtils.GetMaterialName(ParentMaterial)
        if ParentMaterialName == "M_SmoothNormalOutLine" then
          print(bWriteLog and "model_util.ChangeMeshCompFeatureMaterial, ParentMaterialName = " .. tostring(ParentMaterialName))
      end
      else
        local DynamicMaterialInstance = KismetMaterialLibrary.CreateDynamicMaterialInstance(meshComp, material)
        if slua.isValid(DynamicMaterialInstance) then
          meshComp:SetFeatureMaterial(num, DynamicMaterialInstance)
          if Oldmaterial then
            local UMaterialInstance = import("MaterialInstance")
            if not Game:IsClassOf(Oldmaterial, UMaterialInstance) then
              return
            end
            for Order, OriName in ipairs(ReplaceMaterialOrder) do
              local TargetName = ReplaceMaterialSlotName[OriName]
              local oldt = UAvatarUtils.K2_GetTextureParameterValue(Oldmaterial, OriName)
              if slua.isValid(oldt) then
                DynamicMaterialInstance:SetTextureParameterValue(TargetName, oldt)
              end
            end
          end
        end
      end
    end
  end
end
function model_util.ChangeMeshCompsFeatureMaterial(meshComps, material)
  for key, Comp in pairs(meshComps) do
    if slua.isValid(Comp) then
      model_util.ChangeMeshCompFeatureMaterial(Comp, material)
    end
  end
end
function model_util.ClearMeshCompsFeatureMaterial(meshComps)
  for key, Comp in pairs(meshComps) do
    if slua.isValid(Comp) and not Comp:ComponentHasTag("IgnoreChangeFeatureMaterial") then
      Comp:ClearAllFeatureMaterial()
    end
  end
end
function model_util.ChangeActorAllMeshCompFeatureMaterial(Actor, material)
  local AllMeshComps = model_util.GetAllMeshComponents(Actor)
  model_util.ChangeMeshCompsFeatureMaterial(AllMeshComps, material)
end
function model_util.ClearActorMeshCompsFeatureMaterial(Actor)
  local AllMeshComps = model_util.GetAllMeshComponents(Actor)
  model_util.ClearMeshCompsFeatureMaterial(AllMeshComps)
end
function model_util.GetAllMeshComponents(Actor)
  local MeshComps = {}
  if not slua.isValid(Actor) then
    return MeshComps
  end
  local MeshComponent = import("/Script/Engine.MeshComponent")
  local _Comps = Actor:GetComponentsByClass(MeshComponent)
  for key, _Comp in pairs(_Comps) do
    if slua.isValid(_Comp) then
      table.insert(MeshComps, _Comp)
    end
  end
  return MeshComps
end
function model_util.IsChildOfBattleItemHandleBase(BPHandleClass)
  if not BPHandleClass then
    return false
  end
  local BattleItemHandleBase = import("/Script/Basic.BattleItemHandleBase")
  if BusinessHelper.IsChildOf(BPHandleClass, BattleItemHandleBase) then
    return true
  end
  return false
end
function model_util.IsChildOfBackpackCommonAvatarHandle(Object)
  if not slua.isValid(Object) then
    return false
  end
  local BackpackCommonAvatarHandle = import("BackpackCommonAvatarHandle")
  if Game:IsClassOf(Object, BackpackCommonAvatarHandle) then
    return true
  end
  return false
end
function model_util.GetObjectName(Object)
  if not Object then
    return "nil"
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  return UKismetSystemLibrary.GetObjectName(Object)
end
return model_util