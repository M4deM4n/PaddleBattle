package PaddleBattle

import "core:c"
import rl "vendor:raylib"

GridDistortData :: struct {
	gridSize:         f32,
	lineWidth:        f32,
	bgColor:          [3]f32,
	lineColor:        [3]f32,
	glowColor:        [3]f32,
	locTargetHeight:  c.int,
	locGridSize:      c.int,
	locBallPosition:  c.int,
	locBallRadius:    c.int,
	locDistortRadius: c.int,
	locLineWidth:     c.int,
	locBgColor:       c.int,
	locLineColor:     c.int,
	locGlowColor:     c.int,
}

makeGridDistortBackground :: proc() -> Background {
	bg: Background
	bg.id = .GridDistort
	bg.name = "Grid Distort"
	bg.shader = rl.LoadShaderFromMemory(nil, #load("../res/shader/grid_distort.glsl", cstring))

	d := new(GridDistortData)
	d.locTargetHeight = rl.GetShaderLocation(bg.shader, "u_targetHeight")
	d.locGridSize = rl.GetShaderLocation(bg.shader, "u_gridSize")
	d.locBallPosition = rl.GetShaderLocation(bg.shader, "u_ballPos")
	d.locBallRadius = rl.GetShaderLocation(bg.shader, "u_ballRadius")
	d.locDistortRadius = rl.GetShaderLocation(bg.shader, "u_distortRadius")
	d.locLineWidth = rl.GetShaderLocation(bg.shader, "u_lineWidth")
	d.locBgColor = rl.GetShaderLocation(bg.shader, "u_bgColor")
	d.locLineColor = rl.GetShaderLocation(bg.shader, "u_lineColor")
	d.locGlowColor = rl.GetShaderLocation(bg.shader, "u_glowColor")

	d.gridSize = 40
	d.lineWidth = 0.125
	d.bgColor = {0.0, 0.0, 0.0}
	d.lineColor = {0.2, 0.2, 0.2}
	d.glowColor = {0.60, 0.0, 1.00}

	bg.data = d
	bg.update = gridDistortUpdate
	bg.destroy = gridDistortDestroy
	return bg
}

gridDistortUpdate :: proc(bg: ^Background, dt: f32) {
	ball.color = rl.BLACK

	d := cast(^GridDistortData)bg.data
	targetH := gameScreenHeight
	distortRadius := ball.radius * 100

	rl.SetShaderValue(bg.shader, d.locTargetHeight, &targetH, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locGridSize, &d.gridSize, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locLineWidth, &d.lineWidth, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locBallPosition, &ball.position, .VEC2)
	rl.SetShaderValue(bg.shader, d.locBallRadius, &ball.radius, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locDistortRadius, &distortRadius, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locBgColor, &d.bgColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locLineColor, &d.lineColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locGlowColor, &d.glowColor, .VEC3)
}

gridDistortDestroy :: proc(bg: ^Background) {
	free(bg.data)
}
