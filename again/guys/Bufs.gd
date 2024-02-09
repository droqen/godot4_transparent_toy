class_name Bufs

var _bufs : Dictionary = Dictionary()

func _init():
	pass

func _setbuf(bufid : int, value : int):
	if value <= 0: _bufs.erase(bufid)
	else: _bufs[bufid] = value
func addto(bufid : int, value : int):
	_setbuf(bufid,max(0, buf(bufid) + value))
func setmin(bufid : int, value : int):
	_setbuf(bufid,max(buf(bufid), value))
func clr(bufid : int):
	_setbuf(bufid, 0)
func has(bufid : int) -> bool:
	return buf(bufid) > 0
func buf(bufid : int) -> int:
	return _bufs.get(bufid, 0)
func try_consume(bufids:Array[int]) -> bool:
	for bufid in bufids:
		if buf(bufid) <= 0:
			return false
	for bufid in bufids:
		clr(bufid)
	return true
func process_bufs():
	for bufid in _bufs:
		addto(bufid, -1)
	
