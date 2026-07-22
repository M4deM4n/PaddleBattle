package PaddleBattle

import rl "vendor:raylib"

GameInputUpdate :: proc(dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		gameState = GameState.MainMenu
	}

	if rl.IsKeyReleased(.F) {
		rl.ToggleFullscreen()
	}

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

	// debug
	if rl.IsKeyReleased(.SPACE) {
		resetMatch()
	}
}

GameUpdate :: proc(dt: f32) {
	if gameMode == GameMode.SinglePlayer || gameMode == GameMode.SinglePlayerTimed {
		updateAi(&aiState, dt)
	}

	GameInputUpdate(dt)
	updateBall(dt)

	// clamp paddles so they stay on screen
	for i in 0 ..= 1 {
		paddles[i].position.y = clamp(
			paddles[i].position.y,
			0,
			gameScreenHeight - paddles[i].size.y,
		)
	}
}

GameRender :: proc() {
	renderRallyPoints()

	for playerPaddle in paddles {
		rl.DrawRectangleV(playerPaddle.position, playerPaddle.size, playerPaddle.color)
	}

	rl.DrawCircleV(ball.position, ball.radius, ball.color)
}
