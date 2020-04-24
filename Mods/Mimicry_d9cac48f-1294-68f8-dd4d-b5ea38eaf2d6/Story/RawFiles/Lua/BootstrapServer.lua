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
			local diffx = math.abs(rot[7] - rotx)
			local diffz = math.abs(rot[9] - rotz)
			Ext.Print("[Mimicry:ApplyFacingDirection] Diff: ", diffx, diffz)
			if diffx > 1.0 or diffz > 1.0 then
				local forwardVector = {
					-rotx * distanceMult,
					0,
					-rotz * distanceMult,
				}
				x = pos[1] + forwardVector[1]
				z = pos[3] + forwardVector[3]
				y = pos[2]
				--SetStoryEvent("02a77f1f-872b-49ca-91ab-32098c443beb", "LLMIME_Mime_ReApplyFacingDirection")
				--local target = TemporaryCharacterCreateAtPosition(x, y, z, "LeaderLib_SkillDummy_94668062-11ea-4ecf-807c-4cc225cbb236", 0)
				local target = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
				--CharacterSetDetached(target, 1)
				--TeleportToPosition(target, x, y, z, "", 0, 1)
				PlayEffect(uuid, "RS3_FX_Skills_Rogue_Vault_Cast_Overlay_01", "")
				CharacterLookAt(uuid, target, 1)
				Osi.LeaderLib_Timers_StartObjectTimer(target, 250, "LLMIME_Timers_LeaderLib_Commands_RemoveItem", "LeaderLib_Commands_RemoveItem")
				--Osi.LeaderLib_Timers_StartObjectTimer(target, 500, "LLMIME_Timers_LeaderLib_Commands_RemoveTemporaryDummy", "LeaderLib_Commands_RemoveTemporaryDummy")
				--RemoveTemporaryCharacter(target)
				--CharacterFlushQueue(uuid)
				PlayEffectAtPosition("RS3_FX_Skills_Fire_Haste_Impact_Root_01",x,y,z)
				PlayEffectAtPosition("RS3_FX_Skills_Earth_Cast_Aoe_Voodoo_Root_01",x,y,z)
				Ext.Print("[Mimicry:ApplyFacingDirection] Facing direction: ", x, y, z)
				--local rot = character.Stats.Rotation
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