local IngameBuffItemUI = {}
local UGameplayStatics = import("GameplayStatics")
local USTExtraUIUtils = import("STExtraUIUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UpPos = FVector2D(0, 0)
local UpLeftPos = FVector2D(-31, -2)
local UpRightPos = FVector2D(31, -2)
local DownPos = FVector2D(0, 242)
local DownLeftPos = FVector2D(-31, 230)
local DownRightPos = FVector2D(31, 230)
function IngameBuffItemUI:ctor()
  print(bwriteLog and "-IngameBuffItemUI:ctor")
  self.DSEndTime = 0
  self.Duration = 0
  self.BuffID = 0
  self.LayerCount = 1
end
function IngameBuffItemUI:OnInitialize()
  print(bWriteLog and "-IngameBuffItemUI:Initialize")
  self.bCanEverTick = true
  self.bHasScriptImplementedTick = true
  self.bAdabptLocation = false
end
function IngameBuffItemUI:RegistEvents()
  if self.Button_ShowTips then
    self:AddControlEvent(self.Button_ShowTips, "OnPressed", self.ShowBuffDesc, self)
    self:AddControlEvent(self.Button_ShowTips, "OnReleased", self.HideBuffDesc, self)
  end
end
function IngameBuffItemUI:Tick(DeltaTime)
  self:TickBuffItem()
end
function IngameBuffItemUI:InitBuffInfo(InstID, uBuff, Duration, DSEndTime, LayerCount, SkillID)
  if not uBuff or not slua.isValid(uBuff) then
    print(bWriteLog and "-IngameBuffItemUI:InitBuffInfo Error , Buff Is Nil")
    return
  end
  local CurServerTime = UGameplayStatics.GetGameState(self):GetServerWorldTimeSeconds()
  local CurWorldTime = UGameplayStatics.GetTimeSeconds(self)
  print(bWriteLog and "-IngameBuffItemUI:InitBuffInfo BuffID:" .. uBuff.BuffID .. "DSEndTime:" .. DSEndTime .. " CurServerTime:" .. CurServerTime .. " CurWorldTime:" .. CurWorldTime .. " Duration:" .. Duration .. " InstID:" .. InstID)
  self.  self.  self.BuffID = uBuff.BuffID
  self.LayerCount = LayerCount or 1
  local uPlayCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayCharacter) then
    local BuffSytemCom = uPlayCharacter:GetBuffComponent()
    if slua.isValid(BuffSytemCom) then
      self.CDDataArray = BuffSytemCom:GetBuffCDInfo(InstID)
    end
  end
  local CreativeCustomBuffSubsystem = SubsystemMgr:Get("CreativeCustomBuffSubsystem")
  if CreativeCustomBuffSubsystem then
    local SetUGCBuffItem = function()
      if CreativeCustomBuffSubsystem then
        local Icon, Tip = CreativeCustomBuffSubsystem:GetIconAndTipForBar(SkillID, uBuff.BuffID)
        if Icon and Tip then
          print(bWriteLog and "IngameBuffItemUI:InitBuffInfo--GetIconAndTipForBar :" .. uBuff.BuffID .. " :" .. SkillID .. ", Icon:" .. Icon .. ", Tip:" .. Tip)
          if USTExtraUIUtils then
            self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.Image_BG_card:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            USTExtraUIUtils.SetImageTextureAsync(Icon, self.Image_BG_card)
          end
          self.UTRichTextBlock_SkillDEsc:SetText(Tip)
          self.UTRichTextBlock_SkillDEsc_Down:SetText(Tip)
        else
          if USTExtraUIUtils then
            self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.Image_BG_card:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            USTExtraUIUtils.SetImageTextureAsync(uBuff.IconPath, self.Image_BG_card)
          end
          self:SetBuffDesc(uBuff.LocalizeDescID)
        end
      end
    end
    print(bWriteLog and "-IngameBuffItemUI:InitBuffInfo IsExecOverrideBuffData", CreativeCustomBuffSubsystem:IsExecOverrideBuffData())
    if CreativeCustomBuffSubsystem:IsExecOverrideBuffData() then
      SetUGCBuffItem()
      return
    else
      self:AddCommonEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOM_BUFF_EXEC, function()
        SetUGCBuffItem()
        self:RemoveCommonEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOM_BUFF_EXEC)
      end)
    end
  end
  if USTExtraUIUtils then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_BG_card:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    USTExtraUIUtils.SetImageTextureAsync(uBuff.IconPath, self.Image_BG_card)
  end
  if uBuff.LocalizeDescID then
    self:SetBuffDesc(uBuff.LocalizeDescID)
  else
    print(bWriteLog and "-IngameBuffItemUI:InitBuffInfo LocalizeDescID is nil")
  end
end
function IngameBuffItemUI:SetBuffDesc(LocalizeDescID)
  print(bWriteLog and "-IngameBuffItemUI:SetBuffDesc", LocalizeDescID)
  if LocalizeDescID and type(LocalizeDescID) == "number" then
    local sDesc = LocUtil.GetLocalizeResStr(LocalizeDescID)
    if sDesc then
      self.UTRichTextBlock_SkillDEsc:SetText(sDesc)
      self.UTRichTextBlock_SkillDEsc_Down:SetText(sDesc)
    end
  end
end
function IngameBuffItemUI:UpdateBuffInfo(InstID, BuffID, DSEndTime, Duration, LayerCount)
  print(bWriteLog and "-IngameBuffItemUI:UpdateBuffInfo", LayerCount)
  self.  self.  self.  self.LayerCount = LayerCount or 1
  local uPlayCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayCharacter) then
    local BuffSytemCom = uPlayCharacter:GetBuffComponent()
    if slua.isValid(BuffSytemCom) then
      self.CDDataArray = BuffSytemCom:GetBuffCDInfo(InstID)
    end
  end
end
function IngameBuffItemUI:ShowBuffDesc()
  print(bWriteLog and "-IngameBuffItemUI:ShowBuffDesc", self, self.BuffID)
  self:ClearAutoShowTimer()
  local BuffListUI = UIManager.GetUI(UIManager.UI_Config_InGame.BuffList)
  if BuffListUI then
    BuffListUI:HideAllBuffDesc()
  end
  self:AdjustDescPosition()
  if self.Skill_Desc_Tips then
    self.Skill_Desc_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function IngameBuffItemUI:HideBuffDesc()
  print(bWriteLog and "-IngameBuffItemUI:HideBuffDesc", self, self.BuffID)
  if self.Skill_Desc_Tips then
    self.Skill_Desc_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ClearAutoShowTimer()
end
function IngameBuffItemUI:ClearAutoShowTimer()
  if self.AutoShowBuffDescTimer then
    print(bWriteLog and "-IngameBuffItemUI:ClearAutoShowTimer - BuffID:", self.BuffID)
    self:RemoveTimer(self.AutoShowBuffDescTimer)
    self.AutoShowBuffDescTimer = nil
  end
end
function IngameBuffItemUI:ResetBuffItem()
  print(bWriteLog and "-IngameBuffItemUI:ResetBuffItem - prevBuffID:", self.BuffID)
  self:ClearAutoShowTimer()
  self:HideBuffDesc()
  self.BuffID = 0
end
function IngameBuffItemUI:GetBuffID()
  return self.BuffID
end
function IngameBuffItemUI:TickBuffItem()
  self.Image_BOXCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Text_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local DynamicCDMaterial = self.Image_BOXCDBar:GetDynamicMaterial()
  if not DynamicCDMaterial then
    print(bWriteLog and "-IngameBuffItemUI:TickBuffItem Error  DynamicCDMaterial is nil")
    return
  end
  local CurServerWorldTime = UGameplayStatics.GetGameState(self):GetServerWorldTimeSeconds()
  local RemainTime = self.DSEndTime - CurServerWorldTime
  if 0 < RemainTime then
    local CurCDPercent = 1 - RemainTime / self.Duration
    if 0 < CurCDPercent and CurCDPercent < 1 then
      DynamicCDMaterial:SetScalarParameterValue("Mask_Percent", CurCDPercent)
      self.Image_BOXCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
      self.Text_CD:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
      self.Text_CD:SetText(string.format("%1.fs", RemainTime))
    end
  end
  if self.LayerCount and 1 < self.LayerCount then
    self.Text_Buff:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.LayerCount < 100 then
      self.Text_Buff:SetText(tostring(self.LayerCount))
    else
      self.Text_Buff:SetText("99+")
    end
  else
    self.Text_Buff:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local bTempTickCD
  self.Image_CoolDownMask:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.CDDataArray and 0 < self.CDDataArray:Num() then
    local ArrayLength = self.CDDataArray:Num()
    local CDDataStartIndex = math.floor(ArrayLength / 2 + 0.5)
    local CDDuration = self.CDDataArray:Get(0)
    local CDEndTime = self.CDDataArray:Get(CDDataStartIndex)
    local ActiveDuration = 0
    local ActiveEndTime = 0
    if 2 < ArrayLength then
      ActiveDuration = self.CDDataArray:Get(1)
      ActiveEndTime = self.CDDataArray:Get(CDDataStartIndex + 1)
    end
    local ActiveRemainTime = ActiveEndTime - CurServerWorldTime
    local CDRemainTime = CDEndTime - CurServerWorldTime
    if 0 < ActiveRemainTime then
      local ActiveCDPercent = 1 - ActiveRemainTime / ActiveDuration
      if 0 < ActiveCDPercent and ActiveCDPercent < 1 then
        DynamicCDMaterial:SetScalarParameterValue("Mask_Percent", ActiveCDPercent)
        self.Image_BOXCDBar:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        self.Text_CD:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        self.Text_CD:SetText(string.format("%1.fs", ActiveRemainTime))
      end
    elseif 0 < CDRemainTime then
      bTempTickCD = true
      local InCDPercent = 1 - CDRemainTime / CDDuration
      if 0 < InCDPercent and InCDPercent < 1 then
        self.Image_CoolDownMask:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        local DynamicCDMaskMaterial = self.Image_CoolDownMask:GetDynamicMaterial()
        if DynamicCDMaskMaterial then
          DynamicCDMaskMaterial:SetScalarParameterValue("Mask_Percent", InCDPercent)
        end
      end
    end
  end
  if self.bTickCD ~= bTempTickCD then
    if not bTempTickCD then
      EventSystem:postEvent(EVENTTYPE_INGAME_BUFF, EVENTID_INGAME_BUFF_BTN_CD_FINISH, self.BuffID)
    end
    self.bTickCD = bTempTickCD
  end
end
function IngameBuffItemUI:AutoShowBuffDesc()
  print(bWriteLog and "-IngameBuffItemUI:AutoShowBuffDesc - BuffID:", self.BuffID)
  self.AutoShowBuffDesctime = 10
  self:ShowBuffDesc()
  self.AutoShowBuffDescTimer = self:AddTimer(self.AutoShowBuffDesctime, function()
    print(bWriteLog and "-IngameBuffItemUI:AutoShowBuffDesc - AutoHide, BuffID:", self.BuffID)
    self:HideBuffDesc()
  end)
end
function IngameBuffItemUI:AdjustDescPosition()
  local BuffListUI = UIManager.GetUI(UIManager.UI_Config_InGame.BuffList)
  local OffsetX = 1
  local OffsetY = 1
  if BuffListUI and BuffListUI.UIRoot and BuffListUI.BuffListBox then
    if self.bAdabptLocation then
      local USlateBlueprintLibrary = import("SlateBlueprintLibrary")
      local BoxSize = USlateBlueprintLibrary.GetLocalSize(BuffListUI.BuffListBox:GetCachedGeometry())
      local UIUtil = require("client.common.ui_util")
      local BtnLocalPos = UIUtil.GetWidgetViewportPos(self.Object, 0, 0)
      local CenterPos = BtnLocalPos + BoxSize / 2
      local ViewSize = UIUtil.GetViewportSize()
      local ViewScale = UIUtil.GetViewportScale()
      OffsetX = CenterPos.X / (ViewSize.X / ViewScale)
      OffsetY = CenterPos.Y / (ViewSize.Y / ViewScale)
    end
    local SelfIndex = BuffListUI.BuffListBox:GetChildIndex(self)
    local BuffNum = BuffListUI.BuffListBox:GetChildrenCount()
    print(bWriteLog and "IngameBuffItemUI:AdjustDescPosition", OffsetX, OffsetY, SelfIndex, BuffNum, self.bAdabptLocation)
    self:HideAllDesc()
    if OffsetX <= 0.5 then
      if OffsetY <= 0.45 then
        self.Image_RightLine:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.CanvasPanel_DescDown:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.CanvasPanel_DescDown.Slot:SetPosition(DownRightPos)
      elseif SelfIndex == 0 then
        self.CanvasPanel_DescUp.Slot:SetPosition(UpPos)
        self.CanvasPanel_DescUp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_RightLine:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.CanvasPanel_DescUp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.CanvasPanel_DescUp.Slot:SetPosition(UpRightPos)
      end
    elseif OffsetY <= 0.45 then
      self.Image_LeftLine:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_DescDown:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_DescDown.Slot:SetPosition(DownLeftPos)
    elseif SelfIndex == 0 then
      self.CanvasPanel_DescUp.Slot:SetPosition(UpPos)
      self.CanvasPanel_DescUp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_LeftLine:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_DescUp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_DescUp.Slot:SetPosition(UpLeftPos)
    end
  end
end
function IngameBuffItemUI:HideAllDesc()
  self.CanvasPanel_DescDown:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.CanvasPanel_DescUp:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Image_RightLine:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Image_LeftLine:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, IngameBuffItemUI)