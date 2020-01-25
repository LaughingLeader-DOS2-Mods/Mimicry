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

local function apply_overrides(stats)
    for statname,overrides in pairs(stats) do
		for property,value in pairs(overrides) do
			local next_value = value
			Ext.StatSetAttribute(statname, property, next_value)
				Ext.Print("[Mimicry:LLMIME_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. next_value .."\"")
        end
    end
end

local ModuleLoad = function ()
	Ext.Print("[Mimicry:LLMIME_StatOverrides.lua] Module is loading. Applying stat overrides for IgnoreSilence.")
	apply_overrides(skill_overrides)
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("ModuleLoading", ModuleLoad)
else
    Ext.Print("[Mimicry:LLMIME_StatOverrides.lua] [*WARNING*] Extender version is less than v36! Stat overrides ain't happenin', chief.")
end