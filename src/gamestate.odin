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
