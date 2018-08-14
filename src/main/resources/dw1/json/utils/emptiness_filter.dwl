%dw 1.0
// @input elem single property from payload
// Check if element is empty or not
%function notEmpty(elem)
	(elem default {}) != {}

// @input elem element to be filtered
// filter empty json objects - { } from 
// provided element.
%function filterEmptyObjects(elem)
	elem match {
		:object -> (elem mapObject ($$): filterEmptyObjects($)) when notEmpty(elem) otherwise null,
		:array -> elem map filterEmptyObjects($),
		default -> elem
	}
---
{
	filterEmptyObjects: filterEmptyObjects
}