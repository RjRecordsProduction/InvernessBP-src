local GSC_SpecialScreen = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_SpecialScreen:ctor()
  self.tempVal = 0
  self.MaxAlien = 0
  self.MidAlien = 0
end
function GSC_SpecialScreen:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(35302))
  local UIAdaptation = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIAdaptation)
  self.MidAlien = UIAdaptation:GetMidAlien()
  self.MaxAlien = UIAdaptation:GetMaxAlien()
  self:SetWidgetVisible(self.UIRoot.Setting_ScreenTips_UIBP, false)
  self:initButton()
end
function GSC_SpecialScreen:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_Alien_add, "OnClicked", self.OnAlienAdd, self)
  self:AddControlEventByControl(itemRoot.Button_Alien_minus, "OnClicked", self.OnAlienMinus, self)
  self:AddControlEventByControl(itemRoot.Slider_Alien, "OnValueChanged", self.OnSliderAlienValueChange, self)
  self:AddControlEventByControl(itemRoot.Button_liuhai, "OnClicked", self.Onliuhai, self)
  self:AddControlEventByControl(itemRoot.Button_wakong, "OnClicked", self.Onwakong, self)
  self:AddControlEventByControl(itemRoot.Btn_screenHelp, "OnClicked", self.ScreenHelp, self)
end
function GSC_SpecialScreen:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.UIRectOffset, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_SpecialScreen:InitButtonName(textblock, alien)
  if not self.AlienList then
    self.AlienList = {}
    local tb = CDataTable.GetTable("ScreenText")
    for k, v in pairs(tb) do
      table.insert(self.AlienList, {
        Offset = v.Offset,
        LocalizeID = v.LocalizeID
      })
    end
    table.sort(self.AlienList, function(a, b)
      return a.Offset < b.Offset
    end)
    log_tree("GSC_SpecialScreen:InitButtonName", self.AlienList)
  end
  local LocalizeID = 47425
  for k, v in pairs(self.AlienList) do
    if alien <= v.Offset then
      LocalizeID = v.LocalizeID
      break
    end
  end
  textblock:SetText(LocUtil.GetLocalizeResStr(LocalizeID))
end
function GSC_SpecialScreen:initButton()
  local itemRoot = self.UIRoot
  local percent = self.MidAlien / self.MaxAlien
  local Slot = itemRoot.VerticalBox_wakong.Slot
  local BeginSlot = itemRoot.VerticalBox_Begin.Slot
  if Slot and BeginSlot then
    local pos = Slot:GetPosition()
    local beginPos = BeginSlot:GetPosition()
    itemRoot.VerticalBox_liuhai.Slot:SetPosition(FVector2D(beginPos.X + (pos.X - beginPos.X) * percent + 2, pos.Y))
  end
  self:InitButtonName(itemRoot.Text_liuhai, self.MidAlien)
  self:InitButtonName(itemRoot.Text_wakong, self.MaxAlien)
end
function GSC_SpecialScreen:UpdateUI(value)
  local itemRoot = self.UIRoot
  local progress = value / self.MaxAlien
  itemRoot.Slider_Alien:SetValue(progress)
  itemRoot.ProgressBar_Alien:SetPercent(progress)
  itemRoot.VeihcleAlienValue:SetText(LocUtil.LocalizeResFormat(10567, value))
end
function GSC_SpecialScreen:OnAlienAdd()
  self:PlayAudio(sound_config.click_v1)
  local value = GraphicSettingDB:GetUIData(GraphicSettingDB.UIRectOffset)
  value = math.min(self.MaxAlien, value + 1)
  self:OnScreenValueChange(value)
end
function GSC_SpecialScreen:OnAlienMinus()
  self:PlayAudio(sound_config.click_v1)
  local value = GraphicSettingDB:GetUIData(GraphicSettingDB.UIRectOffset)
  value = math.max(0, value - 1)
  self:OnScreenValueChange(value)
end
function GSC_SpecialScreen:OnSliderAlienValueChange(value)
  local KismetMathLibrary = import("KismetMathLibrary")
  local value = KismetMathLibrary.FCeil(value * self.MaxAlien)
  self:OnScreenValueChange(value)
end
function GSC_SpecialScreen:Onliuhai()
  self:PlayAudio(sound_config.click_v1)
  self:OnScreenValueChange(self.MidAlien)
end
function GSC_SpecialScreen:Onwakong()
  self:PlayAudio(sound_config.click_v1)
  self:OnScreenValueChange(self.MaxAlien)
end
function GSC_SpecialScreen:ScreenHelp()
  self:PlayAudio(sound_config.click_v1)
  local parent = self:GetParentUI()
  parent:OnShowScreenTips(self.UIRoot.Btn_screenHelp)
end
function GSC_SpecialScreen:OnScreenValueChange(value)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.UIRectOffset, value)
  self:GetParentUI():SetDirty(true)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_SpecialScreen)