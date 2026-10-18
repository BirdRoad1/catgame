extends Control

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction
const Corridor = DungeonScript.Corridor

var dungeon: Dungeon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	if dungeon == null:
		print("DA NULL")
		return
	print("NAWT NULL")
	var origin := size / 2
	# Draw the player rect
	draw_rect(Rect2(origin.x - 5, origin.y - 5, 10, 10), Color("red"))
	for y in range(-5, 5):
		for x in range(-5, 5):
			var posX = dungeon.current_location.x + x
			var posY = dungeon.current_location.y + y
			var pos = Vector2i(posX, posY)
			var corridor: Corridor = dungeon.map.get(pos)
			print("DA SHIT")
			if corridor != null && corridor.did_travel:
				print("Draw da rect!")
				var corridorMapX = origin.x + x * 20
				var corridorMapY = origin.y + y * 20
				draw_rect(Rect2(corridorMapX - 5, corridorMapY - 5, 10, 10), Color("green"))
				for dir in corridor.open_directions:
					var adj = dungeon.map.get(dungeon.apply_direction(pos, dir))
					var color = Color('purple')
					if adj != null && adj.did_travel:
						color = Color('green')
					match dir:
						Direction.NORTH:
							draw_rect(Rect2(corridorMapX - 5, corridorMapY - 5 - 10, 10, 10), color)
						Direction.EAST:
							draw_rect(Rect2(corridorMapX - 5 + 10, corridorMapY - 5, 10, 10), color)
						Direction.SOUTH:
							draw_rect(Rect2(corridorMapX - 5, corridorMapY - 5 + 10, 10, 10), color)
						Direction.WEST:
							draw_rect(Rect2(corridorMapX - 5 - 10, corridorMapY - 5, 10, 10), color)


			else:
				print("DAT SHIT NULL")
			pass
func refresh(dung: Dungeon):
	dungeon = dung # TODO: this aint great
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
