-- Myam!
p = FindMetaTable("Player")

gMedals = gMedals or {}
gMedals.Config = gMedals.Config or {}

RANK_OFFICER = 1

gMedals.Config = {
    [CADET_INSIGNIA] = {
        name = "Cadet",
        desc = "This is a Default Medal!",
        material = "rank-1.png"
    },
    [SERGEANT_INSIGNIA] = {
        name = "Sergeant",
        desc = "This is a Default Medal!",
        material = "rank-2.png"
    },
    [OFFICER_INSIGNIA] = {
        name = "Officer",
        desc = "This is a Default Medal!",s
        material = "rank-3.png"
    },
}

function p:GiveMedal(medalEnum)
    self:SetPData(medalEnum, true)
end
