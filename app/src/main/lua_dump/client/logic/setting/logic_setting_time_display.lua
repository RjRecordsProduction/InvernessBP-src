local SettingTimeDisplay = {
  dateFormat = "YYYY/MM/DD",
  dateSeparator = "/",
  selectedFormatID = "1",
  selectedSeparatorID = "1",
  allDateFormatList = {
    "YYYY/MM/DD",
    "DD/MM/YY",
    "MM/DD/YY",
    "DD/MM/YYYY",
    "MM/DD/YYYY"
  },
  allDateSeparatorList = {
    "/",
    "-",
    "."
  }
}
local ELanguageToFormat = {
  ar = {formatID = 1, separatorID = 3},
  de = {formatID = 4, separatorID = 3},
  en = {formatID = 1, separatorID = 1},
  es = {formatID = 4, separatorID = 1},
  fr = {formatID = 4, separatorID = 1},
  id = {formatID = 4, separatorID = 1},
  ja = {formatID = 1, separatorID = 1},
  ko = {formatID = 1, separatorID = 1},
  ms = {formatID = 4, separatorID = 1},
  pt = {formatID = 4, separatorID = 1},
  ru = {formatID = 4, separatorID = 3},
  th = {formatID = 4, separatorID = 1},
  tr = {formatID = 4, separatorID = 1},
  vi = {formatID = 4, separatorID = 1},
  zh = {formatID = 1, separatorID = 1},
  HK = {formatID = 4, separatorID = 1},
  TW = {formatID = 1, separatorID = 1}
}
function SettingTimeDisplay.GetTimeConfig(IDConfig)
  local dateSeparator = SettingTimeDisplay.allDateSeparatorList[IDConfig.separatorID]
  local dateFormat = SettingTimeDisplay.allDateFormatList[IDConfig.formatID]
  dateFormat = string.gsub(dateFormat, "/", dateSeparator)
  local timeDisplayTb = {}
  timeDisplayTb.  timeDisplayTb.  timeDisplayTb.selectedFormatID = tostring(IDConfig.formatID)
  timeDisplayTb.selectedSeparatorID = tostring(IDConfig.separatorID)
  return timeDisplayTb
end
function SettingTimeDisplay.SaveTimeDisplay()
  local TimeDisplayTb = {}
  TimeDisplayTb.dateFormat = SettingTimeDisplay.dateFormat
  TimeDisplayTb.dateSeparator = SettingTimeDisplay.dateSeparator
  TimeDisplayTb.selectedFormatID = SettingTimeDisplay.selectedFormatID
  TimeDisplayTb.selectedSeparatorID = SettingTimeDisplay.selectedSeparatorID
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(TimeDisplayTb, PlayerPrefsSystem.ePlayerPrefsType.eTimeDisplayFormat)
end
function SettingTimeDisplay.LoadTimeDisplay()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeDisplay = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTimeDisplayFormat)
  if TimeDisplay and TimeDisplay.dateFormat then
    SettingTimeDisplay.dateFormat = TimeDisplay.dateFormat
    SettingTimeDisplay.dateSeparator = TimeDisplay.dateSeparator
    SettingTimeDisplay.selectedFormatID = TimeDisplay.selectedFormatID
    SettingTimeDisplay.selectedSeparatorID = TimeDisplay.selectedSeparatorID
  else
    local lang = Client.GetCurrentLanguage()
    log(bWriteLog and "[leomzhou] SettingTimeDisplay.LoadTimeDisplay timeDisplayFormat not found lang = " .. tostring(lang))
    local IDConfig = ELanguageToFormat[lang]
    if IDConfig then
      local timeDisplayTb = SettingTimeDisplay.GetTimeConfig(IDConfig)
      SettingTimeDisplay.dateFormat = timeDisplayTb.dateFormat
      SettingTimeDisplay.dateSeparator = timeDisplayTb.dateSeparator
      SettingTimeDisplay.selectedFormatID = timeDisplayTb.selectedFormatID
      SettingTimeDisplay.selectedSeparatorID = timeDisplayTb.selectedSeparatorID
      SettingTimeDisplay.SaveTimeDisplay()
    else
      log(bWriteLog and "[leomzhou] SettingTimeDisplay.LoadTimeDisplay timeDisplayFormat not IDConfig")
    end
  end
end
return SettingTimeDisplay