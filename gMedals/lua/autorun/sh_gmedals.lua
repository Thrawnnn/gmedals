-- Myam!
p = FindMetaTable("Player")

gMedals = gMedals or {}
gMedals.Config = gMedals.Config or {}
gMedals.DeafultMedals = gMedals.DeafultMedals or {}

CADET_INSIGNIA = 1
SERGEANT_INSIGNIA = 2
OFFICER_INSIGNIA = 3
MEDAL_HONOR = 4

-- PLEASE PLEASE PLEASE REMEMBER TO CONFIGURE YOUR MEDALS LIKE THIS!
-- E.G If you make a medal named MEDAL_HONOR then don't forget to equivocate it to a number like MEDAL_HONOR = 4 or something!

gMedals.FallBackImage = "achievement.png"

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
        priority = 3,
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
    util.AddNetworkString("UpdateMedals")
    util.AddNetworkString("RemoveMedals")

    function p:GiveMedal(medalEnum)
        self:SetPData(medalEnum, true)
        net.Start("UpdateMedals")
        net.WritePlayer(self)
        net.WriteInt(medalEnum, 8)
        net.Broadcast()
        print("[gMedal Server Logger] Giving medal "..gMedals.Config[medalEnum].name.." (ID# "..gMedals.Config[medalEnum].id..") to player "..self:Nick())
    end
    
    function p:RemoveMedal(medalEnum)
        self:RemovePData(medalEnum)
        net.Start("RemoveMedals")
        net.WritePlayer(self)
        net.WriteInt(medalEnum, 8)
        net.Broadcast()
        print("[gMedal Server Logger] Removing medal "..gMedals.Config[medalEnum].name.." (ID# "..gMedals.Config[medalEnum].id..") from player "..self:Nick())
    end    
end

function p:HasMedal(medalEnum)
    if not IsValid(self) then return false end
    result = self:GetPData(medalEnum, false)
    return result
end