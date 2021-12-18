currentResourceName = GetCurrentResourceName()
debugIsEnabled = GetConvarInt(('%s-debugMode'):format(currentResourceName), 0) == 1

function DebugPrint(...)
  if not debugIsEnabled then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^1[%s]^2(debugmode)^3%s^0'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end

function Print(...)
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^1[%s]^8(IMPORTANT)^3%s^0'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end