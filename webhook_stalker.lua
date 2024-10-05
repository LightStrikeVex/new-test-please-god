local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local webhookUrl = "https://discord.com/api/webhooks/1291955749802741812/U1pc46iFRLhoDbx94YNz2f9S_H_yqK8qlxTTFx_JL9uMpRW7zntnHYExYhRmvOxUEfOK"

local function sendToWebhook(playerName, elapsedTime, joinTime, leaveTime, avatarUrl)
    local data = {
        content = "Time elapsed on site: " .. elapsedTime .. " minutes.\nRecorded timestamps: " .. joinTime .. " to " .. leaveTime .. " GMT",
        username = playerName,
        avatar_url = avatarUrl
    }

    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
end

local function onPlayerAdded(player)
    local joinTime = os.date("!%H:%M:%S", os.time())
    local joinTick = tick()

    local success, avatarUrl = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)

    if not success then
        avatarUrl = ""
    end
    player.AncestryChanged:Connect(function()
        if player.Parent == nil then
            local leaveTime = os.date("!%H:%M:%S", os.time())
            local leaveTick = tick()
            local timeSpent = math.floor((leaveTick - joinTick) / 60)

            sendToWebhook(player.Name, timeSpent, joinTime, leaveTime, avatarUrl)
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
