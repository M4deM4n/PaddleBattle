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

	// debug
	if rl.IsKeyReleased(.SPACE) {
		resetMatch()
	}
}

GameShaderUpdate :: proc(dt: f32) {
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
	lineColor := [3]f32{0.2, 0.2, 0.2}
	glowColor := [3]f32{0.60, 0.0, 1.00}
	rl.SetShaderValue(gridShader, locBgColor, &bgColor, rl.ShaderUniformDataType.VEC3)
	rl.SetShaderValue(gridShader, locLineColor, &lineColor, rl.ShaderUniformDataType.VEC3)
	rl.SetShaderValue(gridShader, locGlowColor, &glowColor, rl.ShaderUniformDataType.VEC3)
}

GameUpdate :: proc(dt: f32) {
	GameShaderUpdate(dt)

	// updatePowerUp(dt)

	if gameMode == GameMode.SinglePlayer || gameMode == GameMode.SinglePlayerTimed {
		updateAi(&aiState, dt)
	}

	updateMatch(dt)
	updateGameInput(dt)
	updatePaddles(dt)
	updateBall(dt)
}

GameRender :: proc() {
	rl.BeginShaderMode(gridShader)
	rl.DrawRectangle(0, 0, i32(gameScreenWidth), i32(gameScreenHeight), rl.WHITE)
	rl.EndShaderMode()

	renderRallyPoints()

	// rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)

	renderPaddles()

	rl.DrawCircleV(ball.position, ball.radius, ball.color)
	// renderPowerUp()
}
