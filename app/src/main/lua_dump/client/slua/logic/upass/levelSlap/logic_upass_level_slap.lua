local logic_upass_level_slap = {
  ESlapRewardType = {UC = 1, Item = 2},
  bIsNeedShowSlapLevel = false
}
local levelSlapCfg = {
  [37] = {
    type = 1,
    price = 360,
    bFullBack = false
  },
  [43] = {
    type = 1,
    price = 360,
    bFullBack = false
  },
  [47] = {
    type = 1,
    price = 360,
    bFullBack = true
  },
  [50] = {
    type = 2,
    price = 720,
    bWeapon = true
  },
  [87] = {
    type = 1,
    price = 720,
    bFullBack = false
  },
  [93] = {
    type = 1,
    price = 720,
    bFullBack = false
  },
  [97] = {
    type = 1,
    price = 720,
    bFullBack = true
  },
  [100] = {
    type = 2,
    price = 720,
    bSuit = true
  }
}
function logic_upass_level_slap.GetTriggerSlapLevel()
  if not UnknowPassSystem.BuyBeforeLevel then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassLevelSlap) or {}
    if saveData[UnknowPassSystem.Season] then
      for level = UnknowPassSystem.Level, 1, -1 do
        if levelSlapCfg[level] then
          if not saveData[UnknowPassSystem.Season][level] then
            return level
          else
            break
          end
        end
      end
    end
  else
    for level = UnknowPassSystem.Level, UnknowPassSystem.BuyBeforeLevel + 1, -1 do
      if levelSlapCfg[level] then
        return level
      end
    end
  end
  return UnknowPassSystem.Level
end
function logic_upass_level_slap.ShouldSlap()
  log(bWriteLog and "[logic_upass_level_slap] check ShouldSlap: " .. tostring(UnknowPassSystem.Level))
  if not UnknowPassSystem.IsInCurSession then
    log(bWriteLog and "[logic_upass_level_slap] pass not in session")
    return false
  end
  local triggerLevel = logic_upass_level_slap.GetTriggerSlapLevel()
  if not triggerLevel or not levelSlapCfg[triggerLevel] then
    log(bWriteLog and "[logic_upass_level_slap] invalid level cfg: " .. tostring(triggerLevel))
    return false
  end
  if UnknowPassSystem.IsBuyElite and triggerLevel <= 50 then
    log(bWriteLog and "[logic_upass_level_slap] already buy 50 elite")
    return false
  end
  if UnknowPassSystem.IsBuyEliteSeg2 then
    log(bWriteLog and "[logic_upass_level_slap] already buy seg 2")
    return false
  end
  if GameStatus.IsInFightingStatus() then
    log(bWriteLog and "[logic_upass_level_slap] in fight state")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassLevelSlap) or {}
  if saveData[UnknowPassSystem.Season] and saveData[UnknowPassSystem.Season][triggerLevel] then
    log(bWriteLog and "[logic_upass_level_slap] save data already exist")
    return false
  end
  return true
end
function logic_upass_level_slap.ShowLevelSlap()
  log(bWriteLog and "[logic_upass_level_slap] ShowLevelSlap: " .. tostring(UnknowPassSystem.Level))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= PufferConst.ENUM_DownloadState.Done then
    return false
  end
  if not logic_upass_level_slap.bIsNeedShowSlapLevel then
    log(bWriteLog and "[logic_upass_level_slap.bIsNeedShowSlapLevel >>> " .. tostring(logic_upass_level_slap.bIsNeedShowSlapLevel))
    return false
  end
  local triggerLevel = logic_upass_level_slap.GetTriggerSlapLevel()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassLevelSlap) or {}
  saveData[UnknowPassSystem.Season] = saveData[UnknowPassSystem.Season] or {}
  saveData[UnknowPassSystem.Season][triggerLevel] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassLevelSlap)
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Popup_Theme_PushBuy_UIBP)
  return true
end
function logic_upass_level_slap.GetSlapCfg(level)
  return levelSlapCfg[level]
end
function logic_upass_level_slap.SetIsShowSlapLevel(bIsShow)
  bIsShow = bIsShow and logic_upass_level_slap.ShouldSlap()
  logic_upass_level_slap.bIsNeedShowSlapLevel = bIsShow
end
return logic_upass_level_slap