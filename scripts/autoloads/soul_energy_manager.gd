extends Node

## Manages the player's soul energy currency during a run.
## Registered as an autoload so all systems can access the soul balance.

signal souls_changed(new_total: int)

var current_souls: int = 0


func add_souls(amount: int) -> void:
	if amount <= 0:
		return
	current_souls += amount
	souls_changed.emit(current_souls)


func spend_souls(amount: int) -> bool:
	if amount > current_souls:
		return false
	current_souls -= amount
	souls_changed.emit(current_souls)
	return true


func get_souls() -> int:
	return current_souls


func reset() -> void:
	current_souls = 0
	souls_changed.emit(current_souls)
