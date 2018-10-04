local tag = "bartender"

rd_items.NPCShops[tag] = {
	["model"] = "models/Humans/Group03/Female_01.mdl",
	["name"] = "Bartender",
	["descriptions"] = {
		"Hello, what can I get for you today?"
	},
	["items"] = {
		["beer"] = 100;
	}
}

rd_items.NPCSpawns["redream_waterlands_3"][tag] = {
        pos = Vector(5952.4145507812, 7343.1591796875, -87.96875),
        ang = Angle(0,-90,0)
    }
}