class_name ShardPool


static func get_all_shards() -> Array[Shard]:
	var shards: Array[Shard] = []

	# Bone Fragment — Cooldown Reduction
	var bone := Shard.new()
	bone.shard_name = "Bone Fragment"
	bone.stat_type = Shard.StatType.COOLDOWN_REDUCTION
	bone.base_value = -8.0
	bone.adjacency_bonus_percent = 25.0
	bone.receive_directions = [Shard.Direction.DOWN, Shard.Direction.RIGHT] as Array[Shard.Direction]
	bone.purchase_price = 40
	bone.sell_value = 15
	shards.append(bone)

	# Blood Crystal — Damage Amp
	var blood := Shard.new()
	blood.shard_name = "Blood Crystal"
	blood.stat_type = Shard.StatType.DAMAGE_AMP
	blood.base_value = 12.0
	blood.adjacency_bonus_percent = 25.0
	blood.receive_directions = [Shard.Direction.UP, Shard.Direction.DOWN, Shard.Direction.LEFT, Shard.Direction.RIGHT] as Array[Shard.Direction]
	blood.purchase_price = 80
	blood.sell_value = 30
	shards.append(blood)

	# Swift Essence — Attack Speed
	var swift := Shard.new()
	swift.shard_name = "Swift Essence"
	swift.stat_type = Shard.StatType.ATTACK_SPEED
	swift.base_value = 10.0
	swift.adjacency_bonus_percent = 25.0
	swift.receive_directions = [Shard.Direction.LEFT, Shard.Direction.RIGHT] as Array[Shard.Direction]
	swift.purchase_price = 50
	swift.sell_value = 20
	shards.append(swift)

	# Vital Marrow — Healing Rate
	var vital := Shard.new()
	vital.shard_name = "Vital Marrow"
	vital.stat_type = Shard.StatType.HEALING_RATE
	vital.base_value = 3.0
	vital.adjacency_bonus_percent = 25.0
	vital.receive_directions = [Shard.Direction.UP, Shard.Direction.DOWN] as Array[Shard.Direction]
	vital.purchase_price = 45
	vital.sell_value = 18
	shards.append(vital)

	# Soul Stone — Max Health
	var soul := Shard.new()
	soul.shard_name = "Soul Stone"
	soul.stat_type = Shard.StatType.MAX_HEALTH
	soul.base_value = 15.0
	soul.adjacency_bonus_percent = 25.0
	soul.receive_directions = [Shard.Direction.UP, Shard.Direction.LEFT] as Array[Shard.Direction]
	soul.purchase_price = 55
	soul.sell_value = 22
	shards.append(soul)

	# Phantom Shard — Movement Speed
	var phantom := Shard.new()
	phantom.shard_name = "Phantom Shard"
	phantom.stat_type = Shard.StatType.MOVEMENT_SPEED
	phantom.base_value = 8.0
	phantom.adjacency_bonus_percent = 25.0
	phantom.receive_directions = [Shard.Direction.DOWN, Shard.Direction.LEFT, Shard.Direction.RIGHT] as Array[Shard.Direction]
	phantom.purchase_price = 60
	phantom.sell_value = 24
	shards.append(phantom)

	# Reaper's Eye — Soul Bonus
	var reaper := Shard.new()
	reaper.shard_name = "Reaper's Eye"
	reaper.stat_type = Shard.StatType.SOUL_BONUS
	reaper.base_value = 15.0
	reaper.adjacency_bonus_percent = 25.0
	reaper.receive_directions = [Shard.Direction.UP] as Array[Shard.Direction]
	reaper.purchase_price = 35
	reaper.sell_value = 12
	shards.append(reaper)

	# Death's Edge — Crit Chance
	var death := Shard.new()
	death.shard_name = "Death's Edge"
	death.stat_type = Shard.StatType.CRIT_CHANCE
	death.base_value = 5.0
	death.adjacency_bonus_percent = 25.0
	death.receive_directions = [Shard.Direction.UP, Shard.Direction.RIGHT, Shard.Direction.DOWN] as Array[Shard.Direction]
	death.purchase_price = 70
	death.sell_value = 28
	shards.append(death)

	return shards


static func get_shard_by_name(shard_name: String) -> Shard:
	for shard in get_all_shards():
		if shard.shard_name == shard_name:
			return shard
	return null
