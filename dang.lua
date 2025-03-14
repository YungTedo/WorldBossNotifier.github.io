-- External script (dang.lua)

-- Ensure both mobsToCheck and webhookURL are provided by the main script
if not mobsToCheck then
    error("mobsToCheck configuration is not provided!")
end

if not webhookURL then
    error("webhookURL is not provided!")
end

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Disable streaming
Workspace.StreamingEnabled = false

-- Function to get Server Info
local function getServerInfo()
    local serverInfo = {}

    -- Access GlobalSettings in ReplicatedStorage
    local globalSettings = ReplicatedStorage:WaitForChild("GlobalSettings", 5)  -- Wait up to 5 seconds for GlobalSettings
    if not globalSettings then
        warn("GlobalSettings not found in ReplicatedStorage.")
        return serverInfo
    end

    local serverName = globalSettings:FindFirstChild("ServerName")
    local serverRegion = globalSettings:FindFirstChild("ServerRegion")
    local serverAge = globalSettings:FindFirstChild("ServerAge") -- Assuming ServerAge is in seconds

    if serverName then
        serverInfo.name = serverName.Value
    else
        serverInfo.name = "Unknown Server"
    end

    if serverRegion then
        serverInfo.region = serverRegion.Value
    else
        serverInfo.region = "Unknown Region"
    end

    if serverAge then
        -- Convert server age from seconds to hours (1 hour = 3600 seconds)
        local serverAgeInHours = serverAge.Value / 3600
        serverInfo.age = string.format("%.2f", serverAgeInHours) .. " hours"
    else
        serverInfo.age = "Unknown Age"
    end

    return serverInfo
end

-- Function to check for mobs in Workspace -> Alive
local function checkForMobs()
    local mobsFound = {}

    local aliveFolder = Workspace:FindFirstChild("Alive")

    if aliveFolder then
        print("Found 'Alive' folder. Checking for mobs...")
        for _, mob in ipairs(aliveFolder:GetChildren()) do
            if mobsToCheck.runeGolem and mob.Name:match("^Rune Golem%..*$") then
                print("Rune Golem found: " .. mob.Name)
                mobsFound.runeGolem = true
            elseif mobsToCheck.elderTreant and mob.Name:match("^Elder Treant%..*$") then
                print("Elder Treant found: " .. mob.Name)
                mobsFound.elderTreant = true
            elseif mobsToCheck.motherSpider and mob.Name:match("^Mother Spider%..*$") then
                print("Mother Spider found: " .. mob.Name)
                mobsFound.motherSpider = true
            elseif mobsToCheck.direBear and mob.Name:match("^Dire Bear%..*$") then
                print("Dire Bear found: " .. mob.Name)
                mobsFound.direBear = true
            end
        end
    else
        warn("Alive folder not found in Workspace.")
    end

    return mobsFound
end

-- Function to send the webhook with server info and mob statuses
local function sendWebhook(mobsFound)
    local serverInfo = getServerInfo()  -- Get the latest server info
    local playerCount = #Players:GetPlayers()  -- Get current player count

    local data = {
        ["content"] = "Server Info and Mob Statuses:",  -- Optional: A simple message before the embed
        ["embeds"] = {
            {
                ["title"] = "Server Information",
                ["description"] = "Here is the server information:",
                ["color"] = 16777215,  -- White color
                ["fields"] = {
                    {["name"] = "Server Name", ["value"] = serverInfo.name, ["inline"] = false},
                    {["name"] = "Region", ["value"] = serverInfo.region, ["inline"] = false},
                    {["name"] = "Server Age", ["value"] = serverInfo.age, ["inline"] = false},
                    {["name"] = "Players", ["value"] = tostring(playerCount), ["inline"] = false}
                },
                ["footer"] = {["text"] = "Server Info Webhook"}
            }
        }
    }

    local mobAlerts = {}
    if mobsFound.runeGolem then
        table.insert(mobAlerts, {["title"] = "Rune Golem Found!", ["description"] = "The Rune Golem has been spotted in this server!", ["color"] = 16711680})  -- Red color
    end
    if mobsFound.elderTreant then
        table.insert(mobAlerts, {["title"] = "Elder Treant Found!", ["description"] = "The Elder Treant has been spotted in this server!", ["color"] = 16711680})  -- Red color
    end
    if mobsFound.motherSpider then
        table.insert(mobAlerts, {["title"] = "Mother Spider Found!", ["description"] = "The Mother Spider has been spotted in this server!", ["color"] = 16711680})  -- Red color
    end
    if mobsFound.direBear then
        table.insert(mobAlerts, {["title"] = "Dire Bear Found!", ["description"] = "The Dire Bear has been spotted in this server!", ["color"] = 16711680})  -- Red color
    end

    -- Add mob alerts if any
    if #mobAlerts > 0 then
        for _, alert in ipairs(mobAlerts) do
            table.insert(data["embeds"], alert)
        end

        local jsonData = HttpService:JSONEncode(data)

        -- Send the webhook
        local success, response = pcall(function()
            return http.request({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)

        if success then
            print("Webhook sent successfully!")
        else
            warn("Failed to send webhook: " .. tostring(response))
        end
    else
        print("No mobs found, no webhook sent.")
    end
end

-- The rest of the script remains the same as before, using mobsToCheck and webhookURL
