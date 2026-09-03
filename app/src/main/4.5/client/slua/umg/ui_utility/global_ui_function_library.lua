local global_ui_function_library = {}
function global_ui_function_library:IsEnglish(char)
  local StringUtil = require("common.string_util")
  local byte = string.byte(char, 1)
  return StringUtil.IsEnglish(byte)
end
function global_ui_function_library:UpdateLobbyRedpointStatus(isShow, modeId, worldContext)
end
function global_ui_function_library:GetNationSwitch(name, worldContext)
  local nationSwitch = false
  EventFetchNationSwitch()
  if BP_STRUCT_NATION_SWITCH.Updated then
    if name == "All" then
      nationSwitch = BP_STRUCT_NATION_SWITCH.NationAllSwitch
    elseif name == "Rank" then
      nationSwitch = BP_STRUCT_NATION_SWITCH.NationRankSwitch
    elseif name == "Battle" then
      nationSwitch = BP_STRUCT_NATION_SWITCH.NationBattleSwitch
    end
  else
    local key = "Nation" .. tostring(name) .. "Switch"
    local cfg = CDataTable.GetTableData("SystemConfig", key)
    if cfg ~= nil then
      nationSwitch = cfg.ConfigValue == "1"
    else
      log(bWriteLog and "global_ui_function_library:GetNationSwitch, cfg = nil while key = " .. tostring(key))
    end
  end
  log(bWriteLog and "global_ui_function_library:GetNationSwitch, name = " .. tostring(name) .. ", nationSwitch = " .. tostring(nationSwitch))
  return nationSwitch
end
function global_ui_function_library:SetAndroidKeyIsValid(bValid, worldContext)
  BP_Global_AndroidKey_IsValid = bValid
end
function global_ui_function_library:ProcessAndroidBack()
  if not BP_Global_AndroidKey_IsValid then
    log(bWriteLog and "EventLobbyAndroidBack: AndroidKey Is Not Valid")
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK)
end
function global_ui_function_library:GetGlobalLuaUI(worldContext)
  local uiRoot = FuncUtil.GetLuaGlobalUI()
  log(bWriteLog and "global_ui_function_library:GetGlobalLuaUI, uiRoot = " .. tostring(uiRoot))
  return uiRoot
end
function global_ui_function_library:GetItemTimeS(resId, validHour, worldContext)
  local result = ""
  local haveLimit = false
  if validHour and 0 < validHour then
    local strTemp = FuncUtil.TimeNumToTimeS(validHour)
    result = LocUtil.GetLocalizeResStr(301299) .. strTemp
    haveLimit = true
  else
    local item = CDataTable.GetTableData("Item", resId)
    if item and item.ExTime then
      if string.len(item.ExTime) > 1 then
        result = LocUtil.LocalizeResFormat(19217, item.ExTime)
        haveLimit = true
      else
        local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
        local bIsExistTime, nHourTime = CommonItem_Utils.SpecialCheckIsValidTimeItem(resId)
        if bIsExistTime then
          local sTempStr = FuncUtil.TimeNumToTimeS(nHourTime)
          result = LocUtil.GetLocalizeResStr(301299) .. sTempStr
          haveLimit = true
        end
      end
    else
      log(bWriteLog and "global_ui_function_library:GetItemTimeS, item = nil")
    end
  end
  return result, haveLimit
end
function global_ui_function_library:GetCurrentCamera(worldContext)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  return Lobby_camera_manager_module:GetCurrentCamera()
end
function global_ui_function_library:GetLobbyGlobalBp(worldContext)
  local globalBP
  local GameplayStatics = import("GameplayStatics")
  local gameInstance = GameplayStatics.GetGameInstance(worldContext)
  if gameInstance ~= nil then
    local frontendHUD = gameInstance:GetAssociatedFrontendHUD()
    local logicManager = frontendHUD:GetLogicManagerByName("bp_global")
    if logicManager ~= nil then
      globalBP = logicManager:GetWidget(0)
    else
      log(bWriteLog and "global_ui_function_library:GetLobbyGlobalBp, logicManager = nil")
    end
  else
    log(bWriteLog and "global_ui_function_library:GetLobbyGlobalBp, gameInstance = nil")
  end
  log(bWriteLog and "global_ui_function_library:GetLobbyGlobalBp, globalBP = " .. tostring(globalBP))
  return globalBP
end
function global_ui_function_library:GetQualityPath(quality)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetQualityPath(quality)
end
function global_ui_function_library:GetBgQualityPath(quality)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetBgQualityPath(quality)
end
function global_ui_function_library:GetXieQualityPath(quality)
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetXieQualityPath(quality)
end
function global_ui_function_library:GetBgQualityPathWithLight(quality)
  local path = ""
  if quality >= MIN_QUALITY then
    path = string.format("/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_0%d_light_png.T_icon_shop_0%d_light_png", quality, quality)
  end
  return path
end
function global_ui_function_library:SetSpecialIconWithSprite2DMatchSize(widget, specialIconPath)
  if specialIconPath and specialIconPath ~= "" then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local util = require("client.slua_ui_framework.util")
    local params = {sync = true, bMatchSize = true}
    util.SetTexture(widget, specialIconPath, params)
  else
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function global_ui_function_library:ShowItemTipsByButton(nItemId, node_btn, nValidHours, bIsShowCloseBtn)
  local logic_itemTipPanel = require("client.slua.logic.common.logic_itemTipPanel")
  logic_itemTipPanel.ShowItemTips(nItemId, node_btn, {nValidHours = nValidHours, bIsShowCloseBtn = bIsShowCloseBtn})
end
function global_ui_function_library:GetImagePixelSize(sPath)
  local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
  local uObj_textureOrSprite = LogicLoadTexture.LoadTextureOrSprite(sPath)
  if not uObj_textureOrSprite or not slua.isValid(uObj_textureOrSprite) then
    log(bWriteLog and " global_ui_function_library:GetImagePixelSize, uObj_textureOrSprite = nil, sPath = " .. sPath)
    return 0, 0
  end
  local Texture2D = import("/Script/Engine.Texture2D")
  local PaperSprite = import("PaperSprite")
  local BusinessHelper = import("BusinessHelper")
  local nWidth, nHeight = 0, 0
  if BusinessHelper.IsClassOf(uObj_textureOrSprite, PaperSprite) then
    nWidth, nHeight = uObj_textureOrSprite.SourceDimension.X, uObj_textureOrSprite.SourceDimension.Y
  elseif BusinessHelper.IsClassOf(uObj_textureOrSprite, Texture2D) then
    nWidth, nHeight = uObj_textureOrSprite:Blueprint_GetSizeX(), uObj_textureOrSprite:Blueprint_GetSizeY()
  end
  return nWidth, nHeight
end
function global_ui_function_library:PlaySoundClickButton()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioAsyncAtLocation("/Game/WwiseEvent/UI_hall/UI_100/Play_UI_Hall_Click_1.Play_UI_Hall_Click_1", FVector(0, 0, 0), FRotator(0, 0, 0))
end
local class = require("class")
local object = require("object")
local Class = class(object, nil, global_ui_function_library)
return Class