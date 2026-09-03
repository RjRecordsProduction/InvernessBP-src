local Common_Collect_Level_UIBP = {}
local MinDan, MaxDan = 1, 6
local C_LevelNum_Split_Line = 4
local C_Level_BG_Texture = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_0%d_Bg.Collect_Level_0%d_Bg"
local C_Level_BG_Texture_Gray = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_0%d_Gray_Bg.Collect_Level_0%d_Gray_Bg"
local C_Level_Num_Color_1_3 = FSlateColor(FLinearColor(0.672443, 0.708376, 0.799103, 1))
local C_Level_Num_Color_1_3_Gray = FSlateColor(FLinearColor(0.672443, 0.708376, 0.799103, 1))
local C_Level_Num_Color_4_6 = FSlateColor(FLinearColor(1, 0.775822, 0.082283, 1))
local C_Level_Num_Color_4_6_Gray = FSlateColor(FLinearColor(1, 0.854993, 1, 1))
function Common_Collect_Level_UIBP:ctor(_, uid, collectPara)
  self.uid = uid or ""
  self.collectPara = collectPara or {}
  self.totalScore = 0
  self.seasonScore = 0
end
function Common_Collect_Level_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Collect, self.OnClickButton_Collect, self)
end
function Common_Collect_Level_UIBP:OnPostInitialize()
  self:SetCollectLevel()
end
function Common_Collect_Level_UIBP:SetCollectLevel()
  log(bWriteLog and string.format("Common_Avatar_CollectLevel:SetCollectLevel uid = %s", self.uid))
  log_tree("collectPara", self.collectPara)
  local collectData = self.collectPara.collectData or {}
  local curLevel, curDan = self.collectPara.curLevel, self.collectPara.curDan
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  self.totalScore, self.seasonScore = collect_module:GetCollectScoreByCollectData(collectData)
  if not curLevel or not curDan then
    curLevel, curDan = collect_module:GetLevelByScore(self.totalScore)
  end
  log(bWriteLog and string.format("Common_Avatar_CollectLevel:SetCollectLevel self.totalScore = %s, curLevel = %s", self.totalScore, curLevel))
  if type(curLevel) ~= "number" or curLevel <= 0 then
    log(bWriteLog and "Common_Avatar_CollectLevel:SetCollectLevel this data is illegal. curLevel = %s", curLevel)
    return
  end
  self.UIRoot.TextNum:SetText(curLevel)
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  curDan = math.max(MinDan, curDan)
  curDan = math.min(MaxDan, curDan)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.uid)
  local collect_data_cache = profile and profile.collect_data
  local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
  local canLightBadge = collect_badge_module:CheckCanLightBadge(self.uid, collect_data_cache)
  self:TriggerToHighlights(curDan, canLightBadge, self.seasonScore)
  if self.collectPara.showAnimation then
    self:PlayUserWidgetAnimation(self.UIRoot.Ani_LevelUP, 0, 1, 0, 1)
  end
end
function Common_Collect_Level_UIBP:TriggerToHighlights(curDan, canLightBadge, seasonScore)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local lightSpecial = self.UIRoot.CanvasPanel_Glow
  local levelBG = self.UIRoot.Image_Level_BG
  local numColor = C_Level_Num_Color_1_3
  local tPath
  local seasonLevel, highlight = collect_module:GetSeasonLevelByScore(seasonScore)
  log(bWriteLog and string.format("collect_item_util.TriggerToHighlights curDan = %s, seasonLevel = %s, highlight = %s", curDan, seasonLevel, highlight))
  if highlight and canLightBadge then
    tPath = string.format(C_Level_BG_Texture, curDan, curDan)
    if lightSpecial then
      lightSpecial:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:CreateChildWindow(lightSpecial, UIManager.UI_Config.Common_Collect_Level_Bright_UIBP, curDan)
    end
    if curDan >= C_LevelNum_Split_Line then
      numColor = C_Level_Num_Color_4_6
    end
  else
    if lightSpecial then
      lightSpecial:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    tPath = string.format(C_Level_BG_Texture_Gray, curDan, curDan)
    if curDan >= C_LevelNum_Split_Line then
      numColor = C_Level_Num_Color_4_6_Gray
    else
      numColor = C_Level_Num_Color_1_3_Gray
    end
  end
  if levelBG then
    self:SetTexture(levelBG, tPath, {sync = false})
  end
  self.UIRoot.TextNum:SetColorAndOpacity(numColor)
end
function Common_Collect_Level_UIBP:OnClickButton_Collect()
  if not self.uid then
    return
  end
  if not self.collectPara then
    return
  end
  if not self.collectPara.showCollectTips then
    return
  end
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Level_Medal_Tips_UIBP, self.UIRoot, self.totalScore, self.seasonScore, self.uid or "")
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Avatar_CollectLevel = class(ui_base, nil, Common_Collect_Level_UIBP)
return CCommon_Avatar_CollectLevel