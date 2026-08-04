package PaddleBattle

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Ball :: struct {
	position:     rl.Vector2,
	velocity:     rl.Vector2,
	radius:       f32,
	color:        rl.Color,
	shadowColor:  rl.Color,
	shadowOffset: rl.Vector2,
}

collissionTimer: f32
ignoreCollission: bool
ballspeed: f32

lastBallPosition: rl.Vector2
nextBallPosition: rl.Vector2
hitPoint: rl.Vector2

paddleRect: rl.Rectangle

initBall :: proc() {
	ball = Ball {
		position     = {gameScreenWidth * 0.5, gameScreenHeight * 0.5},
		velocity     = {ballspeed, ballspeed},
		radius       = 10,
		color        = {0, 0, 0, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}
}

resetBall :: proc() {
	ballspeed = 550
	ball.position = {gameScreenWidth * 0.5, gameScreenHeight * 0.5}
	ball.velocity = rl.Vector2Normalize(ball.velocity) * ballspeed
}

updateBall :: proc(dt: f32) {
	lastBallPosition = ball.position
	nextBallPosition = ball.position + ((rl.Vector2Normalize(ball.velocity) * ballspeed) * dt)

	dist := math.abs(lastBallPosition.x - nextBallPosition.x)

	for &playerPaddle in paddles {
		paddleRect = {
			playerPaddle.position.x,
			playerPaddle.position.y,
			playerPaddle.size.x,
			playerPaddle.size.y,
		}

		if dist >= ball.radius * 2 {
			if CheckCollisionLineRect(lastBallPosition, nextBallPosition, paddleRect, &hitPoint) {
				rl.PlaySound(audioBallImpact)
				ball.position = hitPoint

				// increase ball velocity
				ballspeed += 50

				updateRally()

				// ball.velocity *= -1
				ball.velocity = calculateNewVelocity(playerPaddle)
				spawnBurst(
					origin = ball.position,
					count = 24,
					color = rl.ColorLerp(playerPaddle.baseColor, rl.WHITE, 0.8),
					force = ball.velocity * 0.4, // lean the whole burst along the new ball vector
					speed = 300,
					life = 0.6,
					size = 5,
				)
			}

		} else {

			if rl.CheckCollisionCircleRec(ball.position, ball.radius, paddleRect) {
				playerPaddle.color = rl.WHITE

				rl.PlaySound(audioBallImpact)
				ballspeed += 50
				updateRally()

				if ball.velocity.x < 0 {
					paddleEdgeX := playerPaddle.position.x + (playerPaddle.size.x * 0.5)
					if ball.position.x < paddleEdgeX {
						ball.position.x = paddleEdgeX + ball.radius
					}

				} else {
					paddleEdgeX := playerPaddle.position.x - (playerPaddle.size.x * 0.5)
					if ball.position.x > paddleEdgeX {
						ball.position.x = paddleEdgeX - ball.radius
					}
				}

				ball.velocity = calculateNewVelocity(playerPaddle)

				spawnBurst(
					origin = ball.position,
					count = 24,
					color = rl.ColorLerp(playerPaddle.baseColor, rl.WHITE, 0.8),
					force = ball.velocity * 0.4, // lean the whole burst along the new ball vector
					speed = 300,
					life = 0.6,
					size = 5,
				)

			}
		}


	}

	ball.position += (rl.Vector2Normalize(ball.velocity) * ballspeed) * dt


	// top constraint
	if ball.position.y >= gameScreenHeight - ball.radius || ball.position.y <= 0 + ball.radius {
		ball.velocity.y *= -1
	}

	if ball.position.x > gameScreenWidth || ball.position.x < 0 {
		rl.PlaySound(audioHorn)
		gameState = GameState.PlayerScored
		ball.position = {gameScreenWidth * 0.5, gameScreenHeight * 0.5}
	}
}

renderBall :: proc() {
	rl.DrawCircleV(ball.position + ball.shadowOffset, ball.radius, ball.shadowColor)
	rl.DrawCircleV(ball.position, ball.radius, ball.color)
}


// CheckCollisionLineRect checks if a line segment intersects with any edge of a rectangle.
// It returns true if a collision occurs and optionally outputs the first collision point found.
CheckCollisionLineRect :: proc(
	line_start, line_end: rl.Vector2,
	rec: rl.Rectangle,
	collision_point: ^rl.Vector2,
) -> bool {
	// Define the four edges of the rectangle
	// Top edge
	top_start := rl.Vector2{rec.x, rec.y}
	top_end := rl.Vector2{rec.x + rec.width, rec.y}

	// Right edge
	right_start := rl.Vector2{rec.x + rec.width, rec.y}
	right_end := rl.Vector2{rec.x + rec.width, rec.y + rec.height}

	// Bottom edge
	bottom_start := rl.Vector2{rec.x + rec.width, rec.y + rec.height}
	bottom_end := rl.Vector2{rec.x, rec.y + rec.height}

	// Left edge
	left_start := rl.Vector2{rec.x, rec.y + rec.height}
	left_end := rl.Vector2{rec.x, rec.y}

	// Temporary point to store intersection
	temp_point := rl.Vector2{0.0, 0.0}
	out_point: ^rl.Vector2

	if collision_point != nil {
		out_point = collision_point
	} else {
		out_point = &temp_point
	}


	// Check collision against each edge
	// if rl.CheckCollisionLines(line_start, line_end, top_start, top_end, out_point) {
	// 	return true
	// }


	if rl.CheckCollisionLines(line_start, line_end, right_start, right_end, out_point) {
		if ball.velocity.x < 0 {
			out_point.x += ball.radius
		} else {
			out_point.x -= ball.radius + (rec.width * 0.5)
		}

		return true

	}

	// if rl.CheckCollisionLines(line_start, line_end, bottom_start, bottom_end, out_point) {
	// 	return true
	// }


	if rl.CheckCollisionLines(line_start, line_end, left_start, left_end, out_point) {
		if ball.velocity.x < 0 {
			out_point.x += ball.radius + (rec.width * 0.5)
		} else {
			out_point.x -= ball.radius
		}
		return true

	}


	return false
}


calculateNewVelocity :: proc(playerPaddle: Paddle) -> rl.Vector2 {
	reflectDirection :=
		ball.position -
		{playerPaddle.position.x, playerPaddle.position.y + (playerPaddle.size.y * 0.5)}

	newVelocity :=
		rl.Vector2Normalize(
			(rl.Vector2{ball.velocity.x * -1, ball.velocity.y} +
				reflectDirection +
				{reflectDirection.x, 0}),
		) *
		ballspeed

	return newVelocity
}
