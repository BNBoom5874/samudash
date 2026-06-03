class_name WaveData
extends RefCounted



var enemies : Array = [] #ประเภทและจำนวน

var simultaneous_max : int #เกิดซ้ำได้กี่ตัว

var limit_map : int #จำกัดจำนวนในแมพ

var spawn_delay : float #เกิดช้าแค่ไหน


#ตัวนับจำนวนศัตรูทั้งหมด
func total_count() -> int:
	var total : int
	for e in enemies:
		total += e.count
	
	return total
