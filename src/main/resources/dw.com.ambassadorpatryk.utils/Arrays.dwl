%dw 2.0

// @input array of element to randomly reorder
fun shuffle(arr: Array) =
    arr orderBy random()
