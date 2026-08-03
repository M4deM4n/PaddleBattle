package PaddleBattle

import rl "vendor:raylib"

SINGLE_PLAYER :: "Single Player"
LOCAL_MULTIPLAYER :: "Local Multiplayer"

gameOptions := []cstring{SINGLE_PLAYER, LOCAL_MULTIPLAYER}
selectedOption: int
selectedColor: rl.Color = rl.YELLOW

MainMenuLoaded: bool = false

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

		gameState = GameState.MatchBegin
		rl.StopMusicStream(music)
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
	if !rl.IsSoundPlaying(audioTitle) && !MainMenuLoaded {
		MainMenuLoaded = true
		rl.PlaySound(audioTitle)
		// rl.PlayMusicStream(music)
	}
	// rl.UpdateMusicStream(music)
	MainMenuInput()
}

MainMenuRender :: proc() {
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
