package PaddleBattle

OpponentProfile :: struct {
	reactionDelay:   f32,
	maxSpeed:        f32,
	predictionError: f32,
	recoverySpeed:   f32,
	resetPosition:   bool,
}

Profile_SlowPoke :: OpponentProfile {
	reactionDelay   = 0.0,
	maxSpeed        = 400.0,
	predictionError = 0.0,
	recoverySpeed   = 400.0,
	resetPosition   = true,
}

Profile_Defensive :: OpponentProfile {
	reactionDelay   = 0.175,
	maxSpeed        = 600.0,
	predictionError = 10.0,
	recoverySpeed   = 600.0,
	resetPosition   = true,
}
