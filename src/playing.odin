package PaddleBattle

import "core:c"
import "core:fmt"
import "matchBackground"
import "particleSystem"
import "types"
import rl "vendor:raylib"


updateGameInput :: proc(game: ^types.Game, dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		MainMenuLoaded = false
		game.state = .MainMenu
	}

	if rl.IsKeyReleased(.F) {
		rl.ToggleFullscreen()
	}

	if rl.IsKeyPressed(.PERIOD) {
		matchBackground.cycleBackground()
	}

	if rl.IsKeyPressed(.EQUAL) {
		nextTrack(&game.audio)
	}

	// debug
	if rl.IsKeyReleased(.SPACE) {
		matchBackground.resetBackground(game)
	}
}

GameUpdate :: proc(game: ^types.Game, dt: f32) {

	if !rl.IsMusicStreamPlaying(game.audio.music[currentSong]) {
		rl.PlayMusicStream(game.audio.music[currentSong])
	}

	rl.UpdateMusicStream(game.audio.music[currentSong])

	// GameShaderUpdate(dt)
	matchBackground.updateBackground(game, dt)
	if currentMatch.powerUps do updatePowerUp(game, dt)

	if game.mode == .SinglePlayer || game.mode == .SinglePlayerTimed {
		updateAi(game, &aiState, dt)
	}

	updateMatch(dt)

	if IsGameClockFinished(gameClock) && currentMatch.matchLength > 0 {
		game.state = .TimesUp
		return
	}

	updateGameInput(game, dt)
	updatePaddles(game, dt)
	particleSystem.update(dt)
	updateBall(game, dt)
}

GameRender :: proc(game: ^types.Game) {
	matchBackground.renderBackground(game)
	renderMatchInfo(game)

	renderPaddles(game)
	particleSystem.render()
	renderBall(game)

	if currentMatch.powerUps do renderPowerUp()
}
