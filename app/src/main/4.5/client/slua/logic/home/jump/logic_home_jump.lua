local logic_home_jump = {}
function logic_home_jump:DefineAndResetData()
end
function logic_home_jump:OnInitialize()
end
function logic_home_jump:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_JUMP_MY_HOME, self.OnJumpMyHome, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PLANPH_GUIDEBOOK, self.OnJumpGuideBook, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PLANPH_DRAWING, self.OnJumpDrawingHall, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PLANPH_CONSOLE, self.OnJumpConsoleUI, self)
end
function logic_home_jump:OnJumpMyHome()
  log(bWriteLog and "logic_home_jump:OnJumpMyHome")
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, nil)
end
function logic_home_jump:OnJumpGuideBook()
  log(bWriteLog and "logic_home_jump:OnJumpGuideBook")
  local logic_home_message_board = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_guidebook)
  logic_home_message_board:ShowGuidePopop()
end
function logic_home_jump:OnJumpDrawingHall()
  log(bWriteLog and "logic_home_jump:OnJumpDrawingHall")
  local gotoFuc = function()
    log(bWriteLog and "logic_home_jump:OnJumpDrawingHall gotoFuc")
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferMapManager:MountMapPak("map_planph_3")
    local cfg = UIManager.UI_Config.PlanPH_DrawingHall_Main_UIBP
    if not cfg then
      log(bWriteLog and "logic_home_jump:OnJumpDrawingHall.cfg is nil")
      return
    end
    if UIManager.IsUIShow(cfg) then
      log(bWriteLog and "logic_home_jump:OnJumpDrawingHall. cfg.moduleName = " .. tostring(cfg.moduleName))
      return
    end
    UIManager.ShowUI(cfg)
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeChildModuleReady(logic_home_download.HomeChileModuleType.HomeShopType, gotoFuc)
end
function logic_home_jump:OnJumpConsoleUI(_, _, params)
  log_tree("params = ", params)
  local cfg = UIManager.UI_Config_InGame.PlanPH_Console_Main_UIBP
  if not cfg then
    log(bWriteLog and "logic_home_jump:OnJumpConsoleUI.cfg is nil")
    return
  end
  local PlanPH_Console_Main_UIBP = UIManager.GetUI(cfg)
  PlanPH_Console_Main_UIBP = PlanPH_Console_Main_UIBP or UIManager.ShowUI(cfg)
  local tab = 1
  if params and params.tab then
    tab = tonumber(params.tab)
  end
  log(bWriteLog and "logic_home_jump:OnJumpConsoleUI. tab = " .. tostring(tab))
  PlanPH_Console_Main_UIBP:OnSelectTab(tab)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_jump = class(CModuleBase, nil, logic_home_jump)
return Clogic_home_jump