-- Variables ====>
-- Engine
S_DrumLibrary = "BFD"
I_seqLength = 16
IndentBeat = 2
Indent = getLength{IndentBeat.."b"}
I_velLimit = 100
timesigupper = 4
timesiglower = 4
I_groove = 0
I_velRandom = 5
I_timeRandom = 2
I_velDep = 0.7 -- velocity depreciation
-- Groove Engine
	I_flamIndent = getLength{"64"}
	--Kick
	B_kickskip3 = false
	B_skipKickonSnare = true

	--Snare
	A_snareHits = {}

	--HH
	I_hhOpen = 0
	I_hhShank = 0
	I_pocket = -2
	I_hhOpenReduc = 100
	I_hhHeavyBeat = 1
	I_hhHeavyAccent = 10
	I_hhredirect = 0
	B_lasthhalt = false

-- Accent Engine
	A_snareGhosts = {}

-- Fill Engine
	B_EarlyEnd = false
	B_lastEarly = true
	I_velFill = 100
	I_velFD = 2 -- fill velocity depreciation
	B_inDrag = false
	-- Length
	I_fillLength = 8
	B_noGroove = true
	-- Structure
	I_fillSnareGhosts = 40
	-- Toms
	I_tomsRange = 100
	B_tomsDown = true
	-- Crash
	B_startCrash = true
	B_endCrash = true
	B_RandomCrash = true
-- <==== Variables