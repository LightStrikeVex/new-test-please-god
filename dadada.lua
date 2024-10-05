local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local webhookUrl = "https://discord.com/api/webhooks/1292002275899740171/2cupByFKaBMSRKu4ihv3cbtcs-TejHJqnTSeM543KlX1u2VWzq0CxUFJ7p7B5DCQ0fO6"

local function sendToWebhook(playerName, elapsedTime, joinTime, leaveTime, avatarUrl)
    -- Evitar que el script falle si alguno de los datos es nil
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
    
    -- Enviar datos al webhook y manejar errores
    local success, response = pcall(function()
        return HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Error sending to webhook: " .. response) -- Mostrar error en caso de fallo
    end
end

local function onPlayerAdded(player)
    local joinTime = os.date("!%H:%M:%S", os.time())
    local joinTick = tick()

    local success, avatarUrl = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)

    if not success then
        avatarUrl = "" -- Valor por defecto si no se pudo obtener la imagen
    end

    player.AncestryChanged:Connect(function()
        if player.Parent == nil then -- El jugador se ha desconectado
            local leaveTime = os.date("!%H:%M:%S", os.time())
            local leaveTick = tick()
            local timeSpent = math.floor((leaveTick - joinTick) / 60) -- Calcular tiempo en minutos

            sendToWebhook(player.Name, timeSpent, joinTime, leaveTime, avatarUrl)
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
