-- Configuration to select which mobs to check
local mobsToCheck = {
    runeGolem = true,  -- Set to true to check for Rune Golem
    elderTreant = true,  -- Set to true to check for Elder Treant
    motherSpider = true,  -- Set to true to check for Mother Spider
    direBear = true,  -- Set to true to check for Dire Bear
}

local webhookURL = "https://discord.com/api/webhooks/1232386144629690550/FboiAC4boH4N1LmRYOkXskBPNn5vWyZNpGOpOGyq80Mrsj1ubjus3d-5FjJjlwu-ocKl"

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

-- Function to send Webhook with server info and mob statuses
local function sendWebhook(mobsFound)
    local serverInfo = getServerInfo()  -- Get the latest server info
    local playerCount = #Players:GetPlayers()  -- Get current player count

    local data = {
        ["content"] = "@everyone Server Info and Mob Statuses:",  -- Optional: A simple message before the embed
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

        -- Use http.request to send the data
        if http and http.request then
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
            warn("Executor does not support HTTP requests.")
        end
    else
        print("No mobs found, no webhook sent.")
    end
end

-- Function to continuously check for mobs every few seconds
local function continuouslyCheckForMobs()
    -- Check instantly first
    local mobsFound = checkForMobs()
    sendWebhook(mobsFound)  -- Send the webhook once mobs are found

    -- Then continue checking every 30 seconds
    while true do
        print("Checking for mobs...")
        -- Wait a small time before checking again (e.g., 30 seconds)
        wait(30)

        -- Check if any mobs have spawned
        mobsFound = checkForMobs()
        sendWebhook(mobsFound)  -- Send the webhook once mobs are found
    end
end

-- Main execution when the script runs
local function execute()
    print("Script is executing...")
    -- Start checking for the mobs continuously
    continuouslyCheckForMobs()
end

-- Run the function immediately upon script execution
execute()
