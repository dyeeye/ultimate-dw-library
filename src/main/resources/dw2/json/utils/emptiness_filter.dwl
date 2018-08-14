%dw 2.0

// @input elem element to be filtered
// filter empty json objects - { } from 
// provided element.
fun filterEmptyObjects(elem) = 
	elem match {
		case is Object -> if(isEmpty(elem)) null else elem mapObject ($$): filterEmptyObjects($),
		case is Array -> elem map filterEmptyObjects($)
		else -> elem
	}
