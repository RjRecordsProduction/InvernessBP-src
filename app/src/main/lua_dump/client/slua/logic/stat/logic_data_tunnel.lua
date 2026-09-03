local logic_data_tunnel = {}
function logic_data_tunnel.OnModePostSwitch(_, __, status)
  log_tree("[WSL] data_tunnel OnModePostSwitch", status)
  if status.current == GameStatus.Fighting then
    if not GameStatus.IsInMainCity() then
      local DisableDTReportInFighting = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableDTReportInFighting", false)
      if DisableDTReportInFighting then
        Client.EnableDataTunnelReport(false)
      end
    end
  else
    Client.EnableDataTunnelReport(true)
  end
end
return logic_data_tunnel