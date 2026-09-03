local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
local default_peakgame_combat = {
  battle_info = {
    game_num = 0,
    win_num = 0,
    top10_count = 0,
    kill_num = 0,
    kd_v2 = 0,
    avg_shot_hit_ratio = 0,
    head_shot_ratio = 0,
    head_shot_num = 0,
    avg_hurt = 0,
    total_hurt = 0,
    max_kill = 0,
    max_hurt = 0,
    total_assist = 0,
    max_move = 0,
    avg_cure = 0,
    avg_live_time = 0,
    avg_move = 0,
    rescue_teammates = 0,
    max_live_time = 0,
    top1_score = 0,
    rating_score = 0,
    assist_score = 0,
    survive_score = 0,
    fight_score = 0,
    sum_score = 0,
    grade = "B",
    rank_rating = PeakGameConfig.DefaultPeakGameRating
  },
  battle_info_format = {
    kd_v2 = function(value)
      return string.format("%.2f", value)
    end,
    head_shot_ratio = function(value)
      return string.format("%.1f%%", value * 100)
    end,
    total_hurt = function(value)
      return string.format("%.1f", value)
    end,
    max_live_time = function(value)
      return string.format("%.1f", value / 60)
    end,
    avg_live_time = function(value)
      return string.format("%.1f", value / 60)
    end,
    max_move = function(value)
      return string.format("%.2fKM", value / 1000)
    end,
    avg_move = function(value)
      return string.format("%.2fKM", value / 1000)
    end,
    avg_cure = function(value)
      return string.format("%.1f", value)
    end,
    avg_shot_hit_ratio = function(value)
      return string.format("%.1f%%", value * 100)
    end,
    avg_hurt = function(value)
      return string.format("%.1f", value)
    end,
    max_hurt = function(value)
      return string.format("%.0f", value)
    end,
    survive_score = function(value)
      return string.format("%.1f", value)
    end,
    top1_score = function(value)
      return string.format("%.1f", value)
    end,
    rating_score = function(value)
      return string.format("%.1f", value)
    end,
    fight_score = function(value)
      return string.format("%.1f", value)
    end,
    assist_score = function(value)
      return string.format("%.1f", value)
    end,
    sum_score = function(value)
      return string.format("%.1f", value)
    end,
    grade = function(value)
      if value == nil then
        return "B"
      end
      return value
    end
  }
}
return default_peakgame_combat