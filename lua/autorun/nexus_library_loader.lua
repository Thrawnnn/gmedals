Nexus = Nexus or {}
Nexus.Config = Nexus.Config or {}

function Nexus:LoadServer(path, bool)
    print("[ Nexus ] "..(bool and "pre-" or "").."loaded sv: "..path)
    include(path)
end

function Nexus:LoadClient(path, bool)
    print("[ Nexus ] "..(bool and "pre-" or "").."loaded cl: "..path)
    if SERVER then
        AddCSLuaFile(path)
    else
        include(path)
    end
end

function Nexus:LoadShared(path, bool)
    print("[ Nexus ] "..(bool and "pre-" or "").."loaded sh: "..path)
    if SERVER then
        AddCSLuaFile(path)
    end
    include(path)
end

function Nexus:LoadFile(path, bool)
    bool = bool or false

    local explode = string.Explode("/", path)
    local fileStr = explode[#explode]

    local fileSide = string.lower(string.Left(fileStr, 3))
    if SERVER and fileSide == "sv_" then
        Nexus:LoadServer(path, bool)
    elseif fileSide == "sh_" then
        Nexus:LoadShared(path, bool)
    elseif fileSide == "cl_" then
        Nexus:LoadClient(path, bool)
    end
end

local filesToLoad = {}
local function GetDirectoryFiles(dir)
    dir = dir.."/"

    local File, Directory = file.Find(dir.."*", "LUA")
    for k, v in ipairs(File) do
        if string.EndsWith(v, ".lua") then
            table.insert(filesToLoad, dir..v)
        end
    end

    for k, v in ipairs(Directory) do
        GetDirectoryFiles(dir..v)
    end
end

function Nexus:LoadDirectory(dir, loadFirst)
    local curTime = CurTime()
    loadFirst = loadFirst or {}
    print("\n\n\n[Nexus] loading directory: "..dir.."\n")

    filesToLoad = {}
    GetDirectoryFiles(dir)

    for _, path in ipairs(loadFirst) do
        Nexus:LoadFile(path, true)
    end

    local formatedFirst = {}
    for _, path in ipairs(loadFirst) do
        formatedFirst[path] = true
    end

    for _, path in ipairs(filesToLoad) do
        if formatedFirst[path] then continue end
        Nexus:LoadFile(path)
    end

    print("\n[Nexus] successfully loaded: "..(CurTime()-curTime).."\n\n\n")
end

Nexus:LoadDirectory("nexus_library")
hook.Run("Nexus:Loaded")