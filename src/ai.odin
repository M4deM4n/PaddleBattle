package PaddleBattle

import "core:math"
import "core:math/rand"


AiState :: struct {
	profile:       OpponentProfile,
	posY:          f32,
	targetY:       f32,
	reactionTimer: f32,
	reactionDelay: f32,
	errFreqTimer:  f32,
	isTracking:    bool,
}

initAI :: proc() {
	aiState = {
		profile    = Profile_SlowPoke,
		posY       = paddles[player2].position.y,
		isTracking = true,
	}
}

predictTrajectory :: proc() -> f32 {
	// if ball.velocity.x <= 0.0 {
	// 	return gameScreenHeight * 0.5
	// }

	timeToImpact := (paddles[player2].position.x - ball.position.x) / ball.position.x
	futureY := ball.position.y + (ball.velocity.y * timeToImpact)

	wrappedY := math.mod(futureY, 2.0 * gameScreenHeight)
	if wrappedY < 0.0 {
		wrappedY += 2.0 * gameScreenHeight
	}

	if wrappedY > gameScreenHeight {
		return 2.0 * gameScreenHeight - wrappedY
	}

	return wrappedY
}

updateAi :: proc(ai: ^AiState, dt: f32) {
	// calculate destination Y
	if ball.velocity.x > 0.0 {

		ai.reactionTimer += dt
		ai.errFreqTimer += dt

		if ai.reactionTimer >= ai.reactionDelay {
			ai.isTracking = true
			perfectTarget := predictTrajectory()

			errorOffset: f32 = 0
			if ai.errFreqTimer >= ai.profile.errorFreq {
				errorOffset = (rand.float32_range(-5.0, 5.0)) * ai.profile.predictionError
				ai.errFreqTimer = 0
			}

			ai.targetY = math.clamp(perfectTarget + errorOffset, 0.0, gameScreenHeight)
			ai.reactionTimer = 0.0
			ai.reactionDelay = (rand.float32_range(0, ai.profile.reactionDelay))
		}
	} else {
		ai.isTracking = ai.profile.alwaysFollow
		// ai.reactionTimer = 0.0

		if ai.isTracking {
			ai.targetY = predictTrajectory()
		}

		if ai.profile.resetPosition && !ai.profile.alwaysFollow {
			ai.targetY = gameScreenHeight * 0.5
		}

	}

	// move paddle
	paddleCenter := ai.posY + paddles[player2].size.y * 0.5
	diff := ai.targetY - paddleCenter

	if math.abs(diff) > 1.0 {
		direction := diff / math.abs(diff)

		currentMaxSpeed := ai.profile.maxSpeed
		if !ai.isTracking {
			currentMaxSpeed = ai.profile.recoverySpeed
		}

		moveDistance := math.min(math.abs(diff), currentMaxSpeed * dt)
		ai.posY += direction * moveDistance

		ai.posY = math.clamp(ai.posY, 0.0, gameScreenHeight)
		paddles[player2].position.y = ai.posY
	}

}
