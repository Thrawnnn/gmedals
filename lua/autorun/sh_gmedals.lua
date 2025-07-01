local p = FindMetaTable("Player")

gMedals = gMedals or {}
gMedals.Config = gMedals.Config or {}

CADET_INSIGNIA = 1
SERGEANT_INSIGNIA = 2
OFFICER_INSIGNIA = 3
MEDAL_HONOR = 4
IRON_CROSS = 5

gMedals.FallBackImage = "achievement.png"
gMedals.ButtonSound = "buttons/lightswitch2.wav" -- the sound that should play when pressing a button in the editor

if SERVER then 
    util.AddNetworkString('ADD_NEW_MEDAL')
    util.AddNetworkString('REMOVE_MEDAL')
    util.AddNetworkString('ResetConfig')
    util.AddNetworkString('RELOAD_CONFIG')
end

list.Set( "DesktopWindows", "gMedals", {
	title = "gMedals",
	icon = "gmedals.png",
	init = function( icon, window )
		LocalPlayer():ConCommand('gmedal_edit')
	end
} )

net.Receive('RELOAD_CONFIG', function()
    gMedals.NewConfig = ReloadConfig()
end)

function ReloadConfig()
    if  not file.Exists('gmedals-config.json', 'DATA') then
        file.Write('gmedals-config.json', util.TableToJSON(gMedals.Config,true))
        tbl = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))
    else
        tbl = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))
    end
    return tbl
end



net.Receive('ResetConfig', function()
    file.Delete('gmedals-config.json')
end)

net.Receive('ADD_NEW_MEDAL', function()
        curConfig = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))
        local nameVal = net.ReadString()
        local descVal = net.ReadString()
        local idVal = net.ReadUInt(32)
        local materialVal = net.ReadString()
        local editorMatVal = materialVal
        local colorVal = net.ReadColor()

        local newMedal = {
            [0] = {
                name = nameVal,
                desc = descVal,
                id = idVal,
                material = materialVal,
                editorMat = editorMatVal,
                priority = idVal,
                
                width = 250,
                height = 250, 
                color = colorVal
            }
        }

        table.Add(curConfig, newMedal)
        file.Write('gmedals-config.json', util.TableToJSON(curConfig, true))

        net.Start('RELOAD_CONFIG')
        net.Broadcast()

        print('Exported!')
end)


net.Receive('REMOVE_MEDAL', function()
    net.Start('RELOAD_CONFIG')
    net.Broadcast()
    gMedals.NewConfig = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))

    local MedalToRemove = net.ReadInt(32) -- Use this to remove based on the ID of the medal

    for k,v in ipairs(gMedals.NewConfig) do
     medal = k
         if v.id == MedalToRemove then
             tblUpdate = gMedals.NewConfig
             table.remove(tblUpdate, medal)
             print(v.id)
             file.Write('gmedals-config.json', util.TableToJSON(tblUpdate, true))
             PrintTable(tblUpdate)
         end
    end

    net.Start('RELOAD_CONFIG')
    net.Broadcast()

    print("Destroyed!")
 end)
 
 gMedals.Config = { -- default medals, I wouldn't recommend editing these if you're just adding a new medal, you can do that in game.
     [CADET_INSIGNIA] = {
         name = "Cadet",
         desc = "The rank insignia of a Cadet.",
         id = 1,
         priority = 1,
         material = Material("rank-1.png"),
         editorMat = "rank-1.png"
     },
 
     [SERGEANT_INSIGNIA] = {
         name = "Sergeant",
         desc = "The rank insignia of a Sergeant.",
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
     util.AddNetworkString("GMEDALS_INIT_MESSAGE")
 
     net.Receive("SYNC_MEDALS_ADD", function()
         local medal = net.ReadUInt(9)
         local ply = net.ReadPlayer()
 
        ply:GiveMedal(medal)
     end)
 
     net.Receive("SYNC_MEDALS_REMOVE", function()
         local medal = net.ReadUInt(9)
         local ply = net.ReadPlayer()
     
        ply:RemoveMedal(medal)
     end)
     
    hook.Add("PlayerInitialSpawn", "SYNC_MEDALS_ONSPAWN", function(ply)
         for enum, v in ipairs(gMedals.NewConfig) do
             if ply:GetPData(enum, false) then
                 ply:GiveMedal(enum)
                 ply:SetPData(enum, true)
             end
         end
         net.Start("GMEDALS_INIT_MESSAGE")
         net.Send(ply)
     end)
     
 end

 function p:GiveMedal(medalEnum)
    self:SetPData('medal_'..medalEnum, true)
    self:SetNWBool(medalEnum, true)
end

function p:RemoveMedal(medalEnum)
    self:RemovePData('medal_'..medalEnum)
    self:SetNWBool(medalEnum, false)

    print(self:GetPData('meda_'..medalEnum))
end

function p:HasMedal(medalEnum)
    if not IsValid(self) then return false end
    return self:GetPData('medal_'..medalEnum, false)
end

 if  not file.Exists('gmedals-config.json', 'DATA') then
    file.Write('gmedals-config.json', util.TableToJSON(gMedals.Config,true))
    gMedals.NewConfig = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))
    PrintTable(gMedals.NewConfig)
else
    gMedals.NewConfig = util.JSONToTable(file.Read('gmedals-config.json', 'DATA'))
    PrintTable(gMedals.NewConfig)
end

if CLIENT then
    net.Receive("GMEDALS_INIT_MESSAGE", function()
        chat.AddText( Color(249, 63, 63, 255), "[gMedals]", Color(37, 150, 190), " This server is running gMedals the Simple Awards Addon by Thrawn.")
        chat.AddText( Color(249, 63, 63, 255), "[gMedals]", Color(37, 150, 190), " Powered by Nexus UI.")
    end)
end

