rd_items.NPCSpawns = {}
rd_items.NPCSpawns["redream_waterlands_3"] = {}

rd_items.CreateNPCs = function()
    local s = rd_items.NPCSpawns[game.GetMap()]
    if s then
        for i,v in pairs(s) do
            local e = ents.Create("redream_shopkeeper")
            e:SetPos(v.pos)
            e:SetAngles(v.ang)
            e.Shop = rd_items.NPCShops[i]
            e:Spawn()
        end
    end
end

hook.Add("InitPostEntity", "rd_items:CreateNPCs", rd_items.CreateNPCs)
