package PaddleBattle

import "core:math/rand"
import rl "vendor:raylib"

announceScoreDialog: bool = true
dialogDelayTimer: f32


PlayerScoredInput :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {
		gameState = GameState.MainMenu
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		resetMatch()
		announceScoreDialog = true
		dialogDelayTimer = 0
		gameState = GameState.MatchBegin
		rl.StopMusicStream(music[currentSong])
		clearParticles()
	}
}

PlayerScoredUpdate :: proc(dt: f32) {
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
			f32(rand.int_range(0, int(gameScreenWidth))),
			f32(rand.int_range(0, int(gameScreenHeight))),
		}
		spawnBurst(
			origin = o,
			count = 75,
			color = rand.choice(fireworksColor[:]),
			speed = 300,
			life = 3,
			size = 14,
		)
		spawnBurst(origin = o, count = 35, color = rl.WHITE, speed = 150, life = 1.5, size = 7)
		fireworksDelay = rand.float32_range(0.5, 2)
		fireworksTimer = 0
	}

	updateBackground(dt)
	updateParticles(dt)
	PlayerScoredInput()
}

PlayerScoredRender :: proc() {
	renderBackground()
	renderParticles()
	renderText(
		{(gameScreenWidth * 0.5) + 3, (gameScreenHeight * 0.5) + 3},
		"SCORE!!!",
		142,
		rl.BLACK,
	)
	renderText({gameScreenWidth * 0.5, gameScreenHeight * 0.5}, "SCORE!!!", 142, rl.WHITE)
}
