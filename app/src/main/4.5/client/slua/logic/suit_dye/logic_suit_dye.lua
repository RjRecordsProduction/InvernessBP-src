local KismetMathLibrary = import("KismetMathLibrary")
local suit_dye_macros = require("client.slua.logic.suit_dye.suit_dye_macros")
local COLOR_KEY_FORMAT = "PartColor%d_a"
local PART_COUNT = 6
local INVALID_SEASON = 9999
local logic_suit_dye = {}
local EnterSuitDyeSources = {
  FullReward = 0,
  WardRobe = 1,
  Shop = 2,
  RPMainPanel = 3,
  AwardPreview = 4
}
function logic_suit_dye:DefineAndResetData()
  self.Data = {}
  self.ExtraData = {}
  self.myDetailData = {}
  self._defaultColor = FLinearColor(1.0, 1.0, 1.0, 0.0)
  self:InitCfg()
  self._periodListNeedRequestAgain = {}
end
function logic_suit_dye:InitCfg()
  if not self.bInited then
    local startTime = slua.getMiliseconds()
    self.bInited = true
    local StringUtil = require("common.string_util")
    self.periodCfg = {}
    local periodCfg = self.periodCfg
    self.suitId2PeriodMap = {}
    local suitId2PeriodMap = self.suitId2PeriodMap
    self.period2MaxLevelMap = {}
    local period2MaxLevelMap = self.period2MaxLevelMap
    self.periodPartCfg = {}
    local suitPartParamCfg = {}
    for k, v in pairs(CDataTable.GetTable("SuitDyePartParam")) do
      local id = v.ID
      suitPartParamCfg[id] = {
        id = id,
        avatarSlotId = v.AvatarSlotID,
        matSlotId = v.MatSlotId,
        paramName = v.ParamName,
        switchParamName = v.SwitchParamName,
        highLightParamName = v.HighLightParamName,
        closeMaskParamName = v.CloseMaskParamName
      }
    end
    for k, v in pairs(CDataTable.GetTable("SuitDyePart")) do
      local id = v.ID
      local changeCostCfg = StringUtil.Split(v.ChangeCost, ";")
      local changeCoinType = tonumber(changeCostCfg[1]) or 0
      local changeCost = tonumber(changeCostCfg[2]) or 0
      local period = v.Period
      local partNo = v.PartNo
      if not self.periodPartCfg[period] then
        self.periodPartCfg[period] = {}
      end
      if not self.periodPartCfg[period][partNo] then
        self.periodPartCfg[period][partNo] = {
          id = id,
          period = period,
          partNo = partNo,
          partName = v.PartName,
          changeCoinType = changeCoinType,
          changeCost = changeCost,
          partParamList = {},
          bTurnAround = v.bTurnAround
        }
        local partParamList = self.periodPartCfg[period][partNo].partParamList
        local partParamIdList = StringUtil.Split(v.PartParamIDs, "|")
        for _, paramIdStr in ipairs(partParamIdList) do
          local paramId = tonumber(paramIdStr)
          if paramId and suitPartParamCfg[paramId] then
            table.insert(partParamList, suitPartParamCfg[paramId])
          end
        end
      end
    end
    self.planCfg = {}
    for k, v in pairs(CDataTable.GetTable("SuitDyePlan")) do
      local id = v.ID
      local planType = v.PlanType
      local period = v.Period
      local item = {
        id = id,
        period = v.Period,
        planNo = v.PlanNo,
        planType = planType,
        colorList = {},
        extraParamIDList = v.ExtraParamID_a
      }
      if not self.planCfg[period] then
        self.planCfg[period] = {}
      end
      table.insert(self.planCfg[period], item)
      if planType ~= 0 then
        local colorList = item.colorList
        for i = 1, PART_COUNT do
          local key = string.format(COLOR_KEY_FORMAT, i)
          local color = v[key]
          if color:Num() >= 3 then
            colorList[i] = {
              H = color:Get(0),
              S = color:Get(1),
              B = color:Get(2)
            }
          else
            log_error(string.format("table: SuitDyePlan, preset color for plan:%s is error", tostring(item.id)))
          end
        end
      end
    end
    local planSortFunc = function(a, b)
      return a.planNo < b.planNo
    end
    for _, planList in pairs(self.planCfg) do
      table.sort(planList, planSortFunc)
    end
    self.minOpenSeason = nil
    self.periodOpenSeason = {}
    for k, v in pairs(CDataTable.GetTable("SuitDyeCfg")) do
      local suitId = v.SuitID
      local level = v.Level
      if suitId ~= 0 and level ~= 0 then
        local period = v.Period
        suitId2PeriodMap[suitId] = period
        if not periodCfg[period] then
          periodCfg[period] = {}
        end
        if not period2MaxLevelMap[period] or level > period2MaxLevelMap[period] then
          period2MaxLevelMap[period] = level
        end
        local upgradeCostCfg = StringUtil.Split(v.UpgradeCost, ";")
        local upgradeCoinType = tonumber(upgradeCostCfg[1]) or 0
        local upgradeCost = tonumber(upgradeCostCfg[2]) or 0
        local openSeason = v.OpenSeason
        if not self.minOpenSeason or openSeason < self.minOpenSeason then
          self.minOpenSeason = openSeason
        end
        if not self.periodOpenSeason[period] then
          self.periodOpenSeason[period] = openSeason
        end
        periodCfg[period][level] = {
          period = period,
          suitId = suitId,
          level = level,
          planIdList = StringUtil.Split(v.PlanIDs, "|"),
          upgradeCoinType = upgradeCoinType,
          upgradeCost = upgradeCost,
                  }
      end
    end
    local minBrightnessLimitCfg = CDataTable.GetTableData("SuitDyeGlobalParam", "MinBrightnessLimit")
    self.MinBrightnessLimit = 0 <= minBrightnessLimitCfg.NumValue and minBrightnessLimitCfg.NumValue or 0
    local endTime = slua.getMiliseconds()
    log(bWriteLog and "logic_suit_dye:InitCfg cost: " .. tostring(endTime - startTime) .. "ms")
  end
end
function logic_suit_dye:ctor()
  self.bInited = false
end
function logic_suit_dye:OnInitialize()
  logic_suit_dye.__super.OnInitialize(self)
  self:InitCfg()
end
function logic_suit_dye:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_BATTLEPROFILE, EVENTID_BATTLEPROFILE_BATCHGET_RES, self.OnBattleProfileBatchGet, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SUIT_DIY, self.OnJumpFromUrl, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, self.OnUnknowPassInfoUpdate, self)
end
function logic_suit_dye:OnLogOut()
  self.Data = {}
  self.ExtraData = {}
  self._periodListNeedRequestAgain = {}
end
function logic_suit_dye:GetSourcesAllType()
  return EnterSuitDyeSources
end
function logic_suit_dye:EnterSuitDyeBySuitId(suitId, source)
  local period = self:GetPeriodBySuitId(suitId)
  period = period ~= 0 and period or self:GetDefaultSuitPeriod()
  self:EnterSuitDye(period, source)
end
function logic_suit_dye:EnterSuitDye(period, source)
  source = source or 0
  period = period or self:GetDefaultSuitPeriod()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SuitDyeEnterSource, source)
  UIManager.ShowUI(UIManager.UI_Config.suit_dye_main, period)
end
function logic_suit_dye:GetDyeSuitPeriodList()
  return self.periodCfg
end
function logic_suit_dye:GetDyeSuitLevels(period)
  if not period then
    return nil
  end
  return self.periodCfg and self.periodCfg[period]
end
function logic_suit_dye:GetDyeSuitLevelCfg(period, level)
  if not period then
    return nil
  end
  if not level then
    return nil
  end
  return self.periodCfg and self.periodCfg[period] and self.periodCfg[period][level]
end
function logic_suit_dye:GetDyeSuitPlans(period)
  return period and self.planCfg and self.planCfg[period]
end
function logic_suit_dye:GetSuitPlanCfg(period, planNo)
  if not (planNo and period) or not self.planCfg[period] then
    return nil
  end
  local planList = self.planCfg[period]
  for k, v in pairs(planList) do
    if v.planNo == planNo then
      return v
    end
  end
  return nil
end
function logic_suit_dye:GetDyeSuitPlanColorAndType(period, planNo)
  if not period or not planNo then
    return nil, nil
  end
  if not (self.planCfg and self.planCfg[period]) or not self.planCfg[period] then
    return nil, nil
  end
  for i, v in pairs(self.planCfg[period]) do
    if v.planNo == planNo then
      return v.colorList, v.planType
    end
  end
  return nil, nil
end
function logic_suit_dye:IsDyeSuit(suitId)
  if not suitId then
    return false
  end
  local period = self:GetPeriodBySuitId(suitId)
  return period ~= 0
end
function logic_suit_dye:GetOwnedSuitLevel(period)
  if not period then
    return 0
  end
  local maxLevel = self:GetMaxSuitLevel(period)
  if not maxLevel then
    return 0
  end
  local periodCfg = self.periodCfg[period]
  if not periodCfg then
    return 0
  end
  local level = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for currentLevel = maxLevel, 1, -1 do
    local itemId = periodCfg[currentLevel].suitId
    local count = wardrobe_data:GetHallDepotItemCountByResID(itemId)
    if 0 < count then
      level = currentLevel
      break
    end
  end
  return level
end
function logic_suit_dye:GetMaxSuitLevel(period)
  if not period then
    return 0
  end
  return self.period2MaxLevelMap[period] or 0
end
function logic_suit_dye:GetSuitIdByPeriodLevel(period, level)
  if not period or not level then
    return
  end
  if not self.periodCfg then
    return nil
  end
  local periodCfg = self.periodCfg
  return periodCfg[period] and periodCfg[period][level] and periodCfg[period][level].suitId
end
function logic_suit_dye:GetAllSuitIdsOfGivenPeriod(period)
  local ret = {}
  if not period then
    return ret
  end
  if not self.periodCfg then
    return ret
  end
  local periodCfg = self.periodCfg
  if periodCfg[period] then
    for k, v in pairs(periodCfg[period]) do
      table.insert(ret, v.suitId)
    end
  end
  return ret
end
function logic_suit_dye:GetSuitColor(period)
  local myDetailData = self:GetMyDetailPlanData(period)
  return myDetailData and myDetailData.plans and myDetailData.plans[0] or {}
end
function logic_suit_dye:GetInt32Format(color)
  if not color then
    return color
  end
end
function logic_suit_dye:IsTwoColorEqual(colorA, colorB)
  if colorA == nil and colorB == nil then
    return true
  end
  local intColorA = colorA
  if type(colorA) == "table" then
    intColorA = self:HSBToInteger(colorA.H, colorA.S, colorA.B)
  end
  local intColorB = colorB
  if type(colorB) == "table" then
    intColorB = self:HSBToInteger(colorB.H, colorB.S, colorB.B)
  end
  return intColorA == intColorB
end
function logic_suit_dye:GetCurrentDyePrice(period, planNo, colorList)
  if not period then
    return 0, nil, 0
  end
  local planCfg = self:GetSuitPlanCfg(period, planNo)
  if not planCfg then
    return 0, nil, 0
  end
  if planCfg.planType ~= 0 then
    return 0, nil, 0
  end
  if not colorList then
    return 0, nil, 0
  end
  local cost = 0
  local changeCount = 0
  local currentPartCfg = self.periodPartCfg and self.periodPartCfg[period]
  if not currentPartCfg or not next(currentPartCfg) then
    return 0, nil, 0
  end
  local coinType = currentPartCfg[1].changeCoinType or 0
  local ownedLevel = self:GetOwnedSuitLevel(period)
  local currentColorList = self:GetSuitColor(period)
  for i = 1, PART_COUNT do
    local requireLevel = self:PartIdToLevel(i)
    if ownedLevel >= requireLevel and not self:IsTwoColorEqual(currentColorList[i], colorList[i]) then
      cost = cost + (currentPartCfg[i] and currentPartCfg[i].changeCost or 0)
      changeCount = changeCount + 1
    end
  end
  return cost, coinType, changeCount
end
function logic_suit_dye:GetRGBFromCustomHSB(h, s, b, bSkipRangeLimit)
  if h and s and b then
    local KismetMathLibrary = import("KismetMathLibrary")
    local normalizedH = h
    local normalizedS = s / suit_dye_macros.MAX_SATURATION
    local MinBrightness = self.MinBrightnessLimit or 0
    local fixedB = b
    if not bSkipRangeLimit then
      fixedB = MinBrightness + b * (suit_dye_macros.MAX_BRIGHTNESS - MinBrightness) / suit_dye_macros.MAX_BRIGHTNESS
    end
    local normalizedB = fixedB / suit_dye_macros.MAX_BRIGHTNESS
    local fakeLinearColor = KismetMathLibrary.HSVToRGB(normalizedH, normalizedS, normalizedB, 1)
    local sColor = fakeLinearColor:ToFColor(false)
    local result = FLinearColor.FromSRGBColor(sColor)
    return result
  end
  return self._defaultColor
end
function logic_suit_dye:GetRGBFromCustomHSBTable(hsbTable, bSkipRangeLimit)
  if not hsbTable then
    return self._defaultColor
  end
  return self:GetRGBFromCustomHSB(hsbTable.H, hsbTable.S, hsbTable.B, bSkipRangeLimit)
end
function logic_suit_dye:PartIdToLevel(partId)
  partId = partId or suit_dye_macros.MAX_PART_COUNT
  return math.floor((partId + 1) / 2)
end
function logic_suit_dye:PartIdToSubIndex(partId)
  partId = partId or suit_dye_macros.MAX_PART_COUNT
  return math.floor(partId + 1) % 2 + 1
end
function logic_suit_dye:LevelIndexToPartId(level, index)
  if not level or not index then
    return 0
  end
  local result = (level - 1) * 2 + index
  return FuncUtil.Clamp(result, 0, suit_dye_macros.MAX_PART_COUNT)
end
function logic_suit_dye:HSBToInteger(h, s, b)
  if not (h and s) or not b then
    return 0
  end
  h = math.floor(h)
  s = math.floor(s)
  b = math.floor(b)
  return (h & 65535) << 16 | (s & 255) << 8 | b & 255
end
function logic_suit_dye:IntegerToHSB(intValue)
  if not intValue then
    return nil
  end
  return intValue >> 16 & 65535, intValue >> 8 & 255, intValue & 255
end
function logic_suit_dye:GetCustomSetting(suitId)
  if not suitId then
    return nil
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local setting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSuitDyeCustomSetting)
  return setting and setting[suitId]
end
function logic_suit_dye:SaveCustomSettingToLocal(suitId, colorList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local setting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSuitDyeCustomSetting)
  setting = setting or {}
  setting[suitId] = {}
  if colorList then
    for i = 1, #suit_dye_macros.MAX_PART_COUNT do
      setting[suitId][i] = colorList[i]
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(setting, PlayerPrefsSystem.ePlayerPrefsType.eSuitDyeCustomSetting)
end
function logic_suit_dye:OnUnknowPassInfoUpdate()
  local oldPeriodList = self._periodListNeedRequestAgain
  self._periodListNeedRequestAgain = {}
  if oldPeriodList then
    for period, v in pairs(oldPeriodList) do
      if period and v then
        self:RequestSelfPlanData(period)
      end
    end
  end
end
function logic_suit_dye:ApplyOnePartSuitColor(avatarComp, suitId, partId, color, cancelBlink)
  log(bWriteLog and "logic_suit_dye:ApplyOnePartSuitColor")
  if not slua.isValid(avatarComp) then
    log_warning("logic_suit_dye:ApplyOnePartSuitColor avatar component is not valid.")
    return
  end
  if not suitId or not partId then
    log_warning("logic_suit_dye:ApplyOnePartSuitColor, either suitId or partId is not specified.")
    return
  end
  local entireScheme = {}
  local rgbColor = color and self:GetRGBFromCustomHSB(color.H, color.S, color.B) or nil
  local bMale = self:GetIsMale(avatarComp)
  local partData = self:GetPartData(suitId, partId, rgbColor, bMale)
  if partData then
    for _, param in pairs(partData) do
      if not entireScheme[param.avatarSlot] then
        entireScheme[param.avatarSlot] = {
          itemId = param.itemId,
          colorDataList = param.colorDataList
        }
      else
        local TableUtil = require("common.table_util")
        entireScheme[param.avatarSlot].colorDataList = TableUtil.TableConcat(entireScheme[param.avatarSlot].colorDataList, param.colorDataList)
      end
    end
    if cancelBlink then
      local selectPartData = self:GetSelectPartData(suitId, partId, false, bMale)
      if selectPartData then
        for _, param in pairs(selectPartData) do
          if not entireScheme[param.avatarSlot] then
            entireScheme[param.avatarSlot] = {
              itemId = param.itemId,
              colorDataList = param.colorDataList
            }
          else
            local TableUtil = require("common.table_util")
            entireScheme[param.avatarSlot].colorDataList = TableUtil.TableConcat(entireScheme[param.avatarSlot].colorDataList, param.colorDataList)
          end
        end
      end
    end
  end
  for k, v in pairs(entireScheme) do
    avatarComp:ApplyDIYColorData(k, v.itemId, v.colorDataList)
  end
end
function logic_suit_dye:ApplyEntireSuitColor(avatarComp, suitId, colorList, blinkPartId, bLimitLevel, originPlanId)
  log(bWriteLog and "logic_suit_dye:ApplyEntireSuitColor")
  if not slua.isValid(avatarComp) then
    log_warning("logic_suit_dye:ApplyEntireSuitColor avatar component is not valid.")
    return
  end
  if not suitId then
    log_warning("logic_suit_dye:ApplyEntireSuitColor, either suitId is not specified.")
    return
  end
  if not colorList then
    log_warning("logic_suit_dye:ApplyEntireSuitColor colorList is nil.")
    return
  end
  local entireScheme = {}
  local suitLevel = self:GetSuitLevelBySuitId(suitId)
  local bMale = self:GetIsMale(avatarComp)
  for i = 1, suit_dye_macros.MAX_PART_COUNT do
    local partLevel = self:PartIdToLevel(i)
    local bCanApplyColor = not bLimitLevel or suitLevel >= partLevel
    local color = bCanApplyColor and colorList[i] or nil
    local rgbColor = color and self:GetRGBFromCustomHSB(color.H, color.S, color.B) or nil
    local partData = self:GetPartData(suitId, i, rgbColor, bMale)
    if partData then
      for _, param in pairs(partData) do
        if not entireScheme[param.avatarSlot] then
          entireScheme[param.avatarSlot] = {
            itemId = param.itemId,
            colorDataList = param.colorDataList
          }
        else
          local TableUtil = require("common.table_util")
          entireScheme[param.avatarSlot].colorDataList = TableUtil.TableConcat(entireScheme[param.avatarSlot].colorDataList, param.colorDataList)
        end
      end
    end
    local selectPartData = self:GetSelectPartData(suitId, i, i == blinkPartId, bMale)
    if selectPartData then
      for _, param in pairs(selectPartData) do
        if not entireScheme[param.avatarSlot] then
          entireScheme[param.avatarSlot] = {
            itemId = param.itemId,
            colorDataList = param.colorDataList
          }
        else
          local TableUtil = require("common.table_util")
          entireScheme[param.avatarSlot].colorDataList = TableUtil.TableConcat(entireScheme[param.avatarSlot].colorDataList, param.colorDataList)
        end
      end
    end
  end
  if originPlanId then
    local extraParamData = self:GetPlanExtraParamData(suitId, originPlanId, bMale)
    if extraParamData then
      for _, param in pairs(extraParamData) do
        if not entireScheme[param.avatarSlot] then
          entireScheme[param.avatarSlot] = {
            itemId = param.itemId,
            colorDataList = param.colorDataList
          }
        else
          local TableUtil = require("common.table_util")
          entireScheme[param.avatarSlot].colorDataList = TableUtil.TableConcat(entireScheme[param.avatarSlot].colorDataList, param.colorDataList)
        end
      end
    end
  end
  for k, v in pairs(entireScheme) do
    avatarComp:ApplyDIYColorData(k, v.itemId, v.colorDataList)
  end
end
function logic_suit_dye:GetPartCfg(period, partId)
  if not period or not partId then
    return nil
  end
  return self.periodPartCfg[period] and self.periodPartCfg[period][partId]
end
function logic_suit_dye:GetPartData(suitId, partId, color, bMale)
  if not suitId then
    return nil
  end
  local period = self:GetPeriodBySuitId(suitId)
  if not period then
    return nil
  end
  local partCfg = self:GetPartCfg(period, partId)
  if not partCfg or not partCfg.partParamList then
    return nil
  end
  local dyeData = {}
  for i, param in ipairs(partCfg.partParamList) do
    local associateItemId = self:GetSuitAssociateItemId(suitId, param.avatarSlotId, bMale)
    if associateItemId and associateItemId ~= 0 then
      if associateItemId and not dyeData[associateItemId] then
        dyeData[associateItemId] = {
          itemId = associateItemId,
          avatarSlot = param.avatarSlotId,
          colorDataList = {}
        }
      end
      local colorDataList = dyeData[associateItemId].colorDataList
      if color then
        table.insert(colorDataList, {
          MatSlotID = param.matSlotId,
          Color = color,
          ColorParamName = param.paramName,
          ColorParamType = 0
        })
        table.insert(colorDataList, {
          MatSlotID = param.matSlotId,
          Color = 1.0,
          ColorParamName = param.switchParamName,
          ColorParamType = 1
        })
        if param.closeMaskParamName and param.closeMaskParamName ~= "" then
          table.insert(colorDataList, {
            MatSlotID = param.matSlotId,
            Color = 0.0,
            ColorParamName = param.closeMaskParamName,
            ColorParamType = 1
          })
        end
      else
        table.insert(colorDataList, {
          MatSlotID = param.matSlotId,
          Color = 0.0,
          ColorParamName = param.switchParamName,
          ColorParamType = 1
        })
        if param.closeMaskParamName and param.closeMaskParamName ~= "" then
          table.insert(colorDataList, {
            MatSlotID = param.matSlotId,
            Color = 1.0,
            ColorParamName = param.closeMaskParamName,
            ColorParamType = 1
          })
        end
      end
    end
  end
  return dyeData
end
function logic_suit_dye:GetPlanExtraParamData(suitId, planId, bMale)
  if not suitId then
    return nil
  end
  if not planId then
    return nil
  end
  local period = self:GetPeriodBySuitId(suitId)
  if not period then
    return nil
  end
  local planCfg = self:GetSuitPlanCfg(period, planId)
  if not planCfg or not planCfg.extraParamIDList then
    return nil
  end
  local extraParamData = {}
  for _, extraParamId in pairs(planCfg.extraParamIDList) do
    local extraParamCfg = CDataTable.GetTableData("SuitDyePlanExtraParam", extraParamId)
    if extraParamCfg then
      local associateItemId = self:GetSuitAssociateItemId(suitId, extraParamCfg.AvatarSlotID, bMale)
      if associateItemId and associateItemId ~= 0 then
        if associateItemId and not extraParamData[associateItemId] then
          extraParamData[associateItemId] = {
            itemId = extraParamId,
            avatarSlot = extraParamCfg.AvatarSlotID,
            colorDataList = {}
          }
        end
        local colorDataList = extraParamData[associateItemId].colorDataList
        local paramType = extraParamCfg.ParamType
        local paramValue
        if paramType == 0 then
          local strH, strS, strB = string.match(extraParamCfg.ParamValue, "([.%d]+)%s*[,;]%s*(%d+)%s*[,;]%s*(%d+)")
          local h = tonumber(strH)
          local s = tonumber(strS)
          local b = tonumber(strB)
          if h and s and b then
            paramValue = logic_suit_dye:GetRGBFromCustomHSB(h, s, b, false)
          end
        elseif paramType == 1 then
          paramValue = tonumber(extraParamCfg.ParamValue)
        elseif paramType == 2 then
          paramValue = extraParamCfg.ParamValue and extraParamCfg.ParamValue ~= "" and extraParamCfg.ParamValue or nil
        else
          paramValue = nil
        end
        if paramValue then
          table.insert(colorDataList, {
            MatSlotID = extraParamCfg.MatSlotID,
            Color = paramValue,
            ColorParamName = extraParamCfg.ParamName,
            ColorParamType = paramType
          })
        end
      end
    end
  end
  return extraParamData
end
function logic_suit_dye:GetSuitAssociateItemId(suitId, slotId, bMale)
  if not suitId or not slotId then
    return nil
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  if slotId == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    return suitId
  end
  local suitsCfg = CDataTable.GetTableData("AvatarSuitsTable", suitId)
  if suitsCfg then
    local StringUtil = require("common.string_util")
    local suitItems
    if bMale then
      suitItems = StringUtil.Split(suitsCfg.MaleSuits, "|")
    else
      suitItems = StringUtil.Split(suitsCfg.FemaleSuits, "|")
    end
    local associateItemId = tonumber(suitItems and suitItems[slotId])
    return associateItemId
  else
    local bindSuits = self:GetSuitBindSuits(suitId)
    if not bindSuits then
      return nil
    end
    for _, v in pairs(bindSuits) do
      local bpCfg = CDataTable.GetTableData("AvatarBPTable", v)
      if bpCfg then
        local tmpSlot = math.floor(bpCfg.TemplateID / 1000)
        if tmpSlot == slotId then
          return v
        end
      end
    end
    return nil
  end
end
function logic_suit_dye:GetSuitBindSuits(suitId)
  local bindCfg = CDataTable.GetTableData("ColorDIYBindSuit", suitId)
  if not bindCfg then
    return nil
  end
  local Ret = {}
  for _, v in pairs(bindCfg.BindIDArray_a) do
    table.insert(Ret, v)
  end
  return Ret
end
function logic_suit_dye:GetSelectPartData(suitId, partId, bSelect, bMale)
  if not suitId then
    return nil
  end
  local period = self:GetPeriodBySuitId(suitId)
  if not period then
    return nil
  end
  local partCfg = self:GetPartCfg(period, partId)
  if not partCfg or not partCfg.partParamList then
    return nil
  end
  local selectData = {}
  for i, param in ipairs(partCfg.partParamList) do
    local associateItemId = self:GetSuitAssociateItemId(suitId, param.avatarSlotId, bMale)
    if associateItemId and associateItemId ~= 0 then
      if associateItemId and not selectData[associateItemId] then
        selectData[associateItemId] = {
          itemId = associateItemId,
          avatarSlot = param.avatarSlotId,
          colorDataList = {}
        }
      end
      local colorDataList = selectData[associateItemId].colorDataList
      table.insert(colorDataList, {
        MatSlotID = param.matSlotId,
        Color = bSelect and 1.0 or 0.0,
        ColorParamName = param.highLightParamName,
        ColorParamType = 1
      })
    end
  end
  return selectData
end
function logic_suit_dye:SelectPart(avatarComp, suitId, partId, bSelect)
  log(bWriteLog and "logic_suit_dye:SelectPart")
  if not slua.isValid(avatarComp) then
    log_warning("logic_suit_dye:SelectPart avatar component is not valid.")
    return
  end
  if not suitId or not partId then
    log_warning("logic_suit_dye:SelectPart, either suitId or partId is not specified.")
    return
  end
  local bMale = self:GetIsMale(avatarComp)
  local selectData = self:GetSelectPartData(suitId, partId, bSelect, bMale)
  if selectData then
    for _, param in pairs(selectData) do
      avatarComp:ApplyDIYColorData(param.avatarSlot, param.itemId, param.colorDataList)
    end
  end
end
function logic_suit_dye:GetPeriodBySuitId(suitId)
  return suitId and self.suitId2PeriodMap and self.suitId2PeriodMap[suitId] or 0
end
function logic_suit_dye:GetMyDetailPlanData(period)
  if not period then
    log(bWriteLog and "logic_suit_dye:GetMyDetailPlanData error! period is nil")
    return nil
  end
  local myPlanData = self.myDetailData[period]
  if not myPlanData then
    self:RequestSelfPlanData(period)
  end
  return myPlanData
end
function logic_suit_dye:SetMyDetailPlanIdAndDataFull(period, cur_plan_id, plans)
  if not period or not cur_plan_id then
    log_error(bWriteLog and string.format("logic_suit_dye:SetMyDetailPlanIdAndData error! period = %s, cur_plan_id = %s", tostring(period), tostring(cur_plan_id)))
    return
  end
  self.myDetailData[period] = {
    cur_plan_id = cur_plan_id,
    plans = plans or {}
  }
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid then
    local itemID = self:GetSuitIdByPeriodLevel(period, self:GetOwnedSuitLevel(period))
    if itemID then
      self:SetPlanData(myUid, itemID, plans[cur_plan_id] or cur_plan_id)
    end
  end
end
function logic_suit_dye:SetMyDetailPlanIdAndDataIncrement(period, plan_id, data)
  if not period or not plan_id then
    log_error(bWriteLog and string.format("logic_suit_dye:SetMyDetailPlanIdAndDataIncrement error! period = %s, plan_id = %s", tostring(period), tostring(plan_id)))
    return
  end
  local planData = data or {}
  if not self.myDetailData[period] then
    self.myDetailData[period] = {
      cur_plan_id = plan_id,
      plans = {
        [plan_id] = planData
      }
    }
  else
    self.myDetailData[period].cur_    if not self.myDetailData[period].plans then
      self.myDetailData[period].plans = {
        [plan_id] = planData
      }
    else
      self.myDetailData[period].plans[plan_id] = planData
    end
  end
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid then
    local itemID = self:GetSuitIdByPeriodLevel(period, self:GetOwnedSuitLevel(period))
    if itemID then
      self:SetPlanData(myUid, itemID, planData)
    end
  end
end
function logic_suit_dye:IsSuitDyeValidateBySuitId(suitId)
  if not suitId then
    return false
  end
  local period = self:GetPeriodBySuitId(suitId)
  if period == 0 then
    return false
  end
  return self:IsSuitDyeValidateByPeriod(period)
end
function logic_suit_dye:IsSuitDyeValidateByPeriod(period)
  if not period or period == 0 then
    return false
  end
  local openSeason = self.periodCfg[period] and self.periodCfg[period][1] and self.periodCfg[period][1].openSeason
  log(bWriteLog and "[dye] IsSuitDyeValidateByPeriod current: " .. UnknowPassSystem.Season .. " open season: " .. tostring(openSeason))
  if UnknowPassSystem.Season and openSeason then
    return openSeason <= UnknowPassSystem.Season
  end
  return false
end
function logic_suit_dye:SetMyDetailPlanId(period, cur_plan_id)
  if not period or not cur_plan_id then
    log_error(bWriteLog and string.format("logic_suit_dye:SetMyDetailPlanData error! period = %s, cur_plan_id = %s", tostring(period), tostring(cur_plan_id)))
    return
  end
  if not self.myDetailData[period] then
    self.myDetailData[period] = {
      cur_plan_id = cur_plan_id,
      plans = {}
    }
  else
    self.myDetailData[period].  end
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid then
    local itemID = self:GetSuitIdByPeriodLevel(period, self:GetOwnedSuitLevel(period))
    if itemID then
      if cur_plan_id == 0 then
        self:SetPlanData(myUid, itemID, self.myDetailData[period].plans[0] or {})
      else
        self:SetPlanData(myUid, itemID, cur_plan_id)
      end
    end
  end
end
function logic_suit_dye:ConvertDataFromServer(period, data)
  local colorList = {}
  local originPlanId
  if not period or not data then
    log(bWriteLog and "logic_suit_dye:ConvertDataFromServer either period or data is nil, return default")
    return colorList
  end
  if type(data) == "number" then
    local planColorList, planType = self:GetDyeSuitPlanColorAndType(period, data)
    if planType == suit_dye_macros.ENUM_SUITDYE_TYPE.Default then
      return colorList, data
    end
    if planColorList then
      for i = 1, suit_dye_macros.MAX_PART_COUNT do
        colorList[i] = planColorList[i]
      end
      originPlanId = data
    end
  elseif type(data) == "table" then
    for i = 1, suit_dye_macros.MAX_PART_COUNT do
      if type(data[i]) == "number" then
        if data[i] ~= -1 then
          local h, s, b = self:IntegerToHSB(data[i])
          colorList[i] = {
            H = h,
            S = s,
            B = b
          }
        end
      else
        colorList[i] = data[i]
      end
    end
    originPlanId = data.origin_plan
  end
  return colorList, originPlanId
end
function logic_suit_dye:ConvertHSBListToServerFormat(colorList)
  local intValueList = {}
  if not colorList or not next(colorList) then
    return intValueList
  end
  for i = 1, suit_dye_macros.MAX_PART_COUNT do
    local color = colorList[i]
    if color then
      intValueList[i] = self:HSBToInteger(color.H, color.S, color.B)
    end
  end
  return intValueList
end
function logic_suit_dye:ApplySuitSchemeData(avatarComp, suitId, schemeData, originPlan)
  log(bWriteLog and "logic_suit_dye:ApplySuitSchemeData suitId: " .. tostring(suitId) .. " originPlan: " .. tostring(originPlan) .. " avatarComp: " .. tostring(avatarComp))
  if not slua.isValid(avatarComp) then
    return
  end
  if not suitId then
    return
  end
  local period = self:GetPeriodBySuitId(suitId)
  if not period then
    return
  end
  local colorList, originPlanInScheme = self:ConvertDataFromServer(period, schemeData)
  if Client.IsDevelopment() then
    log_tree("logic_suit_dye:ApplySuitSchemeData: ", {schemeData = schemeData, colorList = colorList})
  end
  originPlan = originPlan or originPlanInScheme
  self:ApplyEntireSuitColor(avatarComp, suitId, colorList, nil, true, originPlan)
end
function logic_suit_dye:SetPlanData(UID, ItemID, data)
  log(bWriteLog and "logic_suit_dye:SetPlanData " .. tostring(UID))
  local period = self:GetPeriodBySuitId(ItemID)
  if not UID or period == 0 then
    log_error(bWriteLog and string.format("logic_suit_dye:SetPlanData error! UID = %s, itemId = %s", tostring(UID), tostring(ItemID)))
    return
  end
  UID = tostring(UID)
  if not self.Data[UID] then
    self.Data[UID] = {}
  end
  if not self.ExtraData[UID] then
    self.ExtraData[UID] = {}
  end
  local valueData = data
  local originPlan
  valueData, originPlan = self:ConvertDataFromServer(period, valueData)
  valueData = valueData or {}
  self.Data[UID][period] = valueData
  self.ExtraData[UID][period] = {OriginPlan = originPlan}
  if not Client.IsShipping() then
    log_tree("logic_suit_dye:SetPlanData", valueData)
  end
  EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_CHARACTERAVATARCOMP_UPDATE, UID, ItemID, valueData, originPlan)
end
function logic_suit_dye:GetPlanData(UID, period)
  log(bWriteLog and "logic_suit_dye:GetPlanData  " .. tostring(UID))
  if not UID or not period then
    log_error(bWriteLog and string.format("logic_suit_dye:GetPlanData error! UID = %s, SuitID = %s", tostring(UID), tostring(period)))
    return nil, nil
  end
  UID = tostring(UID)
  local originPlan = self.ExtraData and self.ExtraData[UID] and self.ExtraData[UID][period] and self.ExtraData[UID][period].OriginPlan
  if self.Data[UID] and self.Data[UID][period] then
    return self.Data[UID][period], originPlan
  end
  log(bWriteLog and string.format("logic_suit_dye:GetPlanData not found! UID = %s, period = %s", tostring(UID), tostring(period)))
  return nil, nil
end
function logic_suit_dye:RequestSelfPlanData(period)
  if not period then
    log_error(bWriteLog and "logic_suit_dye:RequestSelfPlanData error! period is nil")
    return
  end
  local bSuitUnlocked = self:IsSuitUnlocked(period)
  local bOwnSuit = self:GetOwnedSuitLevel(period) > 0
  if bSuitUnlocked and bOwnSuit then
    local SuitDyeHandler = require("client.network.Protocol.SuitDyeHandler")
    SuitDyeHandler.send_get_recolor_suit_plan_data_req(period)
  elseif not bSuitUnlocked then
    self._periodListNeedRequestAgain[period] = true
  end
end
function logic_suit_dye:GetIsMale(avatarComp)
  local bMale = false
  if not slua.isValid(avatarComp) then
    return bMale
  end
  bMale = avatarComp.gender == 0
  return bMale
end
function logic_suit_dye:GetSuitLevelBySuitId(suitId)
  if not suitId then
    return 0
  end
  local period = self:GetPeriodBySuitId(suitId)
  if not period or period == 0 then
    return 0
  end
  local curPeriodCfg = self.periodCfg[period]
  if curPeriodCfg and next(curPeriodCfg) then
    for k, v in pairs(curPeriodCfg) do
      if v.suitId == suitId then
        return v.level
      end
    end
  end
  return 0
end
function logic_suit_dye:GetDefaultPlanColorCfg(period)
  if not period then
    return nil
  end
  if not self.planCfg or not self.planCfg[period] then
    return nil
  end
  for i, planItem in ipairs(self.planCfg[period]) do
    if planItem.planType == suit_dye_macros.ENUM_SUITDYE_TYPE.Default then
      return planItem.colorList
    end
  end
  return nil
end
function logic_suit_dye:GetSuitOpenSeason(period)
  if not period then
    return nil
  end
  return self.periodOpenSeason and self.periodOpenSeason[period]
end
function logic_suit_dye:IsSuitUnlocked(period)
  if not period then
    return false
  end
  local openSeason = self:GetSuitOpenSeason(period)
  local currentSeason = tonumber(UnknowPassSystem.Season) or 1
  return openSeason and openSeason <= currentSeason
end
function logic_suit_dye:UpdateLobbyAvatar()
  log(bWriteLog and "logic_suit_dye:UpdateLobbyAvatar")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetModel(DataMgr.roleData.uid)
  if avatar then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tRoleWear = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and self:IsDyeSuit(itemInfo.resID) then
        local data, originPlan = self:GetPlanData(DataMgr.roleData.uid, self:GetPeriodBySuitId(itemInfo.resID))
        if data then
          self:ApplySuitSchemeData(avatar.CharacterAvatarComp2_BP, itemInfo.resID, data, originPlan)
        end
      end
    end
  end
end
function logic_suit_dye:CheckHasSameGroupItem(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local period = self:GetPeriodBySuitId(resID)
  if not period then
    return false
  end
  local groupList = self:GetDyeSuitLevels(period)
  if groupList then
    for _, info in pairs(groupList) do
      if info.suitId and wardrobe_data:HasItem(info.suitId) then
        return true, info.suitId
      end
    end
  end
  return false
end
function logic_suit_dye:CheckUnlockedLevelByItemID(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local period = self:GetPeriodBySuitId(resID)
  if not period then
    return false
  end
  local groupList = self:GetDyeSuitLevels(period)
  if groupList then
    local lock = 0
    for level, info in pairs(groupList) do
      if info.suitId and info.suitId == resID then
        lock = level
        break
      end
    end
    for level, info in pairs(groupList) do
      if level >= lock and info.suitId and wardrobe_data:HasItem(info.suitId) then
        return true, info.suitId
      end
    end
  end
  return false
end
function logic_suit_dye:GetUnlockedCurrentLevelItemID(period)
  local groupList = self:GetDyeSuitLevels(period)
  if not groupList then
    return nil
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, info in pairs(groupList) do
    if info.suitId and wardrobe_data:HasItem(info.suitId) then
      return info.suitId
    end
  end
end
function logic_suit_dye:SetMinBrightnessLimit(MinBrightnessLimit)
  self.end
function logic_suit_dye:on_get_recolor_suit_plan_data_rsp(period, cur_plan_id, plans)
  log(bWriteLog and "logic_suit_dye:on_get_recolor_suit_plan_data_rsp")
  self:SetMyDetailPlanIdAndDataFull(period, cur_plan_id, plans)
  EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_DATA_UPDATE, period)
end
function logic_suit_dye:on_set_recolor_suit_plan_id_rsp(period, cur_plan_id)
  if not period or not cur_plan_id then
    log_error(bWriteLog and string.format("logic_suit_dye:on_set_recolor_suit_plan_id_rsp error! period = %s, cur_plan_id = %s", tostring(period), tostring(cur_plan_id)))
    return
  end
  self:SetMyDetailPlanId(period, cur_plan_id)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:SetTriggerSuitDye(true)
  EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_PLAN_CHANGED, period, cur_plan_id)
  self:UpdateLobbyAvatar()
end
function logic_suit_dye:on_set_recolor_suit_plan_data_rsp(period, plan_id, data)
  if not period or not plan_id then
    log_error(bWriteLog and string.format("logic_suit_dye:on_set_recolor_suit_plan_data_rsp error! period = %s, plan_id = %s", tostring(period), tostring(plan_id)))
    return
  end
  self:SetMyDetailPlanIdAndDataIncrement(period, plan_id, data)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:SetTriggerSuitDye(true)
  EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_CUSTOMDATA_CHANGED, period, plan_id)
  self:UpdateLobbyAvatar()
end
function logic_suit_dye:RequestUpgrade(period)
  if not period then
    log_error("logic_suit_dye:RequestUpgrade period is nil")
  end
  local SuitDyeHandler = require("client.network.Protocol.SuitDyeHandler")
  SuitDyeHandler.send_upgrade_recolor_suit_req(period)
end
function logic_suit_dye:OnUpgradeRsp(period, level)
  EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_UPGRADE_SUCCESS, period, level)
end
function logic_suit_dye:BattleProfileBatchGet(game_id, requestList)
  log(bWriteLog and "logic_suit_dye BattleProfileBatchGet")
  local LogicBattleProfile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_profile)
  local moduleID = LogicBattleProfile.MODULE_ENUM.SUIT_DYE
  local queryParams = {}
  for _, request in pairs(requestList) do
    if not queryParams[request.PlayerID] then
      queryParams[request.PlayerID] = {
        [moduleID] = {}
      }
    end
    local period = self:GetPeriodBySuitId(request.ItemID)
    if period then
      table.insert(queryParams[request.PlayerID][moduleID], period)
    else
      log_error(string.format("logic_suit_dye:BattleProfileBatchGet item is not diy suit %s", tostring(request.ItemID)))
    end
  end
  LogicBattleProfile:BatchGetBattleProfileReq(game_id, queryParams)
end
function logic_suit_dye:OnBattleProfileBatchGet(_, _, game_id, profiles)
  log(bWriteLog and "logic_suit_dye:OnBattleProfileBatchGet")
  local LogicBattleProfile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_profile)
  local moduleID = LogicBattleProfile.MODULE_ENUM.SUIT_DYE
  local formatData = {}
  local originPlanData = {}
  if profiles then
    for uid, userData in pairs(profiles) do
      if userData and userData[moduleID] then
        formatData[uid] = {}
        originPlanData[uid] = {}
        for period, data in pairs(userData[moduleID]) do
          local currentFormatData, currentOriginPlanId = self:ConvertDataFromServer(period, data)
          formatData[uid][period] = currentFormatData or {}
          originPlanData[uid][period] = currentOriginPlanId
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_BATTLEPROFILE, EVENTID_BATTLEPROFILE_SUIT_DYE_RES, formatData, originPlanData)
end
function logic_suit_dye:OnJumpFromUrl(_, _, vars)
  vars = vars or {}
  local period = vars.period
  local source = vars.source or -1
  self:EnterSuitDye(period, source)
end
function logic_suit_dye:GetDefaultSuitPeriod()
  local periodList = self:GetDyeSuitPeriodList()
  local latestPeriodOwned, latestPeriodValid
  if periodList then
    for period = #periodList, 1, -1 do
      if not latestPeriodValid and self:IsSuitDyeValidateByPeriod(period) then
        latestPeriodValid = period
        if not latestPeriodOwned and self:GetOwnedSuitLevel(period) > 0 then
          latestPeriodOwned = period
        end
      end
    end
  end
  return latestPeriodOwned or latestPeriodValid or 1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_suit_dye = class(CModuleBase, nil, logic_suit_dye)
return Clogic_suit_dye