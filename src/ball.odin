package PaddleBattle

import "core:math"
import rl "vendor:raylib"

Ball :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
	radius:   f32,
	color:    rl.Color,
}

collissionTimer: f32
ignoreCollission: bool
ballspeed: f32

lastBallPosition: rl.Vector2
nextBallPosition: rl.Vector2

initBall :: proc() {
	ball = Ball {
		position = {gameScreenWidth * 0.5, gameScreenHeight * 0.5},
		velocity = {ballspeed, ballspeed},
		radius   = 10,
		color    = {255, 255, 255, 255},
	}
}

resetBall :: proc() {
	ballspeed = 550
	ball.position = {gameScreenWidth * 0.5, gameScreenHeight * 0.5}
	ball.velocity = rl.Vector2Normalize(ball.velocity) * ballspeed


}

updateBall :: proc(dt: f32) {

	collissionTimer += dt
	if collissionTimer >= 1 {
		ignoreCollission = false
	}

	ball.position += ball.velocity * dt

	// top constraint
	if ball.position.y >= gameScreenHeight - ball.radius || ball.position.y <= 0 + ball.radius {
		ball.velocity.y *= -1
	}


	// // debug side screen collision
	// if ball.position.x >= f32(gameScreenWidth) - ball.radius || ball.position.x <= ball.radius {
	// 	ball.velocity.x *= -1
	// }

	if !ignoreCollission {
		for playerPaddle in paddles {
			if rl.CheckCollisionCircleRec(
				ball.position,
				ball.radius,
				rl.Rectangle {
					playerPaddle.position.x,
					playerPaddle.position.y,
					playerPaddle.size.x,
					playerPaddle.size.y,
				},
			) {
				ignoreCollission = true
				collissionTimer = 0

				ballspeed += 50
				// ballspeed = math.clamp(ballspeed, 500, 1400)
				currentMatch.rallyCount += 1
				currentMatch.rallyScore += currentMatch.rallyCount * 10

				// distFromCenterPaddle :=
				// 	ball.position.y - (playerPaddle.position.y + (playerPaddle.size.y * 0.5))

				reflectDirection :=
					ball.position -
					{
							playerPaddle.position.x,
							playerPaddle.position.y + (playerPaddle.size.y * 0.5),
						}

				newVelocity :=
					rl.Vector2Normalize(
						(rl.Vector2{ball.velocity.x * -1, ball.velocity.y} +
							reflectDirection +
							{reflectDirection.x, 0}),
					) *
					ballspeed

				ball.velocity = newVelocity
				// (rl.Vector2Normalize(reflectDirection + {reflectDirection.x, 0})) * ballspeed
				// ball.velocity.x *= -1
			}
		}
	}


	if ball.position.x > gameScreenWidth || ball.position.x < 0 {
		gameState = GameState.PlayerScored
	}
}
