-- Myam!
p = FindMetaTable("Player")
gMedals = gMedals or {}
gMedals.Config = gMedals.Config or {}

RANK_OFFICER = 1

gMedals.Config = {
    [RANK_OFFICER] = {
        name = "Officer",
        desc = "This is a Default Medal!",
        material = "rank-1.png"
    }
}

function p:GiveMedal(medalEnum)
    self:SetPData(medalEnum, true)
end