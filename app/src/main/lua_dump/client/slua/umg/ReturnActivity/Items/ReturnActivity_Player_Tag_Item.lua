local ReturnActivity_Player_Tag_Item = {}
function ReturnActivity_Player_Tag_Item:ctor(_, params)
  if params then
    self.uid = params.uid
    self.type = params.type
    self.dir = params.dir
    self.profileData = params.profileData
    self.bShowMask = false
  end
  self.bShow = false
end
function ReturnActivity_Player_Tag_Item:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tag, self.OnClickButton_Tag, self)
end
function ReturnActivity_Player_Tag_Item:OnPostInitialize()
  self:UpdateUI()
end
function ReturnActivity_Player_Tag_Item:SetShowOrHide(bShow)
  self.  local parentUI = self:GetParentUI()
  if parentUI.UIRoot.SizeBox_Return then
    self:SetWidgetVisible(parentUI.UIRoot.SizeBox_Return, bShow)
  end
end
function ReturnActivity_Player_Tag_Item:OnClickButton_Tag()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.uid)
  local years = self:GetShowYears(profile)
  local cfgYears = FuncUtil.Clamp(years, 0, 6)
  local content = ""
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local config = return_activity_macro.TagInfoList[cfgYears]
  if config then
    content = LocUtil.LocalizeResFormat(config.tips_locID[self.type], years)
  end
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, content, self.UIRoot.Button_Tag, self.dir)
end
function ReturnActivity_Player_Tag_Item:SetData(params)
  self.uid = params.uid
  self.type = params.type
  self.dir = params.dir
  self.profileData = params.profileData
  self.bShowMask = false
  self:UpdateUI()
end
function ReturnActivity_Player_Tag_Item:UpdateUI()
  log(bWriteLog and "ReturnActivity_Player_Tag_Item:UpdateUI")
  self:SetShowOrHide(false)
  if self.UIRoot.Image_Mask then
    self:SetWidgetVisible(self.UIRoot.Image_Mask, self.bShowMask == true)
  end
  self.UIRoot.TextBlock_Name:SetText(LocUtil.LocalizeResFormat(773205))
  if not self.profileData then
    if tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
      log(bWriteLog and string.format("ReturnActivity_Player_Tag_Item:UpdateUI, 1 uid:%s", self.uid))
      self.profileData = {
        registertime = DataMgr.registertime,
        dynamic_life_time = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.dynamic_life_time,
        rejoin_start_time = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time
      }
      self:UpdateTagUI()
    else
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(self.uid)
      if profile then
        log(bWriteLog and string.format("ReturnActivity_Player_Tag_Item:UpdateUI, 2 uid:%s", self.uid))
        self.profileData = {
          register_years = profile.register_years,
          registertime = profile.registertime,
          dynamic_life_time = profile.dynamic_life_time,
          rejoin_start_time = profile.rejoin_start_time
        }
        self:UpdateTagUI()
      else
        log(bWriteLog and string.format("ReturnActivity_Player_Tag_Item:UpdateUI, 3 uid:%s", self.uid))
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        local memberInfo = TeamUpNewSystem.GetMemberInfo(self.uid)
        if memberInfo then
          self.profileData = {
            register_years = memberInfo.register_years,
            registertime = memberInfo.register_time,
            dynamic_life_time = memberInfo.dynamic_life_time,
            rejoin_start_time = memberInfo.back_time
          }
          self:UpdateTagUI()
        else
          log(bWriteLog and string.format("ReturnActivity_Player_Tag_Item:UpdateUI, 4 uid:%s", self.uid))
        end
      end
    end
  else
    self:UpdateTagUI()
  end
end
function ReturnActivity_Player_Tag_Item:GetShowYears()
  local years = 0
  if not self.profileData then
    log(bWriteLog and "ReturnActivity_Player_Tag_Item:GetShowYears. return of not profile")
    return years
  end
  if self.profileData.register_years then
    years = self.profileData.register_years
  elseif not self.profileData.registertime then
    years = 0
  else
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local time = self.profileData.registertime
    local day = math.floor((curTime - time) / 86400 + 1)
    local Year = 365
    years = math.floor(day / Year + 0.5)
  end
  return years
end
function ReturnActivity_Player_Tag_Item:UpdateTagUI()
  self:SetShowOrHide(false)
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local bIsRejoin = logic_oldfriend_care.IsRejoinPlayer(self.profileData)
  if bIsRejoin then
    self:SetShowOrHide(true)
  end
end
function ReturnActivity_Player_Tag_Item:SetNameTextColor(color)
  self.UIRoot.TextBlock_Name:SetColorAndOpacity(color)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, ReturnActivity_Player_Tag_Item)