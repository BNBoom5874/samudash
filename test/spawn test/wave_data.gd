class_name WaveData
extends RefCounted


var enemies : Array = [] #ประเภทและจำนวน
var allowed_zones : Array[String] = [] #ห้ามให้โซนไหนเกิด "โดยใช้ชื่อ node zone นั้นๆ"

var simultaneous_max : int #เกิดซ้ำได้กี่ตัว
var limit_map : int #จำกัดจำนวนในแมพ

var simultaneous_chance : float #โอกาสที่จะเกิดขึ้น
var spawn_delay : float #เกิดช้าแค่ไหน


#region Functions 

#ตัวนับจำนวนศัตรูทั้งหมด
func total_count() -> int:
	var total : int = 0
	for e in enemies:
		total += e["count"]
	
	return total
