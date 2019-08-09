TAPDH = {}

-- Global Stuff
TAPDH.Globals = {}
TAPDH.Globals.PLAYER_GUID = UnitGUID("player")
TAPDH.Globals.PLAYER_LEVEL = UnitLevel("player")
TAPDH.Globals.ADDON_PREFIX = "TAPDH"
TAPDH.Globals.LastMessage = ""
TAPDH.Settings = {}
TAPDH.Globals.Hostile = {
  ["_DAMAGE"] = true, 
  ["_LEECH"] = true,
  ["_DRAIN"] = true,
  ["_STOLEN"] = true,
  ["_INSTAKILL"] = true,
  ["_INTERRUPT"] = true,
  ["_MISSED"] = true
}

TAPDH.MessageFrame = DEFAULT_CHAT_FRAME

-- Options UI Functions
function TAPDH.OK_Clicked(self)
  TAPDH.Debug.Print("Setting","OK Clicked")
  
  TAPDH_Settings.IsYellEnabled = TAPDH_cbxYell:GetChecked() == 1
  TAPDH_Settings.IsOwnMessagesEnabled = TAPDH_cbxEcho:GetChecked() == 1
  TAPDH_Settings.IsDebugEnabled = TAPDH_cbxDebug:GetChecked() == 1
  
  if(TAPDH_Settings.IsDebugEnabled) then
    TAPDH.Debug.Enable()
  else
    TAPDH.Debug.Disable()
  end
end

function TAPDH.Cancel_Clicked(self)
  TAPDH.Debug.Print("Setting","Cancel Clicked")
end

function TAPDH.Default_Clicked(self)
  TAPDH.Debug.Print("Setting","Default Clicked")
  
  TAPDH_Settings.IsYellEnabled = true
  TAPDH_Settings.IsOwnMessagesEnabled = true
  TAPDH_Settings.IsDebugEnabled = false
end

function TAPDH.OnOptionRefresh(self)
  TAPDH.Debug.Print("Setting","Refresh Triggered")
  
  TAPDH_cbxYell:SetChecked(TAPDH_Settings.IsYellEnabled)
  TAPDH_cbxEcho:SetChecked(TAPDH_Settings.IsOwnMessagesEnabled)
  TAPDH_cbxDebug:SetChecked(TAPDH_Settings.IsDebugEnabled)
  
  if(TAPDH_Settings.IsDebugEnabled) then
    TAPDH.Debug.Enable()
  else
    TAPDH.Debug.Disable()
  end
end

-- Event Handlers
function TAPDH.Checkbutton_OnLoad(checkButton)
    _G[checkButton:GetName() .. "Text"]:SetText(checkButton:GetText())
end

function TAPDH.OnLevelUp(self, level, ...)
  TAPDH.Globals.PLAYER_LEVEL = tonumber(level)
end

function TAPDH.OnAddonLoaded(self, name, ...)
  if name == "Dishonor" then 
    print("|cFF00FF00TAPDH: |rDishonor - Loaded! Type '/Dishonor' for more info")
  
	if TAPDH_Gankers == nil then
	  TAPDH.Debug.Print("Ganker","Initialising TAPDH_Gankers to {}")
	  TAPDH_Gankers = {}
	end
  
    if TAPDH_Settings == nil then
	  TAPDH.Debug.Print("Setting","Initialising TAPDH_Settings to {}")
	  TAPDH_Settings = {}
	end
	
	if TAPDH_Settings.IsYellEnabled == nil then
      TAPDH.Debug.Print("Setting","Initialising IsYellEnabled to true")
      TAPDH_Settings.IsYellEnabled = true
    end
	
	if TAPDH_Settings.IsOwnMessagesEnabled == nil then
      TAPDH.Debug.Print("Setting","Initialising IsOwnMessagesEnabled to true")
      TAPDH_Settings.IsOwnMessagesEnabled = true
    end
	
	if TAPDH_Settings.IsDebugEnabled == nil then
      TAPDH.Debug.Print("Setting","Initialising IsDebugEnabled to false")
      TAPDH_Settings.IsDebugEnabled = false
    end
	
    TAPDH.Debug.Print("Setting","IsYellEnabled == " .. tostring(TAPDH_Settings.IsYellEnabled))
    TAPDH.Debug.Print("Setting","IsOwnMessagesEnabled == " .. tostring(TAPDH_Settings.IsOwnMessagesEnabled))
    TAPDH.Debug.Print("Setting","IsDebugEnabled == " .. tostring(TAPDH_Settings.IsDebugEnabled))
	
	-- The "Main" panel is also the settings UI
	self.name = "Dishonor"	
	self.refresh = function (self) TAPDH.OnOptionRefresh(self); end;
	self.okay = function (self) TAPDH.OK_Clicked(self); end;
	self.cancel = function (self) TAPDH.Cancel_Clicked(self); end;
	self.default = function (self) TAPDH.Default_Clicked(self); end;
	
	InterfaceOptions_AddCategory(self)
		
	SLASH_DISHONOR1 = "/Dishonor"
	SLASH_DISHONOR2 = "/dishonor"
	
    SlashCmdList["DISHONOR"] = function(msg)
	  InterfaceOptionsFrame_OpenToCategory(self)
    end 
	
	if(TAPDH_Settings.IsDebugEnabled) then
      TAPDH.Debug:Enable()
	else
	  TAPDH.Debug:Disable()
    end
  end
end

function TAPDH.UpdateGanker(enemy, minlevel)
  if(TAPDH_Gankers[enemy] == nil) then 
    TAPDH_Gankers[enemy] = {}
	TAPDH_Gankers[enemy].minLevel = 0
	TAPDH.Debug.Print("|cFFFF3333Ganker|r", enemy.."(minLvl:"..tostring(minlevel)..") added to the register")
  end
    
  if minlevel > TAPDH_Gankers[enemy].minLevel then  
    TAPDH_Gankers[enemy].minLevel = minlevel
    TAPDH.Debug.Print("|cFFFF3333Ganker|r", enemy.."(minLvl:"..tostring(minlevel)..") has been updated in the register")
  end
end

function TAPDH.OnAddonMessage(self, prefix, message, channel, sender)
  TAPDH.Debug.Print("CommsIn", prefix .. " " .. sender .. "(" .. channel .. ") " .. message)
  if(prefix == TAPDH.Globals.ADDON_PREFIX and TAPDH.Globals.LastMessage ~= message) then
    if(UnitGUID(sender) ~= TAPDH.Globals.DH_PLAYER_GUID or TAPDH.Settings.IsOwnMessagesEnabled) then
	  -- TAPDH.Debug.Print("CommsIn", message)
	        
	  -- First, get the message code
	  -- - U = Update for Ganker list (might come from normal players not under attack)
	  -- - A = Attack notification
	  
	  messageType, internalMessage = strsplit(";", message, 2)
	  
	  if(messageType == "U") then
	    local enemy, minlevel, junk = strsplit(";", internalMessage, 3)
		TAPDH.UpdateGanker(enemy, tonumber(minlevel))
		TAPDH.MessageFrame:AddMessage("Dishonor: " ..  sender .. " sent updated info on " .. enemy .. "(minLvl-" .. minlevel .. ")", 0.5, 0.0, 0.0)
	  elseif(messageType == "A") then
	    local sourceName, destName, zone, x, y, timeStamp, attackerLvlEstimate, junk = strsplit(";", internalMessage, 8)
	    TAPDH.UpdateGanker(sourceName, tonumber(attackerLvlEstimate))
        TAPDH.MessageFrame:AddMessage("Dishonor: " .. sourceName .. "(minLvl-" .. attackerLvlEstimate .. ")" .. " dishonorably attacked " .. destName .. " in " .. zone .. " at " .. "[" .. x .. " " .. y .. "]", 0.5, 0.0, 0.0)
	  else
		TAPDH.Debug.Print("|cFFFF3333CommsIn|r", "Invalid Message! Ignored!")
	  end

	  TAPDH.Globals.LastMessage = message 
    end
  end
end

function TAPDH.IsGankAttack(sourceGUID, platesDbEntry, gankerDbEntry)
  local playerInfo = GetPlayerInfoByGUID(sourceGUID)
  local isPlayer = playerInfo ~= nil
  
  TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","GetPlayerInfoByGUID="..strjoin(";",GetPlayerInfoByGUID(sourceGUID)))
  
  -- -- Easy check for if is player
  -- if not isPlayer then
    -- return false, -1
  -- end
  
  -- ToDo, use the returned raceFilename  to identify if they are horde

  -- If Plates info available, check if Hostile Player as start
  local isPlatesHostilePlayer = false
  if (platesDbEntry ~= nil) then
    TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","platesDbEntry.reaction="..platesDbEntry.reaction)
	TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","isPlayer="..tostring(isPlayer))
	isPlatesHostilePlayer = platesDbEntry.reaction == "HOSTILE" and isPlayer
	
	if(isPlatesHostilePlayer) then
      TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","Plates + GetPlayerInfoByGUID says Hostile Player")
    else
      TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","Plates + GetPlayerInfoByGUID Plates says NPC")
    end
  end
  
  -- If plates have a definate number then the enemy is not a Boss
  if (platesDbEntry ~= nil and platesDbEntry.isBoss == false) then
	TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","Plates says Level")
    return false and isPlatesHostilePlayer, platesDbEntry.level
  else
    TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","Plates says Boss")
    return true and isPlatesHostilePlayer, TAPDH.Globals.PLAYER_LEVEL + 10
  end

  -- GankerDB is a secondary source. The "minLevel" is maintained using the 
  -- plates info
  if (gankerDbEntry ~= nil and gankerDbEntry.minLevel > TAPDH.Globals.PLAYER_LEVEL + 10) then
    TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","GankDB says Boss")
	return true, gankerDbEntry.minLevel
  else
    TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","GankDB says Level")
    return false, gankerDbEntry.minLevel
  end
  
  -- Default is not enough info to decide. Cant call rape without reason . . .
  TAPDH.Debug.Print("|cFFFFFF00Debug:IsGankAttack|r","not enough info, please turn on your name plates!")
  return false
end

function TAPDH.BroadcastGanker(name)
  local messageToSend = strjoin(";", "U", name, TAPDH_Gankers[name].minLevel)
  SendAddonMessage(TAPDH.Globals.ADDON_PREFIX, messageToSend, "RAID")
  SendAddonMessage(TAPDH.Globals.ADDON_PREFIX, messageToSend, "GUILD")
end

function TAPDH.OnCombat(self, timeStamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ... )
  local suffix = event:match(".+(_.-)$")
  
  if(destGUID == TAPDH.Globals.PLAYER_GUID and TAPDH.Globals.Hostile[suffix] and not(sourceName == nil or sourceName == "")) then -- Something hostile affected me
    TAPDH.Debug.Print("|cFF0000AAEnemy|r","============================================")
	TAPDH.Debug.Print("|cFF0000AAEnemy|r","I am being attacked with " .. event)
	-- TAPDH.Debug.Log(event, sourceGUID, sourceName, destGUID, destName, sourceLevel, sourceIsPlayer)
    	
	-- local sourceLevel = "Unknown"
	-- local sourceIsPlayer = "Unknown"
    -- local sourceIsPlayer = tostring(UnitIsPlayer(sourceName) ~= nil)
	-- GetPlayerInfoByGUID(TAPDH.Globals.PLAYER_GUID)

	-- Is the enemy a known Ganker? (even if he is not actually ganking us)
    if(TAPDH_Gankers[sourceName] ~= nil) then
      TAPDH.Debug.Print("|cFFFF3333Ganker|r",sourceName.." is a known Ganker!")
	  
	  -- As we know this is a gank, collect and distribute info
      if(TAPDH.NamePlates.Enemies[sourceName] ~= nil) then
	    TAPDH.Debug.Print("|cFFFF3333Ganker|r",sourceName.." has given us plate information!")
		
		local minPlateLevel = 0
		if(TAPDH.NamePlates.Enemies[sourceName].isBoss) then
		  minPlateLevel = TAPDH.Globals.PLAYER_LEVEL + 10
		else
		  minPlateLevel = tonumber(TAPDH.NamePlates.Enemies[sourceName].level)
		end
		
		TAPDH.Debug.Print("|cFFFFFF00Debug|r","minPlateLevel="..minPlateLevel)
		TAPDH.Debug.Print("|cFFFFFF00Debug|r","TAPDH_Gankers[sourceName].minLevel="..TAPDH_Gankers[sourceName].minLevel)
		
		if minPlateLevel > TAPDH_Gankers[sourceName].minLevel then
		  TAPDH.Debug.Print("|cFFFF3333Ganker|r",sourceName.." info has been shared!")
		  TAPDH_Gankers[sourceName].minLevel = minPlateLevel
		  -- Now send an addon message as we have updated a value
		  -- Allways distribute the information to all channels
		  TAPDH.BroadcastGanker(sourceName)
		end
	  end	  
    end
		
    -- Check to ensure it is actually a gank attack before broadcasting
	-- At this point we must rely on Plates info?
	local isGankAttack, attackerLvlEstimate = TAPDH.IsGankAttack(sourceGUID, TAPDH.NamePlates.Enemies[sourceName], TAPDH_Gankers[sourceName])
    
	TAPDH.Debug.Print("|cFFFFFF00Debug|r","sourceName="..sourceName)
	TAPDH.Debug.Print("|cFFFFFF00Debug|r","TAPDH.NamePlates.Enemies[sourceName].level="..TAPDH.NamePlates.Enemies[sourceName].level)
	TAPDH.Debug.Print("|cFFFFFF00Debug|r","TAPDH.NamePlates.Enemies[sourceName].isBoss="..tostring(TAPDH.NamePlates.Enemies[sourceName].isBoss))
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","zoneId="..zoneId)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","zone="..zone)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","x="..x)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","y="..y)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","timeStamp="..timeStamp)
	TAPDH.Debug.Print("|cFFFFFF00Debug|r","attackerLvlEstimate="..attackerLvlEstimate)
	
	if(isGankAttack) then
      TAPDH.Debug.Print("|cFF0000FFGanker|r",sourceName.. "(minLvl:" .. attackerLvlEstimate .. ") is a ganking you!")
      
	  -- Get pos and convert to 2dp string
	  local fx, fy = GetPlayerMapPosition("player")
      local x = string.format("%.2f", fx * 100)
      local y = string.format("%.2f", fy * 100)
	  SetMapToCurrentZone()
	  local zoneId = GetCurrentMapZone()
	  local continentId = GetCurrentMapContinent()
	  local zone = ({GetMapZones(continentId)})[zoneId]
	  
	  -- Collect other info from the experience (HP, Class, Race etc.)
	  -- local reportLevel = "minLvl:" .. attackerLvlEstimate
      
      -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","sourceName="..sourceName)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","destName="..destName)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","continentId="..continentId)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","zoneId="..zoneId)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","zone="..zone)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","x="..x)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","y="..y)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","timeStamp="..timeStamp)
	  -- TAPDH.Debug.Print("|cFFFFFF00Debug|r","reportLevel="..reportLevel)
	  
      -- local maxHP = UnitHealthMax(sourceName)
      local messageToSend = strjoin(";","A", sourceName, destName, zone, x, y, timeStamp, attackerLvlEstimate)
      SendAddonMessage(TAPDH.Globals.ADDON_PREFIX, messageToSend, "RAID")
      SendAddonMessage(TAPDH.Globals.ADDON_PREFIX, messageToSend, "GUILD")
       
      -- SendChatMessage
      if(TAPDH_Settings.IsYellEnabled) then
        -- print(TAPDH_PrettyPrint(messageToSend))
        SendChatMessage("Dishonor: " .. sourceName ..  " is acting dishonrably at " .. "[" .. x .. " " .. y .. "]" , "YELL")
      end
    end
	TAPDH.Debug.Print("|cFF0000AAEnemy|r","============================================")
  end
end

function TAPDH.OnLoad(self)
  -- print("TAPDH: Frame - OnLoad - " .. self:GetName())
  
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("PLAYER_LEVEL_UP")
  self:RegisterEvent("CHAT_MSG_ADDON")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function TAPDH.OnEvent(self, event, ...)
  TAPDH.Debug.Print("Frame","OnEvent - " .. event)
  
  if(event == "CHAT_MSG_ADDON") then TAPDH.OnAddonMessage(self,unpack({...}))
  elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then TAPDH.OnCombat(self,unpack({...}))
  elseif(event == "PLAYER_LEVEL_UP") then TAPDH.OnLevelUp(self,unpack({...})) 
  elseif(event == "ADDON_LOADED") then TAPDH.OnAddonLoaded(self,unpack({...})) 
  end
end
