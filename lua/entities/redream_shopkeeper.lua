ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

if SERVER then
    ENT.Shop = rd_items.NPCShops["bartender"]

	function ENT:Initialize()
		self:SetModel(self.Shop.model)
		self:SetHullType(HULL_HUMAN);
		self:SetHullSizeNormal();
		self:SetNPCState(NPC_STATE_SCRIPT)
		self:SetSolid(SOLID_BBOX) 
		self:SetMoveType(MOVETYPE_STEP)
		self:SetUseType(SIMPLE_USE)
		self:CapabilitiesAdd(bit.bor(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD), CAP_AIM_GUN))
		self:SetMaxYawSpeed(5000)
	end
	
	function ENT:AcceptInput(name, activator, caller)
		if name == "Use" and IsValid(caller) and caller:IsPlayer() then
			net.Start("rd_items:GUI")
				net.WriteTable(self.Shop)
				net.WriteEntity(self)
			net.Send(activator)
			
			--Smooth Lookup Animation
			activator:LookAt(self, 0.25)
			
			--Say hi
			local snds = rd_items.VoiceLines[self:GetGender()]
			if not snds then
				print("no sounds exist, not playing sound")
			else
				self:EmitSound(snds.talk[math.random(1, #snds.talk)])
			end
		end
	end
	
	function ENT:OnTakeDamage(dmg)
		local atk = dmg:GetAttacker()
		
		local snds = rd_items.VoiceLines[self:GetGender()]
		if not snds then
			print("no sounds exist, not playing sound")
		else
			self:EmitSound(snds.hurt[math.random(1, #snds.hurt)])
		end
		
		timer.Simple(1, function()
			if IsValid(atk) and atk:IsPlayer() and atk:Health() > 0 then
				atk:Kill()
				if IsValid(atk:GetRagdollEntity()) then
					atk:GetRagdollEntity():SetName("ragdoll_" .. atk:EntIndex())
				end
				atk:EmitSound(rd_items.Sounds.explode[math.random(1, #rd_items.Sounds.explode)])
				
				--create lightning effect
				local effect = EffectData()
				effect:SetOrigin(atk:GetPos())
				effect:SetStart(self:GetPos())
				effect:SetEntity(atk)
				effect:SetMagnitude(100)
				util.Effect("TeslaHitBoxes", effect, true, true)
				
				--dissolve ragdoll
				local dissolve = ents.Create("env_entity_dissolver");
				dissolve:SetPos(atk:GetPos())
				dissolve:SetKeyValue("magnitude", 1000)
				dissolve:SetKeyValue("dissolveType", 0)
				dissolve:Spawn()
				dissolve:Fire("Dissolve", atk:GetRagdollEntity():GetName(), 0)
				dissolve:Fire("Kill", "", 0.1)
				timer.Simple(1, function()
					if IsValid(dissolve) then
						dissolve:Remove()
					end
				end)
			end
		end)
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Draw()
		self:DrawModel()
	end
	
	net.Receive("rd_items:GUI", function()
		local info = net.ReadTable()
		local ent = net.ReadEntity()
		--Create gui based on table
		--TODO: Separate this into its own file
		local shopframe = vgui.Create("DFrame")
		shopframe:SetSize(600, 300)
		shopframe:SetTitle("")
		shopframe:Center()
		shopframe:MakePopup()
		shopframe:SetAlpha(0)
		shopframe:AlphaTo(255, .25, 0)
		shopframe.Close = function(self)
			self:AlphaTo(0, .25, 0, function()
				gui.EnableScreenClicker(false)
				shopframe:Remove()
			end)
		end
		
		local namelabel = vgui.Create("DLabel", shopframe)
		namelabel:SetFont("Trebuchet24")
		namelabel:SetSize(600, 30)
		namelabel:SetPos(90, 35)
		namelabel:SetText(info.name)
		
		local personmdlpanel = vgui.Create("SpawnIcon", shopframe)
		personmdlpanel:SetPos(20, 40)
		personmdlpanel:SetSize(64, 64)
		personmdlpanel:SetModel(ent:GetModel())
		personmdlpanel:SetToolTip("")
		
		local desc = vgui.Create("DLabel", shopframe)
		desc:SetPos(20, 100)
		desc:SetSize(600, 30)
		desc:SetFont("Trebuchet24")
		desc:SetText(info.descriptions[math.random(1, #info.descriptions)])
		
		local scroll = vgui.Create("DScrollPanel", shopframe)
		scroll:SetPos(200, 150)
		scroll:SetSize(380, 130)
		
		local iconlayout = vgui.Create("DIconLayout", scroll)
		iconlayout:Dock(FILL)
		
        if info.items and next(info.items) ~= nil then
            for i,v in pairs(info.items) do
                local itemTable = rd_items.GetItem(i)
                if itemTable then
                    local it = iconlayout:Add("DPanel")
                    it:SetSize(380, 50)
                    
                    local ic = vgui.Create("SpawnIcon", it)
                    ic:SetSize(46, 46)
                    ic:SetPos(2, 2)
                    ic:SetToolTip("Click to buy item!")
                    ic:SetModel(itemTable.rd_model)
                    
                    local itemname = vgui.Create("DLabel", it)
                    itemname:SetPos(50, 0)
					itemname:SetSize(200, 20)
                    itemname:SetDark(1)
                    itemname:SetFont("Trebuchet18")
                    itemname:SetText(itemTable.rd_name .. " (¢" .. string.Comma(tostring(v)) .. ")")

                    local itemdesc = vgui.Create("DLabel", it)
                    itemdesc:SetPos(50, 10)
					itemdesc:SetSize(200, 20)
                    itemdesc:SetDark(1)
                    itemdesc:SetFont("Trebuchet18")
                    itemdesc:SetText(itemTable.rd_desc)

					ic.DoClick = function(self)
						--[[
						net.Start("rd_items:BuyItem")
						net.WriteString(i)
						net.WriteEntity(ent)
						net.SendToServer()
						]]
						local m = DermaMenu()
						m:AddOption("Buy x1", function()
							net.Start("rd_items:BuyItem")
							net.WriteString(i)
							net.WriteEntity(ent)
							net.WriteInt(1, 32)
							net.SendToServer()
						end)
						m:AddOption("Buy Multiple", function()
							Derma_StringRequest(
								"Shopkeeper",
								"How many " .. itemTable.rd_name .. "s do you want to buy?",
								"",
								function(result)
									local n = tonumber(result) or 5

									Derma_Query(
										"Are you sure you want to buy " .. tostring(n) .. "x " .. itemTable.rd_name .. " for ¢" .. string.Comma(tostring(n * v)) .. "?",
										"Shopkeeper",
										"Yes",
										function()
											net.Start("rd_items:BuyItem")
											net.WriteString(i)
											net.WriteEntity(ent)
											net.WriteInt(n, 32)
											net.SendToServer()
										end,
										"No",
										function() end --Do nothing.
									)
								end,
								function()end
							)
						end)
						m:Open()
					end
                end
            end
        end
	end)
end
