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

	if rl.IsKeyPressed(.EQUAL) {
		nextTrack()
	}

	// debug
	if rl.IsKeyReleased(.SPACE) {
		resetMatch()
	}
}

GameUpdate :: proc(dt: f32) {

	if !rl.IsMusicStreamPlaying(music[currentSong]) {
		rl.PlayMusicStream(music[currentSong])
	}

	rl.UpdateMusicStream(music[currentSong])

	// GameShaderUpdate(dt)
	updateBackground(dt)
	// updatePowerUp(dt)

	if gameMode == GameMode.SinglePlayer || gameMode == GameMode.SinglePlayerTimed {
		updateAi(&aiState, dt)
	}

	updateMatch(dt)
	updateGameInput(dt)
	updatePaddles(dt)
	updateParticles(dt)
	updateBall(dt)
}

GameRender :: proc() {
	renderBackground()
	renderRallyPoints()

	// rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)

	renderPaddles()
	renderParticles()
	renderBall()
	// renderPowerUp()
}
