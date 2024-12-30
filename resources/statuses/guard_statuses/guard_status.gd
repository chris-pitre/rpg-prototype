class_name GuardStatus
extends Status

@export_category("Guard Status Characteristics")
@export var guard_type: GUARD = GUARD.NONE

enum GUARD {
	NONE,
	HIGH_GUARD,
	MIDDLE_GUARD,
	LOW_GUARD
}
