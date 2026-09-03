local AirDropMesh = {
  _init = false,
  _cur_AirdropBox = nil,
  _lastSmokeIndex = 0,
  _endTime = 0,
  _BoxShow = true
}
local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
local clock = require("client.slua.common.clock")
local NClockHandle
function AirDropMesh.Create()
  log(bWriteLog and "AirDropMesh_Create")
  local TimeUtil = require("client.common.time_util")
  local scene_list = {
    1,
    2,
    3,
    4
  }
  local hasTargetAirDrop = false
  for _, scene_id in ipairs(scene_list) do
    hasTargetAirDrop = hasTargetAirDrop or LuckAirDropSystem.CheckHasAirDropByScene(scene_id)
    if hasTargetAirDrop then
      AirDropMesh._endTime = LuckAirDropSystem.target_airdrop_data[scene_id].end_time
      break
    end
  end
  if LuckAirDropSystem.GetLeftTime() > 0 or hasTargetAirDrop then
    log(bWriteLog and "AirDropMesh.registEvent")
    if hasTargetAirDrop then
      LuckAirDropSystem.AirDropType = 1
    else
      LuckAirDropSystem.AirDropType = 0
    end
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    if (AirDropMesh._cur_AirdropBox == nil or not slua.isValid(AirDropMesh._cur_AirdropBox)) and not RoleInfoMainSystem.IsShow() then
      EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, AirDropMesh.HideBox)
      EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, AirDropMesh.ShowBox)
      EventSystem:registEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, AirDropMesh.HideBox)
      EventSystem:registEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_LOBBY, AirDropMesh.ShowBox)
      EventSystem:registEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_PREVIEW, AirDropMesh.HideBox)
      log(bWriteLog and "AirDropMesh__cur_AirdropBox")
      AirDropMesh.DownloadResourceAndCreateBox()
    end
    AirDropMesh._init = true
  end
end
function AirDropMesh.DownloadResourceAndCreateBox()
  log(bWriteLog and "AirDropMesh Download BoxMesh")
  local airdropClassPath = LuckAirDropSystem.GetAirDropClassPath()
  local meshAssetPath = LuckAirDropSystem.GetMeshAssetPath()
  local extraData = {bFirst = true, bSkipPopUp = true}
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local downloadKeyList = {meshAssetPath, airdropClassPath}
  local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, downloadKeyList)
  if downloadState == PufferConst.ENUM_DownloadState.Done then
    AirDropMesh.CreateBox()
  else
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, downloadKeyList, PufferTlog.Enum_TLog_From.Auto, AirDropMesh.CreateBox, extraData)
  end
end
local ResourceExists = false
function AirDropMesh.CreateBox()
  log(bWriteLog and "AirDropMesh.CreateBox.")
  if not AirDropMesh._BoxShow then
    log(bWriteLog and string.format("AirDropMesh.CreateBox. BoxShow:%s", AirDropMesh._BoxShow))
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "AirDropMesh.CreateBox. is not in lobby or main city!")
    return
  end
  if not ResourceExists then
    local airdropClassPath = LuckAirDropSystem.GetAirDropClassPath()
    local meshAssetPath = LuckAirDropSystem.GetMeshAssetPath()
    local pak_util = require("client.common.pak_util")
    local airDropExists = pak_util.IsFileExist(airdropClassPath)
    local meshExists = pak_util.IsFileExist(meshAssetPath)
    ResourceExists = airDropExists and meshExists
    if not ResourceExists then
      log(bWriteLog and string.format("AirDropMesh.CreateBox. airDropExists:%s, meshExists:%s", tostring(airDropExists), tostring(meshExists)))
      return
    end
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local mesh = LuckAirDropSystem.GetAirDropClassPath()
  local utility = require("common.utility")
  local _, tclass = xpcall(slua.loadClass, utility.ErrorMessageHandler, mesh)
  log(bWriteLog and "mesh111 " .. mesh)
  if tclass then
    local location, rotation, scale = LuckAirDropSystem.GetBoxTransform()
    AirDropMesh._cur_AirdropBox = world:SpawnActor(tclass, location, nil, nil)
    AirDropMesh._cur_AirdropBox:K2_SetActorRotation(rotation, false)
    AirDropMesh._cur_AirdropBox:SetActorScale3D(scale)
    AirDropMesh._cur_AirdropBox.Tags:Add("LobbyLuckyAirDrop")
    AirDropMesh.UpdateBoxMesh()
    AirDropMesh.CheckNeedChangeSmoke()
    AirDropMesh.CreateClock()
    log_tree("AirDropMesh._cur_AirdropBox ", AirDropMesh._cur_AirdropBox)
  end
end
function AirDropMesh.UpdateBoxMesh()
  log(bWriteLog and "UpdateBoxMesh")
  if AirDropMesh._cur_AirdropBox == nil then
    return
  end
  local meshAssetPath = LuckAirDropSystem.GetMeshAssetPath()
  local asset_util = require("common.asset_util")
  local boxMesh = asset_util.GetAssetSync(meshAssetPath)
  AirDropMesh._cur_AirdropBox.StaticMesh:SetStaticMesh(boxMesh)
end
function AirDropMesh.CreateClock()
  log(bWriteLog and "  : AirDropMesh.CreateClock")
  if NClockHandle then
    AirDropMesh.ClearClock()
  end
  if LuckAirDropSystem.AirDropType == 1 then
    NClockHandle = clock.Init(AirDropMesh._endTime, nil, AirDropMesh.Clear)
  else
    local last_luck_time = LuckAirDropSystem.LuckAirData.last_luck_time
    local durationSec = LuckAirDropSystem.LuckAirData.duration
    NClockHandle = clock.Init(last_luck_time + durationSec, nil, AirDropMesh.Clear)
  end
end
function AirDropMesh.ChangeSkin()
  log(bWriteLog and "[ : ChangeSkin")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if not LogicTxMissionMain.IsInXMission(false) and not UIManager.IsUIShow(UIManager.UI_Config.wardrobe) and not HallThemeUtils.IsThemePreviewStatus() then
    AirDropMesh.Clear()
    AirDropMesh.Create()
  end
end
function AirDropMesh.CheckNeedChangeSmoke(bForceUpdate)
  local leftTime = LuckAirDropSystem.GetLeftTime()
  local quality = LuckAirDropSystem.GetQuality()
  if AirDropMesh._cur_AirdropBox == nil or not slua.isValid(AirDropMesh._cur_AirdropBox) then
    return
  end
  if LuckAirDropSystem.AirDropType == 1 then
    local asset_util = require("common.asset_util")
    local particle = asset_util.GetAssetSync("/Game/Arts_Effect/ParticleSystems/Share/P_AirDrop_TechRed03.P_AirDrop_TechRed03")
    if particle and slua.isValid(particle) then
      log(bWriteLog and "AirDropMesh.CheckNeedChangeSmoke Success")
      AirDropMesh._cur_AirdropBox.Smoke:SetTemplate(nil)
      AirDropMesh._cur_AirdropBox.Smoke:SetTemplate(particle)
      AirDropMesh._cur_AirdropBox.Smoke:SetVisibility(true, false)
    else
      AirDropMesh._cur_AirdropBox.Smoke:SetVisibility(false, false)
    end
    return
  end
  local smokeIndex = 0
  local path = ""
  local table = CDataTable.GetTableByFilter("LuckDropEffect", "Quality", quality)
  for _, j in pairs(table) do
    local StringUtil = require("common.string_util")
    local time = StringUtil.Split(j.LeftTime, ";")
    if leftTime > tonumber(time[1]) * 60 and leftTime <= tonumber(time[2]) * 60 then
      smokeIndex = j.Index
      path = j.EffectPath
      break
    end
  end
  if smokeIndex ~= AirDropMesh._lastSmokeIndex or bForceUpdate then
    log(bWriteLog and "AirDropMesh.CheckNeedChangeSmoke From " .. tostring(AirDropMesh._lastSmokeIndex) .. " changeTo Index = " .. tostring(smokeIndex) .. " leftTime = " .. tostring(leftTime))
    AirDropMesh._lastSmokeIndex = smokeIndex
    local asset_util = require("common.asset_util")
    local particle = asset_util.GetAssetSync(path)
    if particle and slua.isValid(particle) then
      log(bWriteLog and "AirDropMesh.CheckNeedChangeSmoke Success")
      AirDropMesh._cur_AirdropBox.Smoke:SetTemplate(nil)
      AirDropMesh._cur_AirdropBox.Smoke:SetTemplate(particle)
      AirDropMesh._cur_AirdropBox.Smoke:SetVisibility(true, true)
    else
      AirDropMesh._cur_AirdropBox.Smoke:SetVisibility(false, false)
    end
  end
end
function AirDropMesh.ShowOrHide(bShow)
  log(bWriteLog and string.format("AirDropMesh.ShowOrHide. bShow=%s", tostring(bShow)))
  AirDropMesh._BoxShow = bShow
  if bShow and AirDropMesh._cur_AirdropBox == nil then
    AirDropMesh.Create()
    return
  end
  if slua.isValid(AirDropMesh._cur_AirdropBox) then
    AirDropMesh._cur_AirdropBox:SetActorHiddenInGame(not bShow)
    AirDropMesh._cur_AirdropBox:SetCantClick(not bShow)
  end
end
function AirDropMesh.ShowBox()
  log(bWriteLog and "[ : AirDropMesh.ShowBox")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    AirDropMesh.ShowOrHide(true)
    AirDropMesh.CheckNeedChangeSmoke(true)
  end
end
function AirDropMesh.HideBox()
  AirDropMesh.ShowOrHide(false)
end
function AirDropMesh.Clear()
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, AirDropMesh.HideBox)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, AirDropMesh.ShowBox)
  EventSystem:unregistEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, AirDropMesh.HideBox)
  EventSystem:unregistEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_LOBBY, AirDropMesh.ShowBox)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_PREVIEW, AirDropMesh.HideBox)
  AirDropMesh.ClearStatusCache()
  AirDropMesh.ClearClock()
  AirDropMesh._init = false
end
function AirDropMesh.ClearStatusCache()
  if AirDropMesh._cur_AirdropBox and slua.isValid(AirDropMesh._cur_AirdropBox) then
    AirDropMesh._cur_AirdropBox:K2_DestroyActor()
    AirDropMesh._cur_AirdropBox = nil
    AirDropMesh._lastSmokeIndex = 0
  end
  AirDropMesh._BoxShow = true
end
function AirDropMesh.ClearClock()
  log(bWriteLog and "  : AirDropMesh.ClearClock")
  if NClockHandle then
    clock.Release(NClockHandle)
    NClockHandle = nil
  end
end
function AirDropMesh.GetAirBox()
  return AirDropMesh._cur_AirdropBox
end
function AirDropMesh.IsInit()
  return AirDropMesh._init
end
return AirDropMesh