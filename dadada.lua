local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local webhookUrl = "https://discord.com/api/webhooks/1291955749802741812/U1pc46iFRLhoDbx94YNz2f9S_H_yqK8qlxTTFx_JL9uMpRW7zntnHYExYhRmvOxUEfOK"

local function sendToWebhook(playerName, elapsedTime, joinTime, leaveTime, avatarUrl)
    -- Set default values if any of the variables are nil
    local safeJoinTime = joinTime or "Unknown join time"
    local safeLeaveTime = leaveTime or "Unknown leave time"
    local safeElapsedTime = elapsedTime or 0
    local safeAvatarUrl = avatarUrl or ""

    local data = {
        content = "Time elapsed on site: " .. tostring(safeElapsedTime) .. " minutes.\nRecorded timestamps: " .. safeJoinTime .. " to " .. safeLeaveTime .. " GMT",
        username = playerName,
        avatar_url = safeAvatarUrl
    }

    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
end

local function onPlayerAdded(player)
    local joinTime = os.date("!%H:%M:%S", os.time()) -- Format to GMT
    local joinTick = tick()

    local success, avatarUrl = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)

    if not success then
        avatarUrl = ""
    end

    player.AncestryChanged:Connect(function()
        if player.Parent == nil then
            local leaveTime = os.date("!%H:%M:%S", os.time()) -- Format to GMT
            local leaveTick = tick()
            local timeSpent = math.floor((leaveTick - joinTick) / 60)

            sendToWebhook(player.Name, timeSpent, joinTime, leaveTime, avatarUrl)
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
