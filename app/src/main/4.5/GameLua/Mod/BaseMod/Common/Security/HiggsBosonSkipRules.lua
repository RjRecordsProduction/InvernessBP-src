local HiggsBosonSkipRules = {}
HiggsBosonSkipRules.Rules = {
  {
    sName = "CreativeSpeedStrategy",
    tKeywords = {
      "ModeID=880000",
      "SpeedStrategy"
    }
  },
  {
    sName = "CreativeSpeedStrategy1",
    tKeywords = {
      "ModeID=600074",
      "SpeedStrategy"
    }
  },
  {
    sName = "teamupStrategy",
    tKeywords = {
      "StrategyID: 8758"
    }
  },
  {
    sName = "teamupcheck1",
    tKeywords = {"TeamUp"}
  },
  {
    sName = "teamupcheck2",
    tKeywords = {
      "OneSideHasWeaponOnFoot"
    }
  },
  {
    sName = "TeammateStrategy1",
    tKeywords = {
      "TeammateRescue"
    }
  },
  {
    sName = "TeammateStrategy2",
    tKeywords = {
      "TeammateRecall"
    }
  },
  {
    sName = "ESPStrategy",
    tKeywords = {
      "EspBattleInvisibleCnt"
    }
  },
  {
    sName = "CharMoveStrategy",
    tKeywords = {
      "CharMoveAccum"
    }
  }
}
function HiggsBosonSkipRules.IsMessageMatched(sMessage)
  if type(sMessage) ~= "string" or sMessage == "" then
    return false, nil
  end
  for _, tRule in ipairs(HiggsBosonSkipRules.Rules) do
    local tKeywords = tRule.tKeywords
    if type(tKeywords) == "table" and 0 < #tKeywords then
      local bAllMatch = true
      for _, sKeyword in ipairs(tKeywords) do
        if type(sKeyword) ~= "string" or sKeyword == "" or not string.find(sMessage, sKeyword, 1, true) then
          bAllMatch = false
          break
        end
      end
      if bAllMatch then
        return true, tRule.sName or ""
      end
    end
  end
  return false, nil
end
return HiggsBosonSkipRules