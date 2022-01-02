local webhook <const> = "https://discord.com/api/webhooks/your-private-key" -- do not share your webhook with others
local mentionStaffRoleId <const> = nil -- will only mention on possible cheating attempt, set to 'nil' for no mentions 

function sendWebhook(name, identifier, type, value, amount, early)
  if not Config.Webhooks.webhooksEnabled then return end

  local winMessage <const> = {
    ["content"] = null,
    ["embeds"] = {
      {
        ["description"] = (type == "item" and ("**" .. name .. "** won " .. amount .. "x " .. value .. " whilst using a scratch ticket!") or ("**" .. name .. "** won $" .. value .. " whilst using a scratch ticket!")),
        ["fields"] = {
          {
            ["name"] = "Identifier",
            ["value"] = identifier
          }
        },
        ["color"] = 11267014, -- https://www.spycolor.com/ Decimal Value
        ["author"] = {
          ["name"] = "[ " .. currentResourceName .. " ]",
          ["url"] = "https://github.com/xDreamLand/dr-scratching"
        },
        ["timestamp"] = os.date("!%Y%m%dT%H%M%S")
      }
    }
  }
  
  local loseMessage <const> = {
    ["content"] = null,
    ["embeds"] = {
      {
        ["description"] = "**" .. name .."** lost whilst using a scratch ticket.",
        ["fields"] = {
          {
            ["name"] = "Identifier",
            ["value"] = identifier
          }
        },
        ["color"] = 16440280, -- https://www.spycolor.com/ Decimal Value
        ["author"] = {
          ["name"] = "[ " .. currentResourceName .. " ]",
          ["url"] = "https://github.com/xDreamLand/dr-scratching"
        },
        ["timestamp"] = os.date("!%Y%m%dT%H%M%S")
      }
    }
  }

  local importantMessage <const> = {
    ["content"] = (mentionStaffRoleId and ("<@&" .. mentionStaffRoleId .. ">") or null),
    ["embeds"] = {
      {
        ["description"] = "**" .. name .. "** triggered the *possible* cheatting attempt.",
        ["fields"] = {
          {
            ["name"] = "Message",
            ["value"] = "`" .. value .. "`."
          },
          {
            ["name"] = "Identifier",
            ["value"] = identifier
          }
        },
        ["color"] = 11088422, -- https://www.spycolor.com/ Decimal Value
        ["author"] = {
          ["name"] = "[ " .. currentResourceName .. " ]",
          ["url"] = "https://github.com/xDreamLand/dr-scratching"
        },
        ["timestamp"] = os.date("!%Y%m%dT%H%M%S")
      }
    }
  }

  local earlyMessage <const> = {
    ["embeds"] = {
      {
        ["description"] = "**" .. name .. "** closed out early without scratch the whole ticket. (**" .. name .. "** " .. amount .. "x " .. value .. ")",
        ["fields"] = {
          {
            ["name"] = "Identifier",
            ["value"] = identifier
          }
        },
        ["color"] = 15774330, -- https://www.spycolor.com/ Decimal Value
        ["author"] = {
          ["name"] = "[ " .. currentResourceName .. " ]",
          ["url"] = "https://github.com/xDreamLand/dr-scratching"
        },
        ["timestamp"] = os.date("!%Y%m%dT%H%M%S")
      }
    }
  }

  if early == 'early' then
    if Config.Webhooks.logProperties.earlyMessage then
      webHookMessage = earlyMessage
    else
      return
    end
  elseif type == 'money' then
    if tonumber(value) == 0 and Config.Webhooks.logProperties.loseMessages then
      webHookMessage = loseMessage
    elseif tonumber(value) > 0 and Config.Webhooks.logProperties.winMessages then
      webHookMessage = winMessage
    else
      return
    end
  elseif type == "item" and Config.Webhooks.logProperties.winMessages then
    webHookMessage = winMessage
  elseif type == "important" and Config.Webhooks.logProperties.possibleCheatingAttempt then
    webHookMessage= importantMessage
  else
    return
  end

  PerformHttpRequest(webhook, function(err, text, headers)
  end, 'POST', json.encode(webHookMessage), {['Content-Type'] = 'application/json'})
end