package PaddleBattle

import "core:fmt"

i32ToCString :: proc(value: i32) -> cstring {
	return fmt.ctprintf("%d", value) // uses context.temp_allocator
}
