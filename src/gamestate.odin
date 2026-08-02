package PaddleBattle

import rl "vendor:raylib"

GameState :: enum {
	Intro,
	MainMenu,
	MatchBegin,
	Playing,
	PlayerScored,
	MatchOver,
}

GameMode :: enum {
	SinglePlayer,
	SinglePlayerTimed,
	Multiplayer,
	MultiplayerTimed,
}

gameState: GameState
gameMode: GameMode

updateGameState :: proc(dt: f32) {
	#partial switch gameState {
	case GameState.Intro:
		IntroUpdate(dt)

	case GameState.MainMenu:
		MainMenuUpdate(dt)

	case GameState.MatchBegin:
		MatchBeginUpdate(dt)

	case GameState.Playing:
		GameUpdate(dt)

	case GameState.PlayerScored:
		PlayerScoredUpdate(dt)
	}
}

renderGameState :: proc() {
	#partial switch gameState {
	case GameState.Intro:
		IntroRender()

	case GameState.MainMenu:
		MainMenuRender()

	case GameState.MatchBegin:
		MatchBeginRender()

	case GameState.Playing:
		GameRender()

	case GameState.PlayerScored:
		PlayerScoredRender()
	}
}
