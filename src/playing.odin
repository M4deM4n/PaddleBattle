package PaddleBattle

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

updateGameInput :: proc(dt: f32) {
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
	targetHeight := gameScreenHeight
	rl.SetShaderValue(gridShader, locTargetHeight, &targetHeight, rl.ShaderUniformDataType.FLOAT)

	gridSize: f32 = 40
	rl.SetShaderValue(gridShader, locGridSize, &gridSize, rl.ShaderUniformDataType.FLOAT)

	lineWidth: f32 = 0.125
	rl.SetShaderValue(gridShader, locLineWidth, &lineWidth, rl.ShaderUniformDataType.FLOAT)

	rl.SetShaderValue(gridShader, locBallPosition, &ball.position, rl.ShaderUniformDataType.VEC2)
	rl.SetShaderValue(gridShader, locBallRadius, &ball.radius, rl.ShaderUniformDataType.FLOAT)


	distortRadius: f32 = ball.radius * 100
	rl.SetShaderValue(gridShader, locDistortRadius, &distortRadius, rl.ShaderUniformDataType.FLOAT)

	bgColor := [3]f32{0.0, 0.0, 0.0}
	lineColor := [3]f32{0.3, 0.3, 0.3}
	glowColor := [3]f32{0.00, 0.60, 1.00}
	rl.SetShaderValue(gridShader, locBgColor, &bgColor, rl.ShaderUniformDataType.VEC3)
	rl.SetShaderValue(gridShader, locLineColor, &lineColor, rl.ShaderUniformDataType.VEC3)
	rl.SetShaderValue(gridShader, locGlowColor, &glowColor, rl.ShaderUniformDataType.VEC3)

	// updatePowerUp(dt)

	if gameMode == GameMode.SinglePlayer || gameMode == GameMode.SinglePlayerTimed {
		updateAi(&aiState, dt)
	}

	updateGameInput(dt)
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
	rl.BeginShaderMode(gridShader)
	rl.DrawRectangle(0, 0, i32(gameScreenWidth), i32(gameScreenHeight), rl.WHITE)
	rl.EndShaderMode()

	renderRallyPoints()

	// rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)

	for playerPaddle in paddles {
		rl.DrawRectangleV(playerPaddle.position, playerPaddle.size, playerPaddle.color)
	}

	rl.DrawCircleV(ball.position, ball.radius, ball.color)
	// renderPowerUp()
}
