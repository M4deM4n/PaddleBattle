package PaddleBattle

import "core:math/rand"
import rl "vendor:raylib"

SINGLE_PLAYER :: "Single Player"
LOCAL_MULTIPLAYER :: "Local Multiplayer"

gameOptions := []cstring{SINGLE_PLAYER, LOCAL_MULTIPLAYER}
selectedOption: int
selectedColor: rl.Color = rl.YELLOW

MainMenuLoaded: bool = false
fireworksTimer: f32
fireworksDelay: f32 = 1
fireworksColor: [2]rl.Color = [2]rl.Color{{0, 0, 255, 255}, {255, 0, 0, 255}}

MainMenuInput :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {
		shouldClose = true
	}

	if rl.IsKeyPressed(.W) {
		selectedOption -= 1
		rl.PlaySound(audioMenuSelect)
	}

	if rl.IsKeyPressed(.S) {
		selectedOption += 1
		rl.PlaySound(audioMenuSelect)
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		switch gameOptions[selectedOption] {
		case SINGLE_PLAYER:
			MainMenuLoaded = false
			gameMode = GameMode.SinglePlayer

		case LOCAL_MULTIPLAYER:
			MainMenuLoaded = false
			gameMode = GameMode.Multiplayer
		}

		clearParticles()

		rl.StopMusicStream(music[currentSong])
		rl.StopMusicStream(titleMusic)
		gameState = GameState.MatchBegin

	}

	// bounds checks
	if selectedOption < 0 {
		selectedOption = len(gameOptions) - 1
	}

	if selectedOption >= len(gameOptions) {
		selectedOption = 0
	}
}

MainMenuUpdate :: proc(dt: f32) {
	fireworksTimer += dt

	if !rl.IsMusicStreamPlaying(titleMusic) {
		rl.PlayMusicStream(titleMusic)
	}

	rl.UpdateMusicStream(titleMusic)

	if !rl.IsSoundPlaying(audioTitle) && !MainMenuLoaded {
		MainMenuLoaded = true
		rl.PlaySound(audioTitle)
		// rl.PlayMusicStream(music)
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

	// rl.UpdateMusicStream(music)
	updateParticles(dt)
	MainMenuInput()
}

MainMenuRender :: proc() {
	renderParticles()
	renderText(
		{gameScreenWidth * 0.5, (gameScreenHeight * 0.5) - 300},
		"PADDLE BATTLE",
		144,
		rl.WHITE,
	)

	for option, i in gameOptions {
		vOffset := i * 100
		renderText(
			{gameScreenWidth * 0.5, (gameScreenHeight * 0.5) + f32(vOffset)},
			gameOptions[i],
			72,
			(i == selectedOption) ? selectedColor : rl.WHITE,
		)
	}
}
