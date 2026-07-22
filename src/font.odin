package PaddleBattle

import rl "vendor:raylib"

GameFont :: struct {
	font:        rl.Font,
	defaultSize: f32,
	charSpacing: f32,
}

gameFont: GameFont

initFont :: proc() {
	gameFont = GameFont{}
	gameFont.defaultSize = 144
	gameFont.charSpacing = 1.0
	gameFont.font = rl.LoadFontEx("../res/font/SaH2Outline.ttf", i32(gameFont.defaultSize), nil, 0)
}

renderText :: proc(position: rl.Vector2, text: cstring, fontSize: f32, color: rl.Color) {
	textSize := rl.MeasureTextEx(gameFont.font, text, fontSize, gameFont.charSpacing)
	rl.DrawTextEx(
		gameFont.font,
		text,
		{position.x - textSize.x * 0.5, position.y - textSize.y * 0.5},
		fontSize,
		gameFont.charSpacing,
		color,
	)
}
