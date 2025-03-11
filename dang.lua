-- External script (dang.lua)

-- This assumes mobsToCheck is passed to the script already
if not mobsToCheck then
    error("mobsToCheck configuration is not provided!")
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

-- You can now call checkForMobs() or any other functionality, and it will use the external mobsToCheck configuration
