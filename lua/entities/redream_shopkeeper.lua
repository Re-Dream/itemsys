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
			if activator.LookAt then
				activator:LookAt(self, 0.25)
			end
			
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
end
