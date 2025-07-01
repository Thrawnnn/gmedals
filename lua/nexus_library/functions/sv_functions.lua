util.AddNetworkString("Nexus:RequestNetworks")
net.Receive("Nexus:RequestNetworks", function(len, ply)
    if ply.Nexus_Requested then return end
    ply.Nexus_Requested = true

    hook.Run("Nexus:FullyLoaded", ply)
end)

util.AddNetworkString("Nexus:ChatMessage")
function Nexus:ChatMessage(ply, tbl)
    net.Start("Nexus:ChatMessage")
    net.WriteUInt(#tbl, 4)
    for _, v in ipairs(tbl) do
        net.WriteType(v)
    end
    net.Send(ply)
end

util.AddNetworkString("Nexus:Notification")
function Nexus:Notify(ply, int, seconds, str)
    if not IsValid(ply) then return end
    net.Start("Nexus:Notification")
    net.WriteString(str)
    net.WriteUInt(int, 2)
    net.WriteUInt(seconds, 5)
    net.Send(ply)
end