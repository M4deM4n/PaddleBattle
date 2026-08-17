package PaddleBattle

import "core:fmt"
import "core:math"

GameClock :: struct {
	remaining: f32,
	total:     f32,
	running:   bool,
}

gameClock: GameClock

initGameClock :: proc(c: ^GameClock, seconds: f32) {
	c.remaining = seconds
	c.total = seconds
	c.running = true
}

updateGameClock :: proc(c: ^GameClock, dt: f32) {
	if !c.running do return

	c.remaining -= dt
	if c.remaining <= 0 {
		c.remaining = 0
		c.running = false
	}
}

IsGameClockFinished :: proc(c: GameClock) -> bool {
	return !c.running && c.remaining <= 0
}

gameClockText :: proc(c: GameClock, allocator := context.temp_allocator) -> cstring {
	// Small fixed buffer is plenty for a timer
	@(static) buf: [32]u8

	total_secs := math.max(c.remaining, 0)

	if total_secs < 10 {
		// Show one decimal place when under 10 seconds
		fmt.bprintf(buf[:], "%.1f\x00", total_secs)
	} else {
		mins := int(total_secs) / 60
		secs := int(total_secs) % 60
		fmt.bprintf(buf[:], "%02d:%02d\x00", mins, secs)
	}

	return cstring(&buf[0])
}
