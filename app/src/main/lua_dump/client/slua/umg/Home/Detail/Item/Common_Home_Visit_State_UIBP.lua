local Common_Home_Visit_State_UIBP = {}
function Common_Home_Visit_State_UIBP:LoadIcon(uid)
  local logic_home_visit_count = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_visit_count)
  local visitorData = logic_home_visit_count:GetHomeVisCntByUid(tonumber(uid), false)
  if visitorData and visitorData.visitor_count and visitorData.visitor_count > 0 then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if visitorData.visitor_count > 0 and not visitorData.owner_inst_ids then
      self:SetTexture(self.Image_Icon, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_NotAtHome_png.Home_Icon_NotAtHome_png")
    elseif visitorData.visitor_count > 1 and visitorData.owner_inst_ids then
      self:SetTexture(self.Image_Icon, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_AtHome_png.Home_Icon_AtHome_png")
    elseif visitorData.visitor_count == 1 and visitorData.owner_inst_ids then
      self:SetTexture(self.Image_Icon, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_AtHome_png.Home_Icon_AtHome_png")
    end
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Common_Home_Visit_State_UIBP:LoadIconOther(uid)
  local logic_home_visit_count = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_visit_count)
  local visitorData = logic_home_visit_count:GetHomeVisCntByUid(tonumber(uid), false)
  if visitorData and visitorData.visitor_count and visitorData.visitor_count > 0 then
    if visitorData.owner_inst_ids then
      self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetTexture(self.Image_Icon, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_AtHome_png.Home_Icon_AtHome_png")
    else
      self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_Home_Visit_State_UIBP)