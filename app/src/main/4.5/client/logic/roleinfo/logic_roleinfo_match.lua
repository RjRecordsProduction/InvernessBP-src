local RoleInfoMatchSystem = {}
local model_type = {
  solo_model = 1,
  double_model = 2,
  team_model = 3,
  all_model = 4
}
function RoleInfoMatchSystem.Release()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  RoleInfoSystem.CareerCombatTotalInfoList = {}
  RoleInfoSystem.FPPCCombatTotalInfoList = {}
end
function RoleInfoMatchSystem.SetEmpty()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  for i = 1, 4 do
    if i == 4 then
      RoleInfoSystem.MatchCombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = ""
      }
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = ""
      }
    else
      RoleInfoSystem.MatchCombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = "",
        role_toptenrate = "",
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = "",
        role_toptenrate = "",
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
      RoleInfoSystem.MatchCombatGradeInfoList[i] = {
        survive_score = "",
        top1_score = "",
        rating_score = "",
        fight_score = "",
        assist_score = "",
        sum_score = "",
        grade = "0"
      }
      RoleInfoSystem.FPPMCombatGradeInfoList[i] = {
        survive_score = "",
        top1_score = "",
        rating_score = "",
        fight_score = "",
        assist_score = "",
        sum_score = "",
        grade = "0"
      }
    end
  end
  RoleInfoSystem.CareerCombatTotalInfoList = {}
  RoleInfoSystem.FPPCCombatTotalInfoList = {}
  for i = 1, 4 do
    if i == 4 then
      RoleInfoSystem.CareerCombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_allgamenum = ""
      }
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_allgamenum = ""
      }
    else
      RoleInfoSystem.CareerCombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = "",
        role_toptenrate = "",
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = "",
        role_toptenrate = "",
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
    end
  end
end
function RoleInfoMatchSystem.get_role_match_info_rsp(battle_info_no_rank, battle_info_career)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  local role_info, fpp_role_info
  local length = RoleInfoSystem.GetTableLength(model_type)
  local TableUtil = require("common.table_util")
  for i = 1, length do
    if i == model_type.solo_model then
      role_info = battle_info_no_rank.warsolo
      fpp_role_info = battle_info_no_rank.fppsolo
    elseif i == model_type.double_model then
      role_info = battle_info_no_rank.warduo
      fpp_role_info = battle_info_no_rank.fppduo
    elseif i == model_type.team_model then
      role_info = battle_info_no_rank.warsquad
      fpp_role_info = battle_info_no_rank.fppsquad
    elseif i == model_type.all_model then
      role_info = battle_info_no_rank.warall
      fpp_role_info = battle_info_no_rank.warall
    end
    if role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.MatchCombatTotalInfoList[i] = {
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.MatchCombatTotalInfoList[i] = {
          role_totalHurt = role_info.total_hurt,
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_maxsurvivetime = role_info.max_live_time,
          role_avesurvivetime = role_info.avg_live_time,
          role_maxdistance = role_info.max_move,
          role_avedistance = role_info.avg_move,
          role_aveheal = role_info.avg_cure,
          role_aidcount = role_info.rescue_teammates,
          role_score = role_info.rank_rating,
          role_killscore = role_info.kill_rating,
          role_rankscore = role_info.win_rating,
          role_hitrate = role_info.avg_shot_hit_ratio,
          role_critcount = role_info.head_shot_num,
          role_maxkill = role_info.max_kill,
          role_maxdamage = role_info.max_hurt,
          role_avedamage = role_info.avg_hurt,
          role_assist = role_info.total_assist
        }
        if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_winrate = role_info.win_num / role_info.game_num * 100
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_toptenrate = role_info.top10_count / role_info.game_num * 100
        else
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.MatchCombatGradeInfoList[i] = {
          survive_score = role_info.survive_score,
          top1_score = role_info.top1_score,
          rating_score = role_info.rating_score,
          fight_score = role_info.fight_score,
          assist_score = role_info.assist_score,
          sum_score = role_info.sum_score,
          grade = role_info.grade
        }
        local sgrade = role_info.grade
        RoleInfoSystem.MatchCombatGradeInfoList[i].grade = ConvertGrade(sgrade)
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.MatchCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
    if fpp_role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
          role_totalHurt = fpp_role_info.total_hurt,
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio,
          role_maxsurvivetime = fpp_role_info.max_live_time,
          role_avesurvivetime = fpp_role_info.avg_live_time,
          role_maxdistance = fpp_role_info.max_move,
          role_avedistance = fpp_role_info.avg_move,
          role_aveheal = fpp_role_info.avg_cure,
          role_aidcount = fpp_role_info.rescue_teammates,
          role_score = fpp_role_info.rank_rating,
          role_killscore = fpp_role_info.kill_rating,
          role_rankscore = fpp_role_info.win_rating,
          role_hitrate = fpp_role_info.avg_shot_hit_ratio,
          role_critcount = fpp_role_info.head_shot_num,
          role_maxkill = fpp_role_info.max_kill,
          role_maxdamage = fpp_role_info.max_hurt,
          role_avedamage = fpp_role_info.avg_hurt,
          role_assist = fpp_role_info.total_assist
        }
        if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_winrate = fpp_role_info.win_num / fpp_role_info.game_num * 100
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_toptenrate = fpp_role_info.top10_count / fpp_role_info.game_num * 100
        else
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.FPPMCombatGradeInfoList[i] = {
          survive_score = fpp_role_info.survive_score,
          top1_score = fpp_role_info.top1_score,
          rating_score = fpp_role_info.rating_score,
          fight_score = fpp_role_info.fight_score,
          assist_score = fpp_role_info.assist_score,
          sum_score = fpp_role_info.sum_score,
          grade = fpp_role_info.grade
        }
        local sfppgrade = fpp_role_info.grade
        RoleInfoSystem.FPPMCombatGradeInfoList[i].grade = ConvertGrade(sfppgrade)
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPMCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
  end
  RoleInfoSystem.CareerCombatTotalInfoList = {}
  RoleInfoSystem.FPPCCombatTotalInfoList = {}
  for i = 1, length do
    if i == model_type.solo_model then
      role_info = battle_info_career.warsolo
      fpp_role_info = battle_info_career.fppsolo
    elseif i == model_type.double_model then
      role_info = battle_info_career.warduo
      fpp_role_info = battle_info_career.fppduo
    elseif i == model_type.team_model then
      role_info = battle_info_career.warsquad
      fpp_role_info = battle_info_career.fppsquad
    elseif i == model_type.all_model then
      role_info = battle_info_career.warall
      fpp_role_info = battle_info_career.warall
    end
    if role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.CareerCombatTotalInfoList[i] = {
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_allgamenum = role_info.game_num_all
        }
      else
        RoleInfoSystem.CareerCombatTotalInfoList[i] = {
          role_totalHurt = role_info.total_hurt,
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_maxsurvivetime = role_info.max_live_time,
          role_avesurvivetime = role_info.avg_live_time,
          role_maxdistance = role_info.max_move,
          role_avedistance = role_info.avg_move,
          role_aveheal = role_info.avg_cure,
          role_aidcount = role_info.rescue_teammates,
          role_score = role_info.rank_rating,
          role_killscore = role_info.kill_rating,
          role_rankscore = role_info.win_rating,
          role_hitrate = role_info.avg_shot_hit_ratio,
          role_critcount = role_info.head_shot_num,
          role_maxkill = role_info.max_kill,
          role_maxdamage = role_info.max_hurt,
          role_avedamage = role_info.avg_hurt,
          role_assist = role_info.total_assist
        }
        if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
          RoleInfoSystem.CareerCombatTotalInfoList[i].role_winrate = role_info.win_num / role_info.game_num * 100
          RoleInfoSystem.CareerCombatTotalInfoList[i].role_toptenrate = role_info.top10_count / role_info.game_num * 100
        else
          RoleInfoSystem.CareerCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.CareerCombatTotalInfoList[i].role_toptenrate = 0
        end
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.CareerCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.CareerCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
    end
    if fpp_role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.FPPCCombatTotalInfoList[i] = {
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio
        }
        local role_allgamenum = RoleInfoSystem.CareerCombatTotalInfoList[i].role_allgamenum
        RoleInfoSystem.FPPCCombatTotalInfoList[i].      else
        RoleInfoSystem.FPPCCombatTotalInfoList[i] = {
          role_totalHurt = fpp_role_info.total_hurt,
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio,
          role_maxsurvivetime = fpp_role_info.max_live_time,
          role_avesurvivetime = fpp_role_info.avg_live_time,
          role_maxdistance = fpp_role_info.max_move,
          role_avedistance = fpp_role_info.avg_move,
          role_aveheal = fpp_role_info.avg_cure,
          role_aidcount = fpp_role_info.rescue_teammates,
          role_score = fpp_role_info.rank_rating,
          role_killscore = fpp_role_info.kill_rating,
          role_rankscore = fpp_role_info.win_rating,
          role_hitrate = fpp_role_info.avg_shot_hit_ratio,
          role_critcount = fpp_role_info.head_shot_num,
          role_maxkill = fpp_role_info.max_kill,
          role_maxdamage = fpp_role_info.max_hurt,
          role_avedamage = fpp_role_info.avg_hurt,
          role_assist = fpp_role_info.total_assist
        }
        if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
          RoleInfoSystem.FPPCCombatTotalInfoList[i].role_winrate = fpp_role_info.win_num / fpp_role_info.game_num * 100
          RoleInfoSystem.FPPCCombatTotalInfoList[i].role_toptenrate = fpp_role_info.top10_count / fpp_role_info.game_num * 100
        else
          RoleInfoSystem.FPPCCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.FPPCCombatTotalInfoList[i].role_toptenrate = 0
        end
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
    end
  end
  RoleInfoMatchSystem.FormatMatchCombatInfo()
  RoleInfoMatchSystem.FormatCareerCombatInfo()
end
function RoleInfoMatchSystem.FormatMatchCombatInfo()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "RoleInfoMatchSystem FormatMatchCombatInfo")
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    local totalinfo = RoleInfoSystem.MatchCombatTotalInfoList[i]
    totalinfo.role_kd = string.format("%.2f", totalinfo.role_kd)
    totalinfo.role_critrate = string.format("%.1f", totalinfo.role_critrate * 100)
    totalinfo.role_kd_v2 = string.format("%.2f", totalinfo.role_kd_v2)
    if i ~= 4 then
      totalinfo.role_totalHurt = string.format("%.1f", totalinfo.role_totalHurt)
      totalinfo.role_maxsurvivetime = string.format("%.1f", totalinfo.role_maxsurvivetime / 60)
      totalinfo.role_avesurvivetime = string.format("%.1f", totalinfo.role_avesurvivetime / 60)
      totalinfo.role_maxdistance = string.format("%.2f", totalinfo.role_maxdistance / 1000)
      totalinfo.role_avedistance = string.format("%.2f", totalinfo.role_avedistance / 1000)
      totalinfo.role_aveheal = string.format("%.1f", totalinfo.role_aveheal)
      totalinfo.role_winrate = string.format("%.1f", totalinfo.role_winrate)
      totalinfo.role_toptenrate = string.format("%.1f", totalinfo.role_toptenrate)
      totalinfo.role_hitrate = string.format("%.1f", totalinfo.role_hitrate * 100)
      totalinfo.role_avedamage = string.format("%.1f", totalinfo.role_avedamage)
      totalinfo.role_maxdamage = string.format("%.0f", totalinfo.role_maxdamage)
    end
    local fpptotalinfo = RoleInfoSystem.FPPMCombatTotalInfoList[i]
    fpptotalinfo.role_kd = string.format("%.2f", fpptotalinfo.role_kd)
    fpptotalinfo.role_critrate = string.format("%.1f", fpptotalinfo.role_critrate * 100)
    fpptotalinfo.role_kd_v2 = string.format("%.2f", fpptotalinfo.role_kd_v2)
    if i ~= 4 then
      fpptotalinfo.role_totalHurt = string.format("%.1f", fpptotalinfo.role_totalHurt)
      fpptotalinfo.role_maxsurvivetime = string.format("%.1f", fpptotalinfo.role_maxsurvivetime / 60)
      fpptotalinfo.role_avesurvivetime = string.format("%.1f", fpptotalinfo.role_avesurvivetime / 60)
      fpptotalinfo.role_maxdistance = string.format("%.2f", fpptotalinfo.role_maxdistance / 1000)
      fpptotalinfo.role_avedistance = string.format("%.2f", fpptotalinfo.role_avedistance / 1000)
      fpptotalinfo.role_aveheal = string.format("%.1f", fpptotalinfo.role_aveheal)
      fpptotalinfo.role_winrate = string.format("%.1f", fpptotalinfo.role_winrate)
      fpptotalinfo.role_toptenrate = string.format("%.1f", fpptotalinfo.role_toptenrate)
      fpptotalinfo.role_hitrate = string.format("%.1f", fpptotalinfo.role_hitrate * 100)
      fpptotalinfo.role_avedamage = string.format("%.1f", fpptotalinfo.role_avedamage)
      fpptotalinfo.role_maxdamage = string.format("%.0f", fpptotalinfo.role_maxdamage)
    end
  end
  for i = 1, length - 1 do
    local gradeinfo = RoleInfoSystem.MatchCombatGradeInfoList[i]
    gradeinfo.survive_score = string.format("%.1f", gradeinfo.survive_score)
    gradeinfo.top1_score = string.format("%.1f", gradeinfo.top1_score)
    gradeinfo.rating_score = string.format("%.1f", gradeinfo.rating_score)
    gradeinfo.fight_score = string.format("%.1f", gradeinfo.fight_score)
    gradeinfo.assist_score = string.format("%.1f", gradeinfo.assist_score)
    gradeinfo.sum_score = string.format("%.1f", gradeinfo.sum_score)
    local fppgradeinfo = RoleInfoSystem.FPPMCombatGradeInfoList[i]
    fppgradeinfo.survive_score = string.format("%.1f", fppgradeinfo.survive_score)
    fppgradeinfo.top1_score = string.format("%.1f", fppgradeinfo.top1_score)
    fppgradeinfo.rating_score = string.format("%.1f", fppgradeinfo.rating_score)
    fppgradeinfo.fight_score = string.format("%.1f", fppgradeinfo.fight_score)
    fppgradeinfo.assist_score = string.format("%.1f", fppgradeinfo.assist_score)
    fppgradeinfo.sum_score = string.format("%.1f", fppgradeinfo.sum_score)
  end
end
function RoleInfoMatchSystem.FormatCareerCombatInfo()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "RoleInfoMatchSystem FormatCareerCombatInfo")
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    local totalinfo = RoleInfoSystem.CareerCombatTotalInfoList[i]
    totalinfo.role_kd = string.format("%.2f", totalinfo.role_kd)
    totalinfo.role_critrate = string.format("%.1f", totalinfo.role_critrate * 100)
    if totalinfo.role_kd_v2 then
      totalinfo.role_kd_v2 = string.format("%.2f", totalinfo.role_kd_v2)
    end
    if i ~= length then
      totalinfo.role_totalHurt = string.format("%.1f", totalinfo.role_totalHurt)
      totalinfo.role_maxsurvivetime = string.format("%.1f", totalinfo.role_maxsurvivetime / 60)
      totalinfo.role_avesurvivetime = string.format("%.1f", totalinfo.role_avesurvivetime / 60)
      totalinfo.role_maxdistance = string.format("%.2f", totalinfo.role_maxdistance / 1000)
      totalinfo.role_avedistance = string.format("%.2f", totalinfo.role_avedistance / 1000)
      totalinfo.role_aveheal = string.format("%.1f", totalinfo.role_aveheal)
      totalinfo.role_winrate = string.format("%.1f", totalinfo.role_winrate)
      totalinfo.role_toptenrate = string.format("%.1f", totalinfo.role_toptenrate)
      totalinfo.role_hitrate = string.format("%.1f", totalinfo.role_hitrate * 100)
      totalinfo.role_avedamage = string.format("%.1f", totalinfo.role_avedamage)
      totalinfo.role_maxdamage = string.format("%.0f", totalinfo.role_maxdamage)
    end
    local fpptotalinfo = RoleInfoSystem.FPPCCombatTotalInfoList[i]
    fpptotalinfo.role_kd = string.format("%.2f", fpptotalinfo.role_kd)
    fpptotalinfo.role_critrate = string.format("%.1f", fpptotalinfo.role_critrate * 100)
    if fpptotalinfo.role_kd_v2 then
      fpptotalinfo.role_kd_v2 = string.format("%.2f", fpptotalinfo.role_kd_v2)
    end
    if i ~= length then
      fpptotalinfo.role_totalHurt = string.format("%.1f", fpptotalinfo.role_totalHurt)
      fpptotalinfo.role_maxsurvivetime = string.format("%.1f", fpptotalinfo.role_maxsurvivetime / 60)
      fpptotalinfo.role_avesurvivetime = string.format("%.1f", fpptotalinfo.role_avesurvivetime / 60)
      fpptotalinfo.role_maxdistance = string.format("%.2f", fpptotalinfo.role_maxdistance / 1000)
      fpptotalinfo.role_avedistance = string.format("%.2f", fpptotalinfo.role_avedistance / 1000)
      fpptotalinfo.role_aveheal = string.format("%.1f", fpptotalinfo.role_aveheal)
      fpptotalinfo.role_winrate = string.format("%.1f", fpptotalinfo.role_winrate)
      fpptotalinfo.role_toptenrate = string.format("%.1f", fpptotalinfo.role_toptenrate)
      fpptotalinfo.role_hitrate = string.format("%.1f", fpptotalinfo.role_hitrate * 100)
      fpptotalinfo.role_avedamage = string.format("%.1f", fpptotalinfo.role_avedamage)
      fpptotalinfo.role_maxdamage = string.format("%.0f", fpptotalinfo.role_maxdamage)
    end
  end
end
function RoleInfoMatchSystem.RequestMatchBattleInfo()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  local season_id = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  if season_id == nil or zoneId == nil or zoneId == 0 then
    return
  end
  if RoleInfoSystem.RoleMatchCombatInfoGet.ZoneId ~= zoneId or RoleInfoSystem.RoleMatchCombatInfoGet.SeasonId ~= season_id then
    RoleInfoSystem.RoleMatchCombatInfoGet.ZoneId = zoneId
    RoleInfoSystem.RoleMatchCombatInfoGet.SeasonId = season_id
    RoleInfoMatchSystem.send_get_match_history_season_info(RoleInfoSystem.CurShowPlayerInfoUid, season_id, zoneId)
  end
end
function RoleInfoMatchSystem.ProcessMatchInfoError()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  RoleInfoSystem.CareerCombatTotalInfoList = {}
  RoleInfoSystem.FPPCCombatTotalInfoList = {}
  local TableUtil = require("common.table_util")
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.all_model then
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.CareerCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.MatchCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPMCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.CareerCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPCCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
    end
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CareerCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCCombatTotalInfoList)
end
function RoleInfoMatchSystem.send_get_match_history_season_info(uid, season_id, zoneId)
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_history_season_battle_no_rank(tonumber(uid), season_id, zoneId)
end
function RoleInfoMatchSystem.get_match_history_season_info_rsp(res, battle_info)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if res ~= 0 then
    RoleInfoSystem.RoleMatchCombatInfoGet.ZoneId = -1
    RoleInfoSystem.RoleMatchCombatInfoGet.SeasonId = -1
    RoleInfoMatchSystem.ProcessSeasonMatchInfoError()
    return
  end
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  local role_info, fpp_role_info
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.solo_model then
      role_info = battle_info.warsolo
      fpp_role_info = battle_info.fppsolo
    elseif i == model_type.double_model then
      role_info = battle_info.warduo
      fpp_role_info = battle_info.fppduo
    elseif i == model_type.team_model then
      role_info = battle_info.warsquad
      fpp_role_info = battle_info.fppsquad
    elseif i == model_type.all_model then
      role_info = battle_info.warall
      fpp_role_info = battle_info.warall
    end
    if role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.MatchCombatTotalInfoList[i] = {
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.MatchCombatTotalInfoList[i] = {
          role_totalHurt = role_info.total_hurt,
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_maxsurvivetime = role_info.max_live_time,
          role_avesurvivetime = role_info.avg_live_time,
          role_maxdistance = role_info.max_move,
          role_avedistance = role_info.avg_move,
          role_aveheal = role_info.avg_cure,
          role_aidcount = role_info.rescue_teammates,
          role_score = role_info.rank_rating,
          role_killscore = role_info.kill_rating,
          role_rankscore = role_info.win_rating,
          role_hitrate = role_info.avg_shot_hit_ratio,
          role_critcount = role_info.head_shot_num,
          role_maxkill = role_info.max_kill,
          role_maxdamage = role_info.max_hurt,
          role_avedamage = role_info.avg_hurt,
          role_assist = role_info.total_assist
        }
        if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_winrate = role_info.win_num / role_info.game_num * 100
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_toptenrate = role_info.top10_count / role_info.game_num * 100
        else
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.MatchCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.MatchCombatGradeInfoList[i] = {
          survive_score = role_info.survive_score,
          top1_score = role_info.top1_score,
          rating_score = role_info.rating_score,
          fight_score = role_info.fight_score,
          assist_score = role_info.assist_score,
          sum_score = role_info.sum_score,
          grade = role_info.grade
        }
        local sgrade = role_info.grade
        RoleInfoSystem.MatchCombatGradeInfoList[i].grade = ConvertGrade(sgrade)
      end
    else
      local TableUtil = require("common.table_util")
      if i == model_type.all_model then
        RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      else
        RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
        RoleInfoSystem.MatchCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      end
    end
    if fpp_role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = {
          role_totalHurt = fpp_role_info.total_hurt,
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio,
          role_maxsurvivetime = fpp_role_info.max_live_time,
          role_avesurvivetime = fpp_role_info.avg_live_time,
          role_maxdistance = fpp_role_info.max_move,
          role_avedistance = fpp_role_info.avg_move,
          role_aveheal = fpp_role_info.avg_cure,
          role_aidcount = fpp_role_info.rescue_teammates,
          role_score = fpp_role_info.rank_rating,
          role_killscore = fpp_role_info.kill_rating,
          role_rankscore = fpp_role_info.win_rating,
          role_hitrate = fpp_role_info.avg_shot_hit_ratio,
          role_critcount = fpp_role_info.head_shot_num,
          role_maxkill = fpp_role_info.max_kill,
          role_maxdamage = fpp_role_info.max_hurt,
          role_avedamage = fpp_role_info.avg_hurt,
          role_assist = fpp_role_info.total_assist
        }
        if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_winrate = fpp_role_info.win_num / fpp_role_info.game_num * 100
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_toptenrate = fpp_role_info.top10_count / fpp_role_info.game_num * 100
        else
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.FPPMCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.FPPMCombatGradeInfoList[i] = {
          survive_score = fpp_role_info.survive_score,
          top1_score = fpp_role_info.top1_score,
          rating_score = fpp_role_info.rating_score,
          fight_score = fpp_role_info.fight_score,
          assist_score = fpp_role_info.assist_score,
          sum_score = fpp_role_info.sum_score,
          grade = fpp_role_info.grade
        }
        local sfppgrade = fpp_role_info.grade
        RoleInfoSystem.FPPMCombatGradeInfoList[i].grade = ConvertGrade(sfppgrade)
      end
    else
      local TableUtil = require("common.table_util")
      if i == model_type.all_model then
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      else
        RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
        RoleInfoSystem.FPPMCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      end
    end
  end
  RoleInfoMatchSystem.FormatMatchCombatInfo()
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatGradeInfoList)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoMatchSystem.ProcessSeasonMatchInfoError()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.MatchCombatTotalInfoList = {}
  RoleInfoSystem.MatchCombatGradeInfoList = {}
  RoleInfoSystem.FPPMCombatTotalInfoList = {}
  RoleInfoSystem.FPPMCombatGradeInfoList = {}
  local TableUtil = require("common.table_util")
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.all_model then
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.MatchCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.MatchCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.FPPMCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPMCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.MatchCombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPMCombatGradeInfoList)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
return RoleInfoMatchSystem