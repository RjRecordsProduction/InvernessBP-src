local Lobby_Home_Door_Entrance_BG_UIBP = {}
function Lobby_Home_Door_Entrance_BG_UIBP:ctor(_, uid, config)
  self.  self.end
function Lobby_Home_Door_Entrance_BG_UIBP:OnInitialize()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.OnInitialize(self)
end
function Lobby_Home_Door_Entrance_BG_UIBP:RegistEvents()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.RegistEvents(self)
end
function Lobby_Home_Door_Entrance_BG_UIBP:OnPostInitialize()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.OnPostInitialize(self)
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:GetOrReqHomeProfile({
    self.uid
  }, function()
    if not self.UIRoot then
      return
    end
    local profile = logic_home_profile:GetHomeProfileByUid(self.uid)
    if not profile then
      log(bWriteLog and string.format("Lobby_Home_Door_Entrance_BG_UIBP:OnPostInitialize profile is nil, uid=%s", tostring(self.uid)))
      self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_0, false)
      return
    end
    if profile.bUnLock or tonumber(self.uid) == tonumber(DataMgr.roleData.uid) then
      if profile.grow_info.prosperity >= self.config.LevelProsperity2 and self.config.LevelProsperity2 ~= 0 then
        self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_0, true)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      elseif profile.grow_info.prosperity >= self.config.LevelProsperity1 and self.config.LevelProsperity1 ~= 0 then
        self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_0, true)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        self:PlayUserWidgetAnimation(self.UIRoot.Anim_Loop, 0, 9999, 0, 1)
      else
        self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_0, false)
      end
    end
  end, false)
end
function Lobby_Home_Door_Entrance_BG_UIBP:OnShow()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.OnShow(self)
end
function Lobby_Home_Door_Entrance_BG_UIBP:OnHide()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.OnHide(self)
end
function Lobby_Home_Door_Entrance_BG_UIBP:OnClose()
  Lobby_Home_Door_Entrance_BG_UIBP.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Home_Door_Entrance_BG_UIBP = class(ui_base, nil, Lobby_Home_Door_Entrance_BG_UIBP)
return CLobby_Home_Door_Entrance_BG_UIBP