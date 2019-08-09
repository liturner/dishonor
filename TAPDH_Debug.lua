TAPDH.Debug = {}

function TAPDH.Debug.Enable()
  -- TAPDH.Debug.Frame:Show()
end

function TAPDH.Debug.Disable()
  TAPDH.Debug.Frame:Hide()
end

function TAPDH.Debug.OnLoad(self)
  -- print("TAPDH: Frame - OnLoad - " .. self:GetName())
  
  TAPDH.Debug.Frame = self
  TAPDH.Debug.LogHistory = {}
  TAPDH.Debug.LogHistorySize = 0
end

-- Functions
function TAPDH.Debug.Log(event, sourceGUID, sourceName, destGUID, destName, sourceLevel, sourceIsPlayer)
  if(TAPDH_Settings.IsDebugEnabled) then
    TAPDH.Debug.LogHistory[TAPDH.Debug.LogHistorySize + 1] = {event, sourceGUID, sourceName, destGUID, destName, sourceLevel, sourceIsPlayer}
	TAPDH.Debug.LogHistorySize = TAPDH.Debug.LogHistorySize + 1
    print(strjoin(";",event, sourceGUID, sourceName, destGUID, destName, sourceLevel, sourceIsPlayer))
  end
end

function TAPDH.Debug.Print(subject, message)
  if(TAPDH_Settings == nil or TAPDH_Settings.IsDebugEnabled == nil or TAPDH_Settings.IsDebugEnabled) then
    print("|cFF00FF00TAPDH: |r"..subject.." - "..message)
  end
end
