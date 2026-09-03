local Setting_Haptics = require("client.slua.umg.NewSetting.Haptics.Setting_Haptics_Config")
local audio_util = require("client.common.audio_util")
function Setting_Haptics:RegistEvents()
  print(bWriteLog and "Setting_Haptics:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Button_Haptics_High, "OnClicked", self.OnClickMainLabel, self, 2)
  self:AddControlEventByControl(self.UIRoot.Button_Haptics_Low, "OnClicked", self.OnClickMainLabel, self, 1)
  self:AddControlEventByControl(self.UIRoot.Button_Haptics_Close, "OnClicked", self.OnClickMainLabel, self, 0)
  self:AddOnClickedEventByControl(self.UIRoot.Button1, self.OnClickButton1, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button2, self.OnClickButton2, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButton0, self)
  for _, ChildSwich in pairs(self.ChildSwitchConfig) do
    self:AddControlEventByControl(self.UIRoot[ChildSwich.HighButtonName], "OnClicked", self.OnClickChildLabel, self, 3, ChildSwich)
    self:AddControlEventByControl(self.UIRoot[ChildSwich.MiddleButtonName], "OnClicked", self.OnClickChildLabel, self, 2, ChildSwich)
    self:AddControlEventByControl(self.UIRoot[ChildSwich.LowButtonName], "OnClicked", self.OnClickChildLabel, self, 1, ChildSwich)
    self:AddControlEventByControl(self.UIRoot[ChildSwich.CloseButtonName], "OnClicked", self.OnClickChildLabel, self, 0, ChildSwich)
  end
  for _, NormalSwich in pairs(self.NormalSwitchConfig) do
    self:AddControlEventByControl(self.UIRoot[NormalSwich.ButtonName], "OnClicked", self.OnClickNormalSwitch, self, NormalSwich.SwitchName, NormalSwich.SettingConfigKey)
  end
end
function Setting_Haptics:OnClickMainLabel(HapticSwitch)
  audio_util.PlayAudio(sound_config.click_v1)
  local SupportHaptic = Client.GetTMFPTapDeviceSupportFlag() - 1
  print(bWriteLog and "Setting_Haptics:OnClickMainLabel " .. tostring(HapticSwitch) .. " SupportHaptic = " .. tostring(SupportHaptic))
  if not _G.IsEditor and HapticSwitch > SupportHaptic then
    ShowNotice(37100)
    return
  end
  if SupportHaptic < 0 then
    return
  end
  self:RefreshMainLabel(HapticSwitch)
  Client.SetUserTMFPTapEnableFlag(HapticSwitch + 1)
end
function Setting_Haptics:OnClickChildLabel(ChildHapticSwitch, ChildSwich)
  print(bWriteLog and "Setting_Haptics:OnClickChildLabel " .. ChildHapticSwitch)
  audio_util.PlayAudio(sound_config.click_v1)
  self:RefreshChildLabel(ChildHapticSwitch, ChildSwich)
  if ChildHapticSwitch ~= 0 then
    local HapticPara = {
      "84",
      "169",
      "255"
    }
    local sVibratePath = Client.ProjectContentDir() .. "Mod/EvoBase/GeneratorData/VibrateAssets/VibrateSetting.he"
    local InMapData = {
      path = sVibratePath,
      amplitude = HapticPara[ChildHapticSwitch]
    }
    if HapticPara[ChildHapticSwitch] then
      Client.TMFPStartRichTapWithData("63", InMapData)
      print(bWriteLog and "Setting_Haptics:OnClickChildLabel TGPAStartRichTapWithData=" .. HapticPara[ChildHapticSwitch])
    end
  end
end
function Setting_Haptics:OnClickNormalSwitch(SwitchName, SettingKey)
  audio_util.PlayAudio(sound_config.click_v1)
  self:RefreshNormalSwitch(SwitchName, SettingKey, true)
end