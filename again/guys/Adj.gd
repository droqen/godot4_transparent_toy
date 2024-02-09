class_name Adj
signal on_changed(id)
var change_callback : Callable
var id : int :
	set(newid):
		assert(newid in _valid_adjids)
		if newid != _adjid:
			_adjid = newid
			on_changed.emit(newid)
			if change_callback: change_callback.call(newid)
	get:
		return _adjid
var _adjid : int = -93899
var _valid_adjids : Array[int]
func _init(valid_ids : Array[int], _change_cb : Callable = Callable()):
	assert(valid_ids.size()>0)
	self._valid_adjids = valid_ids
	_adjid = self._valid_adjids[0]
	change_callback = _change_cb
func try_set(newid:int) -> bool:
	if newid != _adjid:
		id = newid
		return true
	else: return false
