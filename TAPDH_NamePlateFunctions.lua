TAPDH.NamePlates = CreateFrame("Frame", nil, WorldFrame)
TAPDH.NamePlates.CurrentChildren = 0
TAPDH.NamePlates.Enemies = {}
-- TAPDH.NamePlates.IsPlate = {}

-- IsFrameNameplate: Checks to see if the frame is a Blizz nameplate
function TAPDH.NamePlates.IsFrameNameplate(frame)
  local region = frame:GetRegions()
  return region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" 
end

-- Returns a list of all visible nameplates
-- function TAPDH.NamePlates.Visible()
  -- WorldFrame.GetChildren
-- end

-- GetUnitReaction: Determines the reaction, and type of unit from the health bar color
-- Credit to TidyPlates for this
function TAPDH.NamePlates.GetUnitReaction(red, green, blue)									
	if red < .01 and blue < .01 and green > .99 then return "FRIENDLY" 
	elseif red < .01 and blue > .99 and green < .01 then return "FRIENDLY"
	elseif red > .99 and blue < .01 and green > .99 then return "NEUTRAL"
	elseif red > .99 and blue < .01 and green < .01 then return "HOSTILE"
	else return "HOSTILE" end
end

-- Update Loop for NamePlates
function TAPDH.NamePlates.OnUpdate()

    for index = 1, select("#", WorldFrame:GetChildren()) do
      plate = select(index, WorldFrame:GetChildren())
      -- print(plate)
      if TAPDH.NamePlates.IsFrameNameplate(plate) then
        
		-- Gather information from the visible frame
        local threatglow, healthborder, castborder, castnostop,
            spellicon, highlight, nameObject, levelObject,
            dangerskull, raidicon, eliteicon = plate:GetRegions()

		local healthBar, castBar = plate:GetChildren()
		local r, g, b = healthBar:GetStatusBarColor()
			
        local name = nameObject:GetText()
        local level = "Unknown"
		local isBoss = dangerskull:IsShown() ~= nil
		
		if(isBoss) then
		  level = TAPDH.Globals.PLAYER_LEVEL + 10
		else
		  level = tonumber(levelObject:GetText())
		end
		
        if(TAPDH.NamePlates.Enemies[name] == nil) then
          -- print(name .. " (" .. level .. ")")
          TAPDH.NamePlates.Enemies[name] = {}
          TAPDH.NamePlates.Enemies[name].level = level
		  TAPDH.NamePlates.Enemies[name].isBoss = isBoss
		  TAPDH.NamePlates.Enemies[name].r = r
		  TAPDH.NamePlates.Enemies[name].g = g
		  TAPDH.NamePlates.Enemies[name].b = b
		  TAPDH.NamePlates.Enemies[name].reaction = TAPDH.NamePlates.GetUnitReaction(r, g, b)
		  
		  if(TAPDH_Gankers[name] ~= nil) then
            TAPDH.Debug.Print("|cFFFF3333Plates|r"," spotted the known ganker "..name.."at minlvl:"..level)
			TAPDH.UpdateGanker(name, level)
			TAPDH.BroadcastGanker(name)
		  end
        end
      end
    end

end

TAPDH.NamePlates:SetScript("OnUpdate", TAPDH.NamePlates.OnUpdate);