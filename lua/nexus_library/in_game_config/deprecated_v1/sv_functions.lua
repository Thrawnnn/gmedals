util.AddNetworkString("Nexus:IGC:UpdateValue")
function Nexus:SaveValue(addon, id, value, dontNetwork)
    local data = file.Read("nexus_settings.txt", "DATA") or ""
    data = util.JSONToTable(data) or {}
    data[addon] = data[addon] or {}
    data[addon][id] = value

    if not dontNetwork then
        net.Start("Nexus:IGC:UpdateValue")
        net.WriteString(addon)
        net.WriteString(id)
        net.WriteString(value)
        net.Broadcast()
    end

    file.Write("nexus_settings.txt", util.TableToJSON(data))
end

util.AddNetworkString("Nexus:IGC:SelectOption")
net.Receive("Nexus:IGC:SelectOption", function(len, ply)
    if not Nexus:GetValue("nexus-config-admins")[ply:GetUserGroup()] and not Nexus.Admins[ply:GetUserGroup()] then return end

    local addon, id, data = net.ReadString(), net.ReadString(), net.ReadString()
    Nexus.Config.Addons[addon].Options[id].onComplete(data)

    Nexus:Notify(ply, 0, 3, "Success!")
end)

util.AddNetworkString("Nexus:IGC:NetworkFull")
hook.Add("Nexus:FullyLoaded", "Nexus:IGC:Loaded", function(ply)
    local data = file.Read("nexus_settings.txt", "DATA") or ""
    data = util.JSONToTable(data) or {}
    
    local temp = {}
    for addon, v in pairs(data) do
        if Nexus.Config.Addons[addon] then
            temp[addon] = {}

            for str, value in pairs(v) do
                if Nexus.Config.Addons[addon].Options[str] then
                    local stop = Nexus.Config.Addons[addon].Options[str].dontNetwork
                    if not stop then
                        temp[addon][str] = value
                    end
                end
            end
        end
    end

    local compressedData = util.Compress(util.TableToJSON(temp))

    net.Start("Nexus:IGC:NetworkFull")
    net.WriteUInt(#compressedData, 32)
    net.WriteData(compressedData, #compressedData)
    net.Send(ply)
end)
