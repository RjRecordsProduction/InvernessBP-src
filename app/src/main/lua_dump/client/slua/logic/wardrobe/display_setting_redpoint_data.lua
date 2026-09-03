local display_setting_redpoint_data = {}
local redpoint
local isInited = false
display_setting_redpoint_data.Enum_CheckedType = {FightHelmet = 1, EnterPlayVoice = 2}
function display_setting_redpoint_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local super_data = require("common.super_data")
  if redpoint == nil then
    redpoint = super_data.CreateSuperData({checkedFightHelmet = false, checkedEnterPlayVoice = false})
  end
  display_setting_redpoint_data.ReadChecked()
end
function display_setting_redpoint_data.OnLogout()
  redpoint = nil
  isInited = false
end
function display_setting_redpoint_data.GetData()
  display_setting_redpoint_data.InitData()
  return redpoint
end
function display_setting_redpoint_data.SetChecked(checkedType)
  if not redpoint then
    return
  end
  if checkedType == display_setting_redpoint_data.Enum_CheckedType.FightHelmet then
    if redpoint.checkedFightHelmet then
      return
    end
    redpoint.checkedFightHelmet = true
  elseif checkedType == display_setting_redpoint_data.Enum_CheckedType.EnterPlayVoice then
    if redpoint.checkedEnterPlayVoice then
      return
    end
    redpoint.checkedEnterPlayVoice = true
  end
  display_setting_redpoint_data.WriteChecked(checkedType)
end
function display_setting_redpoint_data.ReadChecked()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  for _, v in pairs(display_setting_redpoint_data.Enum_CheckedType) do
    local fileType
    if v == display_setting_redpoint_data.Enum_CheckedType.FightHelmet then
      fileType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeFightHelmetSetting
    elseif v == display_setting_redpoint_data.Enum_CheckedType.EnterPlayVoice then
      fileType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeEnterPlayVoiceSetting
    end
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
    local checked
    if saveData == nil or saveData.checked == nil then
      checked = false
    else
      checked = saveData.checked
    end
    if v == display_setting_redpoint_data.Enum_CheckedType.FightHelmet then
      redpoint.checkedFightHelmet = checked
    elseif v == display_setting_redpoint_data.Enum_CheckedType.EnterPlayVoice then
      redpoint.checkedEnterPlayVoice = checked
    end
  end
end
function display_setting_redpoint_data.WriteChecked(checkedType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType
  if checkedType == display_setting_redpoint_data.Enum_CheckedType.FightHelmet then
    fileType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeFightHelmetSetting
  elseif checkedType == display_setting_redpoint_data.Enum_CheckedType.EnterPlayVoice then
    fileType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeEnterPlayVoiceSetting
  end
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData.checked = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
return display_setting_redpoint_data