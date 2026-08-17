package PaddleBattle

import "core:fmt"
import "core:math"
import "gameTypes"
import "particleSystem"
import rl "vendor:raylib"


collissionTimer: f32
ignoreCollission: bool

lastBallPosition: rl.Vector2
nextBallPosition: rl.Vector2
hitPoint: rl.Vector2

paddleRect: rl.Rectangle

initBall :: proc(game: ^gameTypes.Game) {
	game.ball = gameTypes.Ball {
		position     = {game.screen.x * 0.5, game.screen.y * 0.5},
		velocity     = {currentMatch.ballSpeed, currentMatch.ballSpeed},
		radius       = 10,
		color        = {0, 0, 0, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}
}

resetBall :: proc(game: ^gameTypes.Game) {
	currentMatch.currentBallSpeed = currentMatch.ballSpeed
	game.ball.position = game.centerScreen
	game.ball.velocity = rl.Vector2Normalize(game.ball.velocity) * currentMatch.currentBallSpeed
}

updateBall :: proc(game: ^gameTypes.Game, dt: f32) {
	lastBallPosition = game.ball.position
	nextBallPosition =
		game.ball.position +
		((rl.Vector2Normalize(game.ball.velocity) * currentMatch.currentBallSpeed) * dt)

	dist := math.abs(lastBallPosition.x - nextBallPosition.x)

	for &playerPaddle in game.paddles {
		paddleRect = {
			playerPaddle.position.x,
			playerPaddle.position.y,
			playerPaddle.size.x,
			playerPaddle.size.y,
		}

		if dist >= game.ball.radius * 2 {
			if CheckCollisionLineRect(
				game,
				lastBallPosition,
				nextBallPosition,
				paddleRect,
				&hitPoint,
			) {
				rl.PlaySound(audioBallImpact)
				game.ball.position = hitPoint

				// increase ball velocity
				currentMatch.currentBallSpeed += currentMatch.ballAcceleration

				updateRally()

				// ball.velocity *= -1
				game.ball.velocity = calculateNewVelocity(game, playerPaddle)
				particleSystem.spawnBurst(
					origin = game.ball.position,
					count = 24,
					color = rl.ColorLerp(playerPaddle.baseColor, rl.WHITE, 0.25),
					force = game.ball.velocity * 0.4, // lean the whole burst along the new ball vector
					speed = 300,
					life = 0.6,
					size = 10,
				)
			}

		} else {

			if rl.CheckCollisionCircleRec(game.ball.position, game.ball.radius, paddleRect) {
				playerPaddle.color = rl.WHITE

				rl.PlaySound(audioBallImpact)

				currentMatch.currentBallSpeed += currentMatch.ballAcceleration

				updateRally()

				if game.ball.velocity.x < 0 {
					paddleEdgeX := playerPaddle.position.x + (playerPaddle.size.x * 0.5)
					if game.ball.position.x < paddleEdgeX {
						game.ball.position.x = paddleEdgeX + game.ball.radius
					}

				} else {
					paddleEdgeX := playerPaddle.position.x - (playerPaddle.size.x * 0.5)
					if game.ball.position.x > paddleEdgeX {
						game.ball.position.x = paddleEdgeX - game.ball.radius
					}
				}

				game.ball.velocity = calculateNewVelocity(game, playerPaddle)

				particleSystem.spawnBurst(
					origin = game.ball.position,
					count = 24,
					color = rl.ColorLerp(playerPaddle.baseColor, rl.WHITE, 0.25),
					force = game.ball.velocity * 0.4, // lean the whole burst along the new ball vector
					speed = 300,
					life = 0.6,
					size = 10,
				)

			}
		}


	}

	game.ball.position +=
		(rl.Vector2Normalize(game.ball.velocity) * currentMatch.currentBallSpeed) * dt


	// top constraint
	if game.ball.position.y >= game.screen.y - game.ball.radius ||
	   game.ball.position.y <= 0 + game.ball.radius {
		game.ball.velocity.y *= -1
	}

	if game.ball.position.x > game.screen.x || game.ball.position.x < 0 {
		rl.PlaySound(audioHorn)

		if game.ball.position.x > game.screen.x {
			currentMatch.p1Score += currentMatch.rallyScore
			currentMatch.p1Goals += 1
		}

		if game.ball.position.x < 0 {
			currentMatch.p2Score += currentMatch.rallyScore
			currentMatch.p2Goals += 1
		}

		fmt.println("score", currentMatch.p1Score, currentMatch.p2Score)
		fmt.println("goals", currentMatch.p1Goals, currentMatch.p2Goals)

		game.state = .PlayerScored
		game.ball.position = game.centerScreen
	}
}

renderBall :: proc(game: ^gameTypes.Game) {
	rl.DrawCircleV(
		game.ball.position + game.ball.shadowOffset,
		game.ball.radius,
		game.ball.shadowColor,
	)
	rl.DrawCircleV(game.ball.position, game.ball.radius, game.ball.color)
}


// CheckCollisionLineRect checks if a line segment intersects with any edge of a rectangle.
// It returns true if a collision occurs and optionally outputs the first collision point found.
CheckCollisionLineRect :: proc(
	game: ^gameTypes.Game,
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
		if game.ball.velocity.x < 0 {
			out_point.x += game.ball.radius
		} else {
			out_point.x -= game.ball.radius + (rec.width * 0.5)
		}

		return true

	}

	// if rl.CheckCollisionLines(line_start, line_end, bottom_start, bottom_end, out_point) {
	// 	return true
	// }


	if rl.CheckCollisionLines(line_start, line_end, left_start, left_end, out_point) {
		if game.ball.velocity.x < 0 {
			out_point.x += game.ball.radius + (rec.width * 0.5)
		} else {
			out_point.x -= game.ball.radius
		}
		return true

	}


	return false
}


calculateNewVelocity :: proc(game: ^gameTypes.Game, playerPaddle: gameTypes.Paddle) -> rl.Vector2 {
	reflectDirection :=
		game.ball.position -
		{playerPaddle.position.x, playerPaddle.position.y + (playerPaddle.size.y * 0.5)}

	newVelocity :=
		rl.Vector2Normalize(
			(rl.Vector2{game.ball.velocity.x * -1, game.ball.velocity.y} +
				reflectDirection +
				{reflectDirection.x, 0}),
		) *
		currentMatch.currentBallSpeed

	return newVelocity
}
