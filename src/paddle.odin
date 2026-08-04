package PaddleBattle

import rl "vendor:raylib"

Paddle :: struct {
	size:         rl.Vector2,
	position:     rl.Vector2,
	velocity:     f32,
	color:        rl.Color,
	baseColor:    rl.Color,
	shadowColor:  rl.Color,
	shadowOffset: rl.Vector2,
}

normalPaddle: rl.Vector2 = {20, 100}

initPaddles :: proc() {
	startPosY = (gameScreenHeight * 0.5) - (normalPaddle.y * 0.5)

	paddle_l := Paddle {
		size         = {20, 100},
		position     = {10, startPosY},
		velocity     = paddle_velocity,
		color        = {0, 0, 255, 255},
		baseColor    = {0, 0, 255, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}

	paddle_r := Paddle {
		position     = {gameScreenWidth - 30, startPosY},
		size         = {20, 100},
		velocity     = paddle_velocity,
		color        = {255, 0, 0, 255},
		baseColor    = {255, 0, 0, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}

	paddles[player1] = paddle_l
	paddles[player2] = paddle_r
}

resetPaddles :: proc() {
	for i in 0 ..= 1 {
		paddles[i].position.y = startPosY
	}
}

updatePaddleInput :: proc(dt: f32) {
	// player 1
	if rl.IsKeyDown(.W) {
		paddles[player1].position.y -= paddles[player1].velocity * dt
	}

	if rl.IsKeyDown(.S) {
		paddles[player1].position.y += paddles[player1].velocity * dt
	}

	// player 2
	if gameMode == GameMode.Multiplayer || gameMode == GameMode.MultiplayerTimed {

		if rl.IsKeyDown(.KP_8) {
			paddles[player2].position.y -= paddles[player2].velocity * dt
		}

		if rl.IsKeyDown(.KP_5) {
			paddles[player2].position.y += paddles[player2].velocity * dt
		}
	}
}

updatePaddles :: proc(dt: f32) {
	updatePaddleInput(dt)

	// clamp paddles so they stay on screen
	for i in 0 ..= 1 {
		if i == 0 {
			paddles[i].color = rl.ColorLerp(paddles[i].color, paddles[i].baseColor, dt)
		}

		if i == 1 {
			paddles[i].color = rl.ColorLerp(paddles[i].color, paddles[i].baseColor, dt)
		}


		paddles[i].position.y = clamp(
			paddles[i].position.y,
			0,
			gameScreenHeight - paddles[i].size.y,
		)
	}
}

renderPaddles :: proc() {
	for playerPaddle in paddles {
		rl.DrawRectangleV(
			playerPaddle.position + playerPaddle.shadowOffset,
			playerPaddle.size,
			playerPaddle.shadowColor,
		)
		rl.DrawRectangleV(playerPaddle.position, playerPaddle.size, playerPaddle.color)
	}
}
