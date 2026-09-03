local ugc_center_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {
  Assistant = 5,
  CreativeCenter = 6,
  ShareEmpower = 9,
  Mail = 10,
  CreatTemplate = 12,
  Grow = 1,
  IncentivePlan = 2,
  School_Video = 3,
  School_Challenge = 9,
  DataCenter = 4,
  BenchmarkAuthor = 7,
  OfficialStory = 8,
  WowEmail_Message = 10,
  WowEmail_Award_Message = 11,
  School = 3,
  Level = 1,
  Mission = 2,
  Video = 1,
  Challenge = 2,
  Mission_Newbie = 1,
  Mission_Daily = 2,
  Mission_Grow = 3,
  Mission_Week = 1,
  Mission_Season = 2,
  Mission_Creative = 1,
  Mission_Achievement = 2,
  Overview = 1,
  Mod = 2,
  Fans = 3,
  CreatorForum = 999,
  Event = 1,
  CreateGuide = 1,
  AiCopilot = 2,
  System = 1,
  Secure = 2
}
ugc_center_reddot_data.local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCCenter,
    types = {
      newCount = 0,
      [RedDotType.CreativeCenter] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.CreativeCenter,
        pages = {
          newCount = 0,
          [RedDotType.Grow] = {
            newCount = 0,
            category = Category.Receive,
            subID = RedDotType.Grow,
            pages = {
              newCount = 0,
              [RedDotType.Level] = {
                newCount = 0,
                category = Category.Receive,
                subID = RedDotType.Grow
              },
              [RedDotType.Mission] = {
                newCount = 0,
                subID = RedDotType.Grow,
                category = Category.Receive,
                pages = {
                  newCount = 0,
                  [RedDotType.Mission_Newbie] = {
                    newCount = 0,
                    subID = RedDotType.Grow,
                    category = Category.Receive,
                    instanceId = {_isLeaf = true}
                  },
                  [RedDotType.Mission_Daily] = {
                    newCount = 0,
                    subID = RedDotType.Grow,
                    category = Category.Receive,
                    pages = {
                      newCount = 0,
                      [RedDotType.Mission_Week] = {
                        newCount = 0,
                        subID = RedDotType.Grow,
                        category = Category.Receive,
                        instanceId = {_isLeaf = true}
                      },
                      [RedDotType.Mission_Season] = {
                        newCount = 0,
                        subID = RedDotType.Grow,
                        category = Category.Receive,
                        instanceId = {_isLeaf = true}
                      }
                    }
                  },
                  [RedDotType.Mission_Grow] = {
                    newCount = 0,
                    subID = RedDotType.Grow,
                    category = Category.Receive,
                    pages = {
                      newCount = 0,
                      [RedDotType.Mission_Creative] = {
                        newCount = 0,
                        subID = RedDotType.Grow,
                        category = Category.Receive,
                        instanceId = {_isLeaf = true}
                      },
                      [RedDotType.Mission_Achievement] = {
                        newCount = 0,
                        subID = RedDotType.Grow,
                        category = Category.Receive,
                        instanceId = {_isLeaf = true}
                      }
                    }
                  }
                }
              }
            }
          },
          [RedDotType.IncentivePlan] = {
            newCount = 0,
            subID = RedDotType.IncentivePlan,
            category = Category.Receive,
            pages = {newCount = 0, isDynamic = true}
          },
          [RedDotType.School] = {
            newCount = 0,
            category = Category.Receive,
            subID = RedDotType.CreativeCenter,
            pages = {
              newCount = 0,
              [RedDotType.Video] = {
                newCount = 0,
                subID = RedDotType.School_Video,
                category = Category.Receive
              },
              [RedDotType.Challenge] = {
                newCount = 0,
                subID = RedDotType.School_Challenge,
                category = Category.Receive
              }
            }
          },
          [RedDotType.DataCenter] = {
            newCount = 0,
            category = Category.NewArrivals,
            subID = RedDotType.DataCenter,
            pages = {
              newCount = 0,
              [RedDotType.Overview] = {
                newCount = 0,
                subID = RedDotType.DataCenter,
                category = Category.NewArrivals
              },
              [RedDotType.Mod] = {
                newCount = 0,
                subID = RedDotType.DataCenter,
                category = Category.NewArrivals
              },
              [RedDotType.Fans] = {
                newCount = 0,
                subID = RedDotType.DataCenter,
                category = Category.NewArrivals
              }
            }
          },
          [RedDotType.BenchmarkAuthor] = {
            newCount = 0,
            category = Category.NewArrivals,
            subID = RedDotType.BenchmarkAuthor
          },
          [RedDotType.OfficialStory] = {
            newCount = 0,
            category = Category.NewArrivals,
            subID = RedDotType.OfficialStory
          }
        }
      },
      [RedDotType.Assistant] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.Assistant,
        pages = {
          newCount = 0,
          [RedDotType.CreateGuide] = {
            newCount = 0,
            subID = RedDotType.Assistant,
            category = Category.Receive
          },
          [RedDotType.AiCopilot] = {
            newCount = 0,
            subID = RedDotType.Assistant,
            category = Category.Receive
          }
        }
      },
      [RedDotType.Mail] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.WowEmail_Message,
        pages = {
          newCount = 0,
          [RedDotType.System] = {
            newCount = 0,
            subID = RedDotType.WowEmail_Message,
            category = Category.Receive,
            pages = {
              newCount = 0,
              category = Category.Receive,
              isDynamic = true
            }
          },
          [RedDotType.Secure] = {
            newCount = 0,
            subID = RedDotType.WowEmail_Award_Message,
            category = Category.Receive,
            pages = {
              newCount = 0,
              category = Category.Receive,
              isDynamic = true
            }
          }
        }
      },
      [RedDotType.ShareEmpower] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.ShareEmpower,
        pages = {
          newCount = 0,
          category = Category.Receive,
          isDynamic = true
        }
      },
      [RedDotType.CreatTemplate] = {
        newCount = 0,
        category = Category.NewArrivals,
        subID = RedDotType.CreatTemplate,
        pages = {
          newCount = 0,
          category = Category.NewArrivals,
          isDynamic = true
        }
      }
    }
  }
  return data
end
function ugc_center_reddot_data.InitData()
  if bIsInited then
    return
  end
  bIsInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if RedDot == nil then
    RedDot = super_data.CreateSuperData(data)
  end
  local RedDotManager = require("client.slua.logic.reddot.reddot_manager")
  RedDotManager:Regist(RedDot)
end
function ugc_center_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
end
function ugc_center_reddot_data.GetData(RedDotType)
  if RedDot ~= nil then
    if RedDotType == nil then
      return RedDot
    else
      return RedDot.types[RedDotType]
    end
  end
  return nil
end
function ugc_center_reddot_data.OnLogin()
  log(bWriteLog and "ugc_center_reddot_data OnLogin")
  ugc_center_reddot_data.InitData()
end
function ugc_center_reddot_data.OnLogout()
  log(bWriteLog and "ugc_center_reddot_data OnLogout")
  ugc_center_reddot_data.DestroyData()
end
function ugc_center_reddot_data.GetGrowReddot()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow]
  end
end
function ugc_center_reddot_data.GetLevelRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Level]
  end
end
function ugc_center_reddot_data.UpdateLevelCount(Count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Level].new  end
end
function ugc_center_reddot_data.UpdateCreateGuideCount(Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.Assistant].pages[RedDotType.CreateGuide] then
      RedDot.types[RedDotType.Assistant].pages[RedDotType.CreateGuide].new    end
  end
end
function ugc_center_reddot_data.GetCreateGuideRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.Assistant].pages[RedDotType.CreateGuide]
  end
end
function ugc_center_reddot_data.UpdateAiCopilotCount(Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.Assistant].pages[RedDotType.AiCopilot] then
      RedDot.types[RedDotType.Assistant].pages[RedDotType.AiCopilot].new    end
  end
end
function ugc_center_reddot_data.GetAiCopilotRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.Assistant].pages[RedDotType.AiCopilot]
  end
end
function ugc_center_reddot_data.GetSchoolRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School]
  end
end
local GenVideoData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    subID = RedDotType.School,
    category = reddot_macro.Category.Receive,
    pages = {
      newCount = 0,
      category = reddot_macro.Category.Receive,
      isDynamic = true
    }
  }
  return data
end
local GenSubVideoData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.Receive,
    desc = Desc,
    subID = RedDotType.School,
    instanceId = {_isLeaf = true}
  }
  return data
end
local GenSubVideoDataCreatorForum = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.NewArrivals,
    desc = Desc,
    subID = RedDotType.DataCenter,
    instanceId = {_isLeaf = true}
  }
  return data
end
function ugc_center_reddot_data.GetVideoRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video]
  end
end
function ugc_center_reddot_data.GetVideoSubRedDotData(TabID)
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages ~= nil then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[TabID]
  end
end
function ugc_center_reddot_data.GetVideoSubTabRedDotData(TabID, SubTabID)
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages ~= nil then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[TabID].pages[SubTabID]
  end
end
function ugc_center_reddot_data.AddVideoTabRedDotData(TabID, SubTabID, Desc)
  if RedDot then
  end
end
function ugc_center_reddot_data.UpdateVideoSubRedDotData(TabID, SubTabID, VideoID, bIsShow)
  if RedDot then
  end
end
function ugc_center_reddot_data.UpdateCenterVideoRedDotData(Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School] and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].new    end
  end
end
function ugc_center_reddot_data.GetChallengeRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Challenge]
  end
end
function ugc_center_reddot_data.UpdateChallengeCount(Count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Level].pages[RedDotType.Challenge].new  end
end
function ugc_center_reddot_data.GetMissionRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission]
  end
end
function ugc_center_reddot_data.GetMissionSubRedDotData(TabID)
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID]
  end
end
function ugc_center_reddot_data.GetMissionThirdRedDotData(TabID, SubTabID)
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID] and 0 < SubTabID then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID].pages[SubTabID]
  end
end
function ugc_center_reddot_data.UpdateMissionRedDotData(TabID, SubTabID, MissionID, bIsShow)
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID] then
    if 0 < SubTabID then
      if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID].pages[SubTabID] then
        RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID].pages[SubTabID].instanceId[MissionID] = bIsShow
      end
    else
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.Grow].pages[RedDotType.Mission].pages[TabID].instanceId[MissionID] = bIsShow
    end
  end
end
local GenEventData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.NewArrivals,
    desc = Desc,
    subID = RedDotType.IncentivePlan,
    isDynamicCategory = true
  }
  return data
end
function ugc_center_reddot_data.GetIncentivePlanRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan]
  end
end
function ugc_center_reddot_data.AddEventSubRedDotData(ActID, Desc)
  if RedDot then
    RedDot.groupShow = true
    if not RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID] = GenEventData(Desc or tostring(ActID))
    end
  end
end
function ugc_center_reddot_data.UpdateEventSubActCount(ActID, Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID].new    end
  end
end
function ugc_center_reddot_data.GetEventSubActData(ActID)
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID] ~= nil then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.IncentivePlan].pages[ActID]
  end
end
function ugc_center_reddot_data.SendRemoveEventTlog(ActID)
end
function ugc_center_reddot_data.UpdateRedDotBySA(taskList)
  if taskList == nil or next(taskList) == nil then
    return
  end
  log(bWriteLog and "ugc_center_reddot_data UpdateRedDotBySA")
  local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  local MissionConfig = LogicUGCCenter:GetMissionConfig()
  for key, MissionID in pairs(taskList) do
    local Config = MissionConfig[MissionID]
    if Config then
      if Config.tab_type == Config_UGC_Center.Config_UGC_Center_MissionTabID.NewbieMission then
        ugc_center_reddot_data.UpdateMissionRedDotData(Config.tab_type, 0, MissionID, nil)
      else
        ugc_center_reddot_data.UpdateMissionRedDotData(Config.tab_type, Config.tab_subtype, MissionID, nil)
      end
    end
  end
end
function ugc_center_reddot_data.UpdateDataCenterRedDotData(TabID, Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter].pages[TabID] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter].pages[TabID].new    end
  end
end
function ugc_center_reddot_data.GetDataCenterRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter]
  end
end
function ugc_center_reddot_data.GetOverviewRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter].pages[RedDotType.Overview]
  end
end
function ugc_center_reddot_data.GetModRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter].pages[RedDotType.Mod]
  end
end
function ugc_center_reddot_data.GetFansRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.DataCenter].pages[RedDotType.Fans]
  end
end
function ugc_center_reddot_data.AddCreatorForumRedDotData()
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages ~= nil then
    RedDot.groupShow = true
    if not RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum] = GenSubVideoDataCreatorForum("CreatorForum")
    end
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum].newCount = 1
    end
  end
end
function ugc_center_reddot_data.ReMoveCreatorForumRedDotData()
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages ~= nil and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum] then
    RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum].newCount = 0
  end
end
function ugc_center_reddot_data.GetCreatorForumRedDotData()
  if RedDot and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages ~= nil and RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum] then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.School].pages[RedDotType.Video].pages[RedDotType.CreatorForum].newCount
  end
  return 0
end
function ugc_center_reddot_data.UpdateBenchmarkAuthorCount(Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.BenchmarkAuthor] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.BenchmarkAuthor].new    end
  end
end
function ugc_center_reddot_data.GetBenchmarkAuthorRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.BenchmarkAuthor]
  end
end
function ugc_center_reddot_data.UpdateOfficialStoryCount(Count)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.OfficialStory] then
      RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.OfficialStory].new    end
  end
end
function ugc_center_reddot_data.GetOfficialStoryRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreativeCenter].pages[RedDotType.OfficialStory]
  end
end
function ugc_center_reddot_data.GetMessageRedDot()
  if RedDot then
    return RedDot.types[RedDotType.Mail]
  end
end
function ugc_center_reddot_data.GetSubRedDot(subID)
  if RedDot then
    local redDotType
    if subID == RedDotType.System then
      redDotType = RedDotType.System
    elseif subID == RedDotType.Secure then
      redDotType = RedDotType.Secure
    end
    if redDotType then
      return RedDot.types[RedDotType.Mail].pages[redDotType]
    end
  end
end
function ugc_center_reddot_data.UpdateMailRedDot(MailList)
  local SystemRedDotData = ugc_center_reddot_data.GetSubRedDot(RedDotType.System)
  local SecureRedDotData = ugc_center_reddot_data.GetSubRedDot(RedDotType.Secure)
  if not SystemRedDotData or not SecureRedDotData then
    log(bWriteLog and "ugc_center_reddot_data.UpdateMailRedDot Not Ready")
    return
  end
  if not MailList or not next(MailList) then
    log(bWriteLog and "[v_yibxu] ugc_mail_reddot_data  UpdateRedDot MailList = nil")
    ugc_center_reddot_data.SendMailRedRemoveTLog(SystemRedDotData.pages, {})
    ugc_center_reddot_data.SendMailRedRemoveTLog(SecureRedDotData.pages, {})
    return
  else
    for k, v in pairs(MailList) do
      local mail_id = v.Mail.my_id
      local RedDot
      local redCategory, subID = ugc_center_reddot_data.GetCategoryWithSubId(mail_id)
      if v.UGCMail.SubTab == RedDotType.System then
        RedDot = SystemRedDotData or 0
      elseif v.UGCMail.SubTab == RedDotType.Secure then
        RedDot = SecureRedDotData or 0
      end
      if RedDot then
        if not RedDot.pages[mail_id] then
          RedDot.pages[mail_id] = ugc_center_reddot_data.GenDefaultSubData(subID, redCategory)
        else
          RedDot.pages[mail_id].category = redCategory
          RedDot.pages[mail_id].        end
        if v.Mail.read then
          RedDot.pages[mail_id].newCount = 0
        else
          RedDot.pages[mail_id].newCount = 1
        end
      end
    end
    ugc_center_reddot_data.RemoveNotPlayerClickMailRed(MailList)
  end
end
function ugc_center_reddot_data.RemoveNotPlayerClickMailRed(newMailList)
  if not RedDot then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local NewMailList = {}
  for key, value in pairs(newMailList) do
    NewMailList[value.Mail.my_id] = value
  end
  for _, mail_type in pairs(Config_UGC.Config_UGC_MessageType) do
    local tabData = RedDot.types[RedDotType.Mail].pages[mail_type] or {}
    ugc_center_reddot_data.SendMailRedRemoveTLog(tabData.pages, NewMailList)
  end
end
function ugc_center_reddot_data.SendMailRedRemoveTLog(list, new_list)
  if not list then
    return
  end
  for k, v in pairs(list) do
    if type(v) == "table" and not new_list[k] and v.newCount and v.newCount ~= 0 then
      v.newCount = 0
      log(bWriteLog and "[v_yibxu] ugc_mail_reddot_data DelReddot mail_id = " .. k .. " newCount = 0")
    end
  end
end
function ugc_center_reddot_data.GenDefaultSubData(subID, redType)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = redType or reddot_macro.Category.Other,
    subID = subID,
    instanceId = {_isLeaf = true}
  }
  return data
end
function ugc_center_reddot_data.GetCategoryWithSubId(mailID)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local UGC_Config = require("client/slua/logic/ugc/config_ugc")
  local category = reddot_macro.Category.Other
  local sub_id = RedDotType.WowEmail_Message
  local b_attach = false
  local mail_info = logic_mail.GetMailInfoById(mailID)
  if mail_info then
    if logic_mail_utils.IsWithAttach(mail_info) then
      b_attach = true
      category = reddot_macro.Category.Receive
    end
    sub_id = b_attach and RedDotType.WowEmail_Award_Message or RedDotType.WowEmail_Message
  end
  return category, sub_id
end
function ugc_center_reddot_data.GetShareModRedDotData(mod_id)
  if RedDot then
    if RedDot.types[RedDotType.ShareEmpower].pages[mod_id] then
      return RedDot.types[RedDotType.ShareEmpower].pages[mod_id]
    else
      log(bWriteLog and "ugc_center_reddot_data:GetShareModRedDotData mod_id not found mod_id = " .. mod_id)
    end
  end
end
function ugc_center_reddot_data.UpdateModRedDotData(mod_id, bShow)
  if RedDot and RedDot.types[RedDotType.ShareEmpower] then
    RedDot.types[RedDotType.ShareEmpower].pages[mod_id].instanceId[mod_id] = bShow or nil
  end
end
local GenSubShareModData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.Receive,
    desc = Desc,
    subID = RedDotType.ShareEmpower,
    instanceId = {_isLeaf = true}
  }
  return data
end
function ugc_center_reddot_data.AddShareModRedDotData(mod_id)
  if RedDot and RedDot.types[RedDotType.ShareEmpower] and not RedDot.types[RedDotType.ShareEmpower].pages[mod_id] then
    RedDot.types[RedDotType.ShareEmpower].pages[mod_id] = GenSubShareModData(mod_id)
  end
end
function ugc_center_reddot_data:GetShareEmpowerRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.ShareEmpower]
  end
end
local GenSubCreatTemplateData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.NewArrivals,
    desc = Desc,
    subID = RedDotType.CreatTemplate,
    instanceId = {_isLeaf = true}
  }
  return data
end
local GenCreatTemplateTabData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.NewArrivals,
    subID = RedDotType.CreatTemplate,
    pages = {
      newCount = 0,
      category = reddot_macro.Category.NewArrivals,
      isDynamic = true
    }
  }
  return data
end
function ugc_center_reddot_data.GetTabCreatTemplateRedDotData(tab_id)
  if RedDot then
    if RedDot.types[RedDotType.CreatTemplate].pages[tab_id] then
      return RedDot.types[RedDotType.CreatTemplate].pages[tab_id]
    else
      log(bWriteLog and "ugc_center_reddot_data:GetTabCreatTemplateRedDotData tab_id not found tab_id = " .. tab_id)
    end
  end
end
function ugc_center_reddot_data.GetSubTabCreatTemplateRedDotData(tab_id, sub_tab_id)
  if RedDot then
    if RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id] then
      return RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id]
    else
      log(bWriteLog and "ugc_center_reddot_data:GetTabCreatTemplateRedDotData tab_id not found tab_id = " .. tab_id .. " sub_tab_id = " .. sub_tab_id)
    end
  end
end
function ugc_center_reddot_data.GetTemplateRedDotData(tab_id, sub_tab_id, template_id)
  if not RedDot then
    log(bWriteLog and "ugc_center_reddot_data:GetTemplateRedDotData - RedDot is nil")
    return nil
  end
  local creatTemplateType = RedDot.types[RedDotType.CreatTemplate]
  if not creatTemplateType then
    log(bWriteLog and "ugc_center_reddot_data:GetTemplateRedDotData - CreatTemplate type not found")
    return nil
  end
  local tabData = creatTemplateType.pages[tab_id]
  if not tabData then
    log(bWriteLog and "ugc_center_reddot_data:GetTemplateRedDotData - tab_id not found, tab_id = " .. tostring(tab_id))
    return nil
  end
  local subTabData = tabData.pages[sub_tab_id]
  if not subTabData then
    log(bWriteLog and "ugc_center_reddot_data:GetTemplateRedDotData - sub_tab_id not found, tab_id = " .. tostring(tab_id) .. " sub_tab_id = " .. tostring(sub_tab_id))
    return nil
  end
  local templateData = subTabData.pages[template_id]
  if not templateData then
    log(bWriteLog and "ugc_center_reddot_data:GetTemplateRedDotData - template_id not found, tab_id = " .. tostring(tab_id) .. " sub_tab_id = " .. tostring(sub_tab_id) .. " template_id = " .. tostring(template_id))
    return nil
  end
  return templateData
end
function ugc_center_reddot_data.AddCreatTemplateTabRedDot(tab_id, sub_tab_id, template_id)
  if RedDot and RedDot.types[RedDotType.CreatTemplate] then
    if not RedDot.types[RedDotType.CreatTemplate].pages[tab_id] then
      RedDot.types[RedDotType.CreatTemplate].pages[tab_id] = GenCreatTemplateTabData(tab_id)
    end
    if sub_tab_id then
      if not RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id] then
        RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id] = GenCreatTemplateTabData(sub_tab_id)
      end
      if not RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id].pages[template_id] then
        RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id].pages[template_id] = GenSubCreatTemplateData(template_id)
      end
    elseif not RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[template_id] then
      RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[template_id] = GenSubCreatTemplateData(template_id)
    end
  end
end
function ugc_center_reddot_data.UpdateCreatTemplateRedDotData(tab_id, sub_tab_id, template_id, bShow)
  log(bWriteLog and "ugc_center_reddot_data:UpdateCreatTemplateRedDotData tab_id = " .. tab_id .. ", sub_tab_id = " .. tostring(sub_tab_id) .. ", template_id = " .. template_id .. ", bShow = " .. tostring(bShow))
  if RedDot then
    if sub_tab_id then
      if RedDot.types[RedDotType.CreatTemplate].pages[tab_id] and RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id] and RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id].pages[template_id] then
        RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[sub_tab_id].pages[template_id].instanceId[template_id] = bShow or nil
      end
    elseif RedDot.types[RedDotType.CreatTemplate].pages[tab_id] and RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[template_id] then
      RedDot.types[RedDotType.CreatTemplate].pages[tab_id].pages[template_id].instanceId[template_id] = bShow or nil
    end
  end
end
function ugc_center_reddot_data:GetCreatTemplateRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CreatTemplate]
  end
end
return ugc_center_reddot_data