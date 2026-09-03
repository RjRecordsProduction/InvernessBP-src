local LobbySceneMgrHelper = {}
local GameplayStatics = import("GameplayStatics")
local actorClass = import("/Script/Engine.Actor")
local asset_util = require("common.asset_util")
local KismetSystemLibrary = import("KismetSystemLibrary")
local KismetMaterialLibrary = import("KismetMaterialLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local handler, CreateActor
local CurrentSceneKey = 0
function LobbySceneMgrHelper.GetAllActorsWithTag(tag)
  local world = slua_GameFrontendHUD:GetWorld()
  local actorArray = slua.Array(UEnums.EPropertyClass.Object, actorClass)
  return GameplayStatics.GetAllActorsWithTag(world, tag, actorArray)
end
function LobbySceneMgrHelper.SetMallWeaponParticalVisible(bVis)
  local partical = LobbySceneMgrHelper.GetWeaponPartical()
  local UIUtil = require("client.common.ui_util")
  if UIUtil.IsValid(partical) then
    partical:SetActorHiddenInGame(bVis)
  end
end
function LobbySceneMgrHelper.GetWeaponPartical()
  return LobbySceneMgrHelper.GetBaseActorByTagAndName("weaponPartical", "WeaponPartical")
end
function LobbySceneMgrHelper.ChangeMallSceneMaterial(materialID)
  local world = slua_GameFrontendHUD:GetWorld()
  local GlobalUIFunctionLibrary_C = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  GlobalUIFunctionLibrary_C.SwitchLobbyMeshBg(materialID, world)
end
function LobbySceneMgrHelper.ChangeMallSceneTexture(textureUrl)
  LobbySceneMgrHelper.ChangeSceneTextureByType(textureUrl, 1)
end
function LobbySceneMgrHelper.ChangeWeaponSceneTexture(textureUrl)
  LobbySceneMgrHelper.ChangeSceneTextureByType(textureUrl, 2)
end
function LobbySceneMgrHelper.ChangePictorialSceneTexture(textureUrl)
  LobbySceneMgrHelper.ChangeSceneTextureByType(textureUrl, 3)
end
function LobbySceneMgrHelper.ChangeSceneTextureByType(textureUrl, type)
  if textureUrl == "" then
    return
  end
  local changeFunc
  if type == 1 then
    changeFunc = LobbySceneMgrHelper.ChangeMallScene
  elseif type == 2 then
    changeFunc = LobbySceneMgrHelper.ChangeWeaponScene
  elseif type == 3 then
    changeFunc = LobbySceneMgrHelper.ChangePictorialScene
  end
  if not changeFunc then
    return
  end
  CurrentSceneKey = textureUrl
  local texture = asset_util.GetAssetSync(textureUrl)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.IsValid(texture) then
    changeFunc(texture)
  else
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    texture = image_download_mgr:GetLocalImageCache(textureUrl)
    if UIUtil.IsValid(texture) then
      changeFunc(texture)
    else
      image_download_mgr:DownloadImageByHttpWrapper(textureUrl, changeFunc)
    end
  end
end
function LobbySceneMgrHelper.ChangeMallScene(BgImg, imgUrl)
  LobbySceneMgrHelper.ChangeSceneByType(BgImg, imgUrl, 1)
end
function LobbySceneMgrHelper.ChangeWeaponScene(BgImg, imgUrl)
  LobbySceneMgrHelper.ChangeSceneByType(BgImg, imgUrl, 2)
end
function LobbySceneMgrHelper.ChangePictorialScene(BgImg, imgUrl)
  LobbySceneMgrHelper.ChangeSceneByType(BgImg, imgUrl, 3)
end
function LobbySceneMgrHelper.ChangeSceneByType(BgImg, imgUrl, type)
  local UIUtil = require("client.common.ui_util")
  if not imgUrl or imgUrl ~= CurrentSceneKey then
    return
  end
  local path, tagName, attrName
  if type == 1 then
    path = "/Game/Arts_Scenes/Materials/UI/Lobby02/Lobby02_close_up_Inst.Lobby02_close_up_Inst"
    tagName = "LobbyBgMesh"
    attrName = "StMesh"
  elseif type == 2 then
    path = "/Game/Arts_Scenes/Lobby/Old/Lobby02_mesh/Mat_Lobby_WEP_Institute.Mat_Lobby_WEP_Institute"
    tagName = "Background_Weapon_02"
    attrName = "StaticMeshComponent"
  elseif type == 3 then
    path = "/Game/Arts_Scenes/Materials/UI/Lobby02/Lobby02_close_up_Inst.Lobby02_close_up_Inst"
    tagName = "LobbyBgMesh_tj"
    attrName = "StMesh"
  end
  if UIUtil.IsValid(BgImg) then
    local softObjPath = KismetSystemLibrary.MakeSoftObjectPath(path)
    local asset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
    local BgMat = KismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), asset)
    if BgMat then
      BgMat:SetTextureParameterValue("Diffuse", BgImg)
      local util = UIUtil.GetGameFrontendHUD():GetUtils()
      local actors = LobbySceneMgrHelper.GetAllActorsWithTag(tagName)
      for _, actor in pairs(actors) do
        if attrName ~= nil and actor[attrName] ~= nil then
          actor[attrName]:SetMaterial(0, BgMat)
        end
      end
    end
  end
end
function LobbySceneMgrHelper.ChangeLight(lightType)
  local world = slua_GameFrontendHUD:GetWorld()
  local GlobalUIFunction = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  if lightType == LobbySceneManager.LIGHT_LOBBY then
    GlobalUIFunction.SetLobbyDefaultLightProperty(world)
  elseif lightType == LobbySceneManager.LIGHT_MALL_MODEL then
    GlobalUIFunction.SetWeaponLightProperty(world)
  elseif lightType == LobbySceneManager.LIGHT_MALL_AVATAR then
    GlobalUIFunction.SetHumanLightProperty(world)
  elseif lightType == LobbySceneManager.LIGHT_ARENA_WEAPON then
    GlobalUIFunction.SetArenaWeaponLightProperty(world)
  end
  LobbySceneMgrHelper.UpdateMPCLightDirection(world)
end
function LobbySceneMgrHelper.UpdateMPCLightDirection(worldContext)
  local tmpMinDistance = 1000000
  local tmpMinIndex = 0
  local GameplayStatics = import("GameplayStatics")
  local lightClass = import("/Script/Engine.DirectionalLight")
  local uActor = import("/Script/Engine.Actor")
  local lightArray = GameplayStatics.GetAllActorsOfClass(worldContext, lightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  local AfterLoop = function()
    if lightArray:Num() > tmpMinIndex then
      local element = lightArray:Get(tmpMinIndex)
      if slua.isValid(element) then
        local vector = element.LightComponent:GetForwardVector()
        local KismetMathLibrary = import("KismetMathLibrary")
        vector = KismetMathLibrary.Multiply_VectorFloat(vector, -1.0)
        local linearColor = KismetMathLibrary.Conv_VectorToLinearColor(vector)
        LobbySceneMgrHelper.LastLinearColor = LobbySceneMgrHelper.LastLinearColor or nil
        if linearColor == LobbySceneMgrHelper.LastLinearColor then
          return
        end
        local KismetMaterialLibrary = import("KismetMaterialLibrary")
        local asset_util = require("common.asset_util")
        asset_util.GetAssetAsync("/Game/Arts/Common/MatFunctions/MPC_LightDirection.MPC_LightDirection", function(LoadObject)
          if slua.isValid(worldContext) then
            KismetMaterialLibrary.SetVectorParameterValue(worldContext, LoadObject, "LightDirection", linearColor)
            LobbySceneMgrHelper.LastLinearColor = linearColor
          end
        end)
      else
        log(bWriteLog and "LobbySceneMgrHelper:AfterLoop, element = nil")
      end
    else
      log(bWriteLog and "LobbySceneMgrHelper:AfterLoop, lightArray:Num() <= " .. tostring(tmpMinIndex))
    end
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local camera = Lobby_camera_manager_module:GetCurrentCamera()
  if camera then
    for i = 0, lightArray:Num() - 1 do
      local element = lightArray:Get(i)
      if element ~= nil then
        local curLocation = camera:K2_GetActorLocation()
        local eleLocation = element:K2_GetActorLocation()
        local KismetMathLibrary = import("KismetMathLibrary")
        local subVector = KismetMathLibrary.Subtract_VectorVector(curLocation, eleLocation)
        local vectorLen = KismetMathLibrary.VSize(subVector)
        if tmpMinDistance >= vectorLen then
          tmpMinIndex = i
          tmpMinDistance = vectorLen
        end
      else
        log(bWriteLog and "LobbySceneMgrHelper:UpdateMPCLightDirection, element = nil")
      end
    end
    AfterLoop()
  else
    AfterLoop()
  end
end
function LobbySceneMgrHelper.GetBaseActorByTagAndName(vName, tagName)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.IsValid(LobbySceneMgrHelper[vName]) then
    return LobbySceneMgrHelper[vName]
  end
  local actors = LobbySceneMgrHelper.GetAllActorsWithTag(tagName)
  if actors:Num() > 0 then
    LobbySceneMgrHelper[vName] = actors:Get(0)
  end
  return LobbySceneMgrHelper[vName]
end
function LobbySceneMgrHelper.DestroyXmissionEnterEmitter()
  local actorArray = LobbySceneMgrHelper.GetAllActorsWithTag("XmissionEnter")
  local len = actorArray:Num()
  for k, actor in pairs(actorArray) do
    STExtraBlueprintFunctionLibrary.DestroyActorWithParam(actor, false, false)
  end
end
function LobbySceneMgrHelper.ParseVec3(str)
  local vec = {
    x_f = 1,
    y_f = 1,
    z_f = 1
  }
  if str and str ~= "" then
    local StringUtil = require("common.string_util")
    local arr = StringUtil.Split(str, ";")
    if arr and #arr == 3 then
      vec = {
        x_f = tonumber(arr[1]),
        y_f = tonumber(arr[2]),
        z_f = tonumber(arr[3])
      }
    end
  end
  return vec
end
function LobbySceneMgrHelper.GetStreamingLevel(levelName)
  if not levelName then
    return nil
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local level = GameplayStatics.GetStreamingLevel(world, levelName)
  return level
end
function handler(self, func, ...)
  return func(self, ...)
end
function CreateActor(path)
  local softObjPath = KismetSystemLibrary.MakeSoftObjectPath(path)
  local ClassObj = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(softObjPath)
  local world = slua_GameFrontendHUD:GetWorld()
  local actorObj = world:SpawnActor(ClassObj, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  actorObj:SetActorScale3D(FVector(1.0, 1.0, 1.0))
  return actorObj
end
return LobbySceneMgrHelper