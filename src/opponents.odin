package PaddleBattle

OpponentProfile :: struct {
	reactionDelay:   f32,
	maxSpeed:        f32,
	errorFreq:       f32,
	predictionError: f32,
	recoverySpeed:   f32,
	resetPosition:   bool,
	alwaysFollow:    bool, // trumps resetPosition
}

Profile_SlowPoke :: OpponentProfile {
	reactionDelay   = 0.25,
	maxSpeed        = 600.0,
	errorFreq       = 1000,
	predictionError = 15.0,
	recoverySpeed   = 400.0,
	resetPosition   = true,
	alwaysFollow    = true,
}

Profile_Defensive :: OpponentProfile {
	reactionDelay   = 0.275,
	maxSpeed        = 600.0,
	errorFreq       = 1000,
	predictionError = 10.0,
	recoverySpeed   = 600.0,
	resetPosition   = true,
}
