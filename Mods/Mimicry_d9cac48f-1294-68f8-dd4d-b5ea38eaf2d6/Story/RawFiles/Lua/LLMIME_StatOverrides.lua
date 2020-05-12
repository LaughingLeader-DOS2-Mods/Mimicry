local skill_overrides = {
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes"
	},
	Shout_InspireStart = {
		IgnoreSilence = "Yes"
	},
	Shout_RecoverArmour = {
		IgnoreSilence = "Yes"
	},
	Shout_FleshSacrifice = {
		IgnoreSilence = "Yes"
	},
	Cone_Flamebreath = {
		IgnoreSilence = "Yes"
	},
	Shout_PlayDead = {
		IgnoreSilence = "Yes"
	},
	Target_PetrifyingTouch = {
		IgnoreSilence = "Yes"
	},
	Teleportation_ResurrectScroll = {
		IgnoreSilence = "Yes"
	},
	Teleportation_StoryModeFreeResurrect = {
		IgnoreSilence = "Yes"
	},
}

local weaponex_additions = {
	Shout_LLMIME_EvasiveManeuver = {
		Description = "Shout_LLMIME_EvasiveManeuver_WeaponExpansion_Description"
	},
	Target_LLMIME_DisarmingBlow = {
		Description = "Target_LLMIME_DisarmingBlow_WeaponExpansion_Description"
	},
	LLMIME_COUNTER_THROW = {
		Description = "LLMIME_COUNTER_THROW_WeaponExpansion_Description"
	},
}

local function apply_overrides(stats)
    for statname,overrides in pairs(stats) do
		for property,value in pairs(overrides) do
			local next_value = value
			Ext.StatSetAttribute(statname, property, next_value)
				Ext.Print("[Mimicry:LLMIME_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. next_value .."\"")
        end
    end
end

local function ModuleLoading()
	Ext.Print("[Mimicry:LLMIME_StatOverrides.lua] Module is loading. Applying stat overrides.")
	apply_overrides(skill_overrides)

	--WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f
	if Ext.IsModLoaded("c60718c3-ba22-4702-9c5d-5ad92b41ba5f") then
		apply_overrides(weaponex_additions)
	end

	-- Mods like DU may override these status types.
	Ext.StatSetAttribute("LLMIME_DECOY_DISABLED", "StatusType", "INCAPACITATED")
	Ext.StatSetAttribute("LLMIME_LAUNCHED_DISABLE", "StatusType", "INCAPACITATED")
	Ext.StatSetAttribute("LLMIME_DOPPELGANGER", "StatusType", "INCAPACITATED")
	-- Divinity Unleashed
	if Ext.IsModLoaded("e844229e-b744-4294-9102-a7362a926f71") then
		--Ext.StatSetAttribute("Stats_LLMIME_DecoyCharacter", "DodgeBoost", 0)
		--Ext.StatSetAttribute("Stats_LLMIME_DecoyCharacter", "AccuracyBoost", 0)
	end
end

Ext.RegisterListener("ModuleLoading", ModuleLoading)