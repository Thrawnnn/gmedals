-- Myam!
local p = FindMetaTable("Player")

gMedals = gMedals or {}
gMedals.Config = gMedals.Config or {}
gMedals.DeafultMedals = gMedals.DeafultMedals or {}

CADET_INSIGNIA = 1
SERGEANT_INSIGNIA = 2
OFFICER_INSIGNIA = 3
MEDAL_HONOR = 4
IRON_CROSS = 5

-- PLEASE PLEASE PLEASE REMEMBER TO CONFIGURE YOUR MEDALS LIKE THIS!
-- E.G If you make a medal named MEDAL_HONOR then don't forget to equivocate it to a number like MEDAL_HONOR = 4 or something!

gMedals.FallBackImage = "achievement.png"
gMedals.ButtonSound = "buttons/lightswitch2.wav" -- the sound that should play when pressing a button in the editor

gMedals.Config = {
    [CADET_INSIGNIA] = {
        name = "Cadet",
        desc = "The rank insignia of an Cadet.",
        id = 1,
        priority = 1,
        material = Material("rank-1.png"),
        editorMat = "rank-1.png"
    },

    [SERGEANT_INSIGNIA] = {
        name = "Sergeant",
        desc = "The rank insignia of an Sergeant.",
        id = 2,
        priority = 2,
        material = Material("rank-2.png"),
        editorMat = "rank-2.png"
    },

    [OFFICER_INSIGNIA] = {
        name = "Officer",
        desc = "The rank insignia of an Officer.",
        id = 3,
        priority = 3,
        material = Material("rank-3.png"),
        editorMat = "rank-3.png"
    },

    [MEDAL_HONOR] = {
        name = "Medal Of Honor",
        desc = "The medal of Honor",
        id = 4,
        priority = 4,
        material = Material("allied-star.png"),
        editorMat = "allied-star.png"
    },
}

--[[
Configuration Documentation:

Example:

[UNIQUE_ID] = {
    name = "YOUR_NAME_HERE",
    desc = "Your Description here.",
    material = Material("YOUR_MATERIAL_PATH_HERE"),
    editorMat = "YOUR_MATERIAL_PATH_HERE" -- MUST be a string, this cannot be a IMaterial() because it is for the VGUI Editor!
    priority = NUMBER,
    id = NUMBER,
    width = NUMBER, -- Used for modifying the Width of the badge above the head
    height = NUMBER, -- Used for modifying the height of the badge above the head
    color = Color(255,255,255,255) -- Color Variable for the color that the badge should have
}

]]


if SERVER then -- no real reason to really have this *probably*
    util.AddNetworkString("SYNC_MEDALS_ADD")
    util.AddNetworkString("SYNC_MEDALS_REMOVE")
    util.AddNetworkString("SYNC_MEDALS_SPAWN")

    net.Receive("SYNC_MEDALS_ADD", function()
        local medal = net.ReadInt(8)
        local ply = net.ReadPlayer()

        ply:SetPData(medal, true)
        ply:SetNWBool(medal, true)
    end)

    net.Receive("SYNC_MEDALS_REMOVE", function()
        local medal = net.ReadInt(8)
        local ply = net.ReadPlayer()
    
        ply:RemovePData(medal)
        ply:SetNWBool(medal, false)
        print("Removed medal PData for", medal, "from player", ply:Nick(), "PData now:", ply:GetPData(medal))
    end)
    
   hook.Add("PlayerInitialSpawn", "SYNC_MEDALS_ONSPAWN", function(ply)
        print("PlayerInitialSpawn for", ply:Nick())
        for enum, v in pairs(gMedals.Config) do
            if ply:GetPData(enum, false) then
                ply:GiveMedal(enum)
                ply:SetPData(enum, true)
                print("Re-adding medal", enum, "to player", ply:Nick())
            else
                print("Not adding medal", enum, "to player", ply:Nick())
            end
        end
    end)
    
end

function p:GiveMedal(medalEnum)
    self:SetNWBool(medalEnum, true)
    print("[gMedals Logger] Giving medal "..gMedals.Config[medalEnum].name.." (ID# "..gMedals.Config[medalEnum].id..") to player "..self:Nick())
end

function p:RemoveMedal(medalEnum)
    self:SetNWBool(medalEnum, false)
    print("[gMedals Logger] Removing medal "..gMedals.Config[medalEnum].name.." (ID# "..gMedals.Config[medalEnum].id..") from player "..self:Nick())
end

function p:HasMedal(medalEnum)
    if not IsValid(self) then return false end
    result = self:GetNWBool(medalEnum, false)
    return result
end
