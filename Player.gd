extends MovingGuy

const STAND = 1
const RUN = 2
const AIR = 3
var floorstate = Adj.new([AIR,STAND,RUN], func(fsid):match fsid:
	STAND: spr.setup([92])
	RUN: spr.setup([92,93],8)
	AIR: spr.setup([93])
)
var facingdir = Adj.new([1,-1], func(dirid): spr.flip_h = dirid < 0)

func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	velocity.x = move_toward(velocity.x, pin.stick.x, 0.1)
	velocity.y = move_toward(velocity.y, 4.0, 0.1)
	if pin.a.pressed: bufs.setmin(JUMPBUF, 4)
	if bufs.try_consume([JUMPBUF,FLORBUF]):
		velocity.y = -2.0
	process_slidey_move()
	
	if pin.stick.x: facingdir.id = -1 if pin.stick.x < 0 else 1
	if not bufs.has(FLORBUF): floorstate.id = AIR
	elif pin.stick.x: floorstate.id = RUN
	else: floorstate.id = STAND
