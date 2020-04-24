function SaveFacingDirection(uuid)
	local character = Ext.GetCharacter(uuid)
	local rot = character.Stats.Rotation
	Ext.Print("Rotation: ", LeaderLib.Common.Dump(rot))
	Osi.LLMIME_Skills_SaveFacingDirection(uuid, rot[7], rot[9])
	Ext.Print("[Mimicry:SaveFacingDirection] Saved facing direction for ", uuid)
	CharacterStatusText(uuid, "LLMIME_StatusText_FacingDirectionSaved")
end

function ApplyFacingDirection(uuid)
	Ext.Print("[Mimicry:ApplyFacingDirection] Applying facing direction for ", uuid)
	local dbEntry = Osi.DB_LLMIME_Skills_FacingDirection:Get(uuid, nil, nil)
	if dbEntry ~= nil and #dbEntry > 0 then
		local rotx = dbEntry[1][2]
		local rotz = dbEntry[1][3]
		local x,y,z = 0.0,0.0,0.0
		if rotx~= nil and rotz ~= nil then
			local character = Ext.GetCharacter(uuid)
			local pos = character.Stats.Position
			local distanceMult = 2.0
			local rot = character.Stats.Rotation
			local diff = math.abs(rot[7] - rotx) + math.abs(rot[9] - rotz)
			Ext.Print("[Mimicry:ApplyFacingDirection] Diff: ", diff)
			if diff >= 0.01 then
				local forwardVector = {
					-rotx * distanceMult,
					0,
					-rotz * distanceMult,
				}
				x = pos[1] + forwardVector[1]
				z = pos[3] + forwardVector[3]
				y = pos[2]
				local target = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
				CharacterLookAt(uuid, target, 1)
				--PlayEffect(uuid, "RS3_FX_Skills_Rogue_Vault_Cast_Overlay_01", "")
				Osi.LeaderLib_Timers_StartObjectTimer(target, 250, "LLMIME_Timers_LeaderLib_Commands_RemoveItem", "LeaderLib_Commands_RemoveItem")
				Ext.Print("[Mimicry:ApplyFacingDirection] Facing direction: ", x, y, z)
				--PlayEffectAtPosition("RS3_FX_Skills_Fire_Haste_Impact_Root_01",x,y,z)
				--PlayEffectAtPosition("RS3_FX_Skills_Earth_Cast_Aoe_Voodoo_Root_01",x,y,z)
			else
				Ext.Print("[Mimicry:ApplyFacingDirection] Skipping rotation since character facing is the same.")
			end
		else
			Ext.PrintError("[Mimicry:ApplyFacingDirection] Failed: Saved rotation is null:\n"..tostring(LeaderLib.Common.Dump(dbEntry)))
		end
	else
		Ext.PrintError("[Mimicry:ApplyFacingDirection] No saved rotation for mime:\n"..tostring(LeaderLib.Common.Dump(dbEntry)))
	end
end

local function CloneWeapon(mime,item,slot)
	NRD_ItemCloneBegin(item)
	local stat = NRD_ItemGetStatsId(item)
	local statType = NRD_StatGetType(stat)
	if statType == "Weapon" then
		-- Damage type fix
		-- Deltamods with damage boosts may make the weapon's damage type be all of that type, so overwriting the statType
		-- fixes this issue.
		local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
		if damageTypeString == nil then damageTypeString = "Physical" end
		local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
		NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)
	end
	local clone = NRD_ItemClone()
	SetTag(clone, "LLMIME_MIMICKED_WEAPON")
	ItemSetOriginalOwner(clone, mime)
	--CharacterEquipItem(mime, clone)
	NRD_CharacterEquipItem(mime, clone, slot, 0, 0, 0, 1)
	ItemSetCanInteract(clone, 0)
	ItemSetOnlyOwnerCanUse(clone, 1)
	return clone
end
Ext.NewQuery(CloneWeapon, "LLMIME_Ext_QRY_CloneWeapon", "[in](CHARACTERGUID)_Mime, [in](ITEMGUID)_Item, [in](STRING)_Slot, [out](ITEMGUID)_Clone")

local function GetMimeSkillTargetPosition(mimeuuid, caster, x, y, z)
	local mime = Ext.GetCharacter(mimeuuid)
	--local caster = Ext.GetCharacter(casteruuid)
	local pos = mime.Stats.Position
	local rot = mime.Stats.Rotation
	local dist = GetDistanceToPosition(caster, x, y, z)

	local forwardX = -rot[7] * dist
	local forwardZ = -rot[9] * dist
	--Ext.Print("forwardVector:",Ext.JsonStringify(forwardVector))

	local tx = pos[1] + forwardX
	local tz = pos[3] + forwardZ

	return tx, tz
end
Ext.NewQuery(GetMimeSkillTargetPosition, "LLMIME_Ext_QRY_GetMimeSkillTargetPosition", "[in](CHARACTERGUID)_Mime, [in](CHARACTERGUID)_Caster, [in](REAL)_x, [in](REAL)_y, [in](REAL)_z, [out](REAL)_tx, [out](REAL)_tz")


local brawlerWeaponTags = {
	"UNARMED_WEAPON",
	"LLMIME_BrawlerFist",
}

local function IsUnarmedWeapon(weapon)
	if weapon == nil then return true end
	for i,tag in pairs(brawlerWeaponTags) do
		if IsTagged(weapon, tag) == 1 then
			return true
		end
	end
	local stat = NRD_ItemGetStatsId(weapon)
	local statType = NRD_StatGetType(stat)
	--Ext.Print("[LLMIME_Ext_QRY_IsUnarmed] weapon ("..weapon..") stat("..stat..")")
	if statType == "Weapon" then
		if Ext.StatGetAttribute(stat, "AnimType") == "Unarmed" then
			return true
		end
	else
		return true
	end
	return false
end

local function IsUnarmed(character)
	local weapon = CharacterGetEquippedItem(character, "Weapon")
	local offhand = CharacterGetEquippedItem(character, "Shield")
	if weapon == nil and offhand == nil then
		return 1
	else
		if IsUnarmedWeapon(weapon) and IsUnarmedWeapon(offhand) then
			return 1
		end
	end
	--Ext.Print("[LLMIME_Ext_QRY_IsUnarmed] weapon("..tostring(weapon)..") offhand("..tostring(offhand)..")")
	return 0
end
Ext.NewQuery(IsUnarmed, "LLMIME_Ext_QRY_IsUnarmed", "[in](CHARACTERGUID)_Character, [out](INTEGER)_IsUnarmed")

local function SkillRequiresWeapon(skill)
	local useWeaponDamage = Ext.StatGetAttribute(skill, "UseWeaponDamage")
	if useWeaponDamage == "Yes" then
		return true
	end
	local requirement = Ext.StatGetAttribute(skill, "Requirement")
	if (requirement ~= nil and requirement ~= "None" and requirement ~= "") then
		return true
	end
	return false
end

local function SkillRequiresWeapon_QRY(skill)
	if SkillRequiresWeapon(skill) then
		return 1
	end
	return 0
end
Ext.NewQuery(SkillRequiresWeapon_QRY, "LLMIME_Ext_QRY_SkillRequiresWeapon", "[in](STRING)_Skill, [out](INTEGER)_RequiresWeapon")