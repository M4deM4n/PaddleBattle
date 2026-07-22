package PaddleBattle

import "core:fmt"
import rl "vendor:raylib"

Match :: struct {
	rallyCount: i32,
	rallyScore: i32,
	p1Score:    i32,
	p2Score:    i32,
}

currentMatch: Match = Match{}

resetMatch :: proc() {
	currentMatch.rallyCount = 0
	currentMatch.rallyScore = 0
	currentMatch.p1Score = 0
	currentMatch.p2Score = 0

	resetPaddles()
	resetBall()
	gameState = GameState.MatchBegin
}

renderRallyPoints :: proc() {
	position := rl.Vector2{gameScreenWidth * 0.5, 50}

	renderText(position, fmt.caprintf("%i", currentMatch.rallyScore), 72, rl.DARKBLUE)
}
