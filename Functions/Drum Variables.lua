-- Variables ====>
-- Engine
S_DrumLibrary = "BFD"
IndentBeat = 2
Indent = getLength{IndentBeat.."b"}
I_velocity = 100
timesig = 4
-- Groove Engine
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

-- Fill Engine
	B_EarlyEnd = true
	-- Crash
	B_EndCrash = true
	B_RandomCrash = true
-- <==== Variables