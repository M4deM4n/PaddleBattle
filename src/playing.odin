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

	if rl.IsKeyPressed(.PERIOD) {
		cycleBackground()
	}

	// debug
	if rl.IsKeyReleased(.SPACE) {
		resetMatch()
	}
}

GameUpdate :: proc(dt: f32) {
	// GameShaderUpdate(dt)
	updateBackground(dt)
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
	renderBackground()
	renderRallyPoints()

	// rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)

	renderPaddles()

	rl.DrawCircleV(ball.position, ball.radius, ball.color)
	// renderPowerUp()
}
