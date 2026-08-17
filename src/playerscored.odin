package PaddleBattle

import "core:math/rand"
import "gameTypes"
import "matchBackground"
import "particleSystem"
import rl "vendor:raylib"

announceScoreDialog: bool = true
dialogDelayTimer: f32


PlayerScoredInput :: proc(game: ^gameTypes.Game) {
	if rl.IsKeyPressed(.ESCAPE) {
		game.state = .MainMenu
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		resetMatch(game)
		announceScoreDialog = true
		dialogDelayTimer = 0
		game.state = .MatchBegin
		rl.StopMusicStream(music[currentSong])
		particleSystem.clear()
	}
}

PlayerScoredUpdate :: proc(game: ^gameTypes.Game, dt: f32) {
	fireworksTimer += dt
	dialogDelayTimer += dt

	if rl.IsMusicStreamPlaying(music[currentSong]) {
		rl.UpdateMusicStream(music[currentSong])
	}

	if announceScoreDialog && dialogDelayTimer >= 1.0 {
		rl.PlaySound(rand.choice(announcerGoal[:]))
		announceScoreDialog = false
	}

	if fireworksTimer >= fireworksDelay {
		rl.PlaySound(audioBallImpact)
		o := rl.Vector2 {
			f32(rand.int_range(0, int(game.screen.x))),
			f32(rand.int_range(0, int(game.screen.y))),
		}
		particleSystem.spawnBurst(
			origin = o,
			count = 75,
			color = rand.choice(fireworksColor[:]),
			speed = 300,
			life = 3,
			size = 14,
		)
		particleSystem.spawnBurst(
			origin = o,
			count = 35,
			color = rl.WHITE,
			speed = 150,
			life = 1.5,
			size = 7,
		)
		fireworksDelay = rand.float32_range(0.5, 2)
		fireworksTimer = 0
	}

	matchBackground.updateBackground(game, dt)
	particleSystem.update(dt)
	PlayerScoredInput(game)
}

PlayerScoredRender :: proc(game: ^gameTypes.Game) {
	matchBackground.renderBackground(game)
	particleSystem.render()
	renderMatchGoals(game)
	renderText(game.centerScreen - {0, game.screen.y * 0.25}, "SCORE!", 142, rl.WHITE, 3)
}
