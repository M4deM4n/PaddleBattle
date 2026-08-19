package PaddleBattle

import "core:math"
import "core:math/rand"
import "types"

AiState :: struct {
	profile:       OpponentProfile,
	posY:          f32,
	targetY:       f32,
	reactionTimer: f32,
	reactionDelay: f32,
	errFreqTimer:  f32,
	isTracking:    bool,
}

initAI :: proc(game: ^types.Game) {
	aiState = {
		profile    = Profile_SlowPoke,
		posY       = game.paddles[player2].position.y,
		isTracking = true,
	}
}

predictTrajectory :: proc(game: ^types.Game) -> f32 {
	timeToImpact :=
		(game.paddles[player2].position.x - game.ball.position.x) / game.ball.position.x
	futureY := game.ball.position.y + (game.ball.velocity.y * timeToImpact)

	wrappedY := math.mod(futureY, 2.0 * game.screen.y)
	if wrappedY < 0.0 {
		wrappedY += 2.0 * game.screen.y
	}

	if wrappedY > game.screen.y {
		return 2.0 * game.screen.y - wrappedY
	}

	return wrappedY
}

updateAi :: proc(game: ^types.Game, ai: ^AiState, dt: f32) {
	// calculate destination Y
	if game.ball.velocity.x > 0.0 {

		ai.reactionTimer += dt
		ai.errFreqTimer += dt

		if ai.reactionTimer >= ai.reactionDelay {
			ai.isTracking = true
			perfectTarget := predictTrajectory(game)

			errorOffset: f32 = 0
			if ai.errFreqTimer >= ai.profile.errorFreq {
				errorOffset = (rand.float32_range(-5.0, 5.0)) * ai.profile.predictionError
				ai.errFreqTimer = 0
			}

			ai.targetY = math.clamp(perfectTarget + errorOffset, 0.0, game.screen.y)
			ai.reactionTimer = 0.0
			ai.reactionDelay = (rand.float32_range(0, ai.profile.reactionDelay))
		}
	} else {
		ai.isTracking = ai.profile.alwaysFollow
		// ai.reactionTimer = 0.0

		if ai.isTracking {
			ai.targetY = predictTrajectory(game)
		}

		if ai.profile.resetPosition && !ai.profile.alwaysFollow {
			ai.targetY = game.screen.y * 0.5
		}

	}

	// move paddle
	paddleCenter := ai.posY + game.paddles[player2].size.y * 0.5
	diff := ai.targetY - paddleCenter

	if math.abs(diff) > 1.0 {
		direction := diff / math.abs(diff)

		currentMaxSpeed := ai.profile.maxSpeed
		if !ai.isTracking {
			currentMaxSpeed = ai.profile.recoverySpeed
		}

		moveDistance := math.min(math.abs(diff), currentMaxSpeed * dt)
		ai.posY += direction * moveDistance

		ai.posY = math.clamp(ai.posY, 0.0, game.screen.y)
		game.paddles[player2].position.y = ai.posY
	}

}
