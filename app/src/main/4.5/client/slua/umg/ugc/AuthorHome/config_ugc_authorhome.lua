local Config_UGC_AuthorHome = {}
local _TabID = {
  Main = 1,
  Mod = 2,
  Honor = 3
}
Config_UGC_AuthorHome.Clocal _MainPage = {
  TabID = _TabID.Main,
  NameKey = 79534,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.MainPage
    })
  end,
  Module = "UGC_AuthorHomePage"
}
local _ModPage = {
  TabID = _TabID.Mod,
  NameKey = 79535,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.ModPange
    })
  end,
  Module = "UGC_AuthorModPage"
}
local _HonorPage = {
  TabID = _TabID.Honor,
  NameKey = 79536,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.HonorPage
    })
  end,
  Module = "UGC_AuthorHonorPage"
}
local _Tab = {
  _MainPage,
  _ModPage,
  _HonorPage
}
Config_UGC_AuthorHome.Clocal _HonorGroupID = {
  All = 0,
  HonorCreate = 8,
  HonorSeason = 9
}
Config_UGC_AuthorHome.Clocal _HonorAll = {
  ID = _HonorGroupID.All,
  NameKey = 79552,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.HonorAll
    })
  end
}
local _HonorCreate = {
  ID = _HonorGroupID.HonorCreate,
  NameKey = 79553,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.HonorCreate
    })
  end,
  OpenFun = function()
    return false
  end
}
local _HonorSeason = {
  ID = _HonorGroupID.HonorSeason,
  NameKey = 79554,
  TlogFun = function()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    Logic_UGC_TLog:ReportAuthorHomeClick({
      source = UGCMacros.Enum_UGC_AuthorHomeClick_Type.HonorSeason
    })
  end,
  OpenFun = function()
    return false
  end
}
local _HonorTab = {
  _HonorAll,
  _HonorCreate,
  _HonorSeason
}
Config_UGC_AuthorHome.Clocal _HonorSortID = {Sort = 1, Time = 2}
Config_UGC_AuthorHome.Clocal _HonorSortType = {
  [1] = {
    ID = _HonorSortID.Sort,
    NameKey = 79555
  },
  [2] = {
    ID = _HonorSortID.Time,
    NameKey = 79556
  }
}
Config_UGC_AuthorHome.Clocal _ModTabID = {_Pub_time = 1, _Play_cnt = 2}
local _ModTab = {
  [1] = {
    ID = _ModTabID._Pub_time,
    NameKey = 79564,
    SKey = "update_date"
  },
  [2] = {
    ID = _ModTabID._Play_cnt,
    NameKey = 79565,
    SKey = "play_cnt"
  }
}
Config_UGC_AuthorHome.Creturn Config_UGC_AuthorHome