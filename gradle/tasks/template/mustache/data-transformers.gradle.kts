extra["transform-data"] = fun(dataIterable: Iterable<Any>): Iterable<Any> {
  val transformedData = mutableListOf<Any>()
  dataIterable.forEach { data ->
    if (data is MutableMap<*, *>) {
      createArraysForMaps(data as MutableMap<Any, Any?>)
    }
    transformedData.add(data)
  }
  return transformedData
}

/**
 * input:
 *   value: 4
 *   map:
 *     a: 1
 *     b: 2
 *
 * input ->
 *   value: 4
 *   map:
 *     a: 1
 *     b: 1
 *   mapArray:
 *     - key:   a
 *       value: 1
 *     - key:   b
 *       value: 2
 *
 * output:
 *   - key:   value
 *     value: 4
 *   - key: map
 *   - value:
 *       a: 1
 *       b: 2
 */
fun createArraysForMaps(map: MutableMap<Any, Any?>): Array<*> {
  val arrayItems = mutableListOf<Any>()
  val mapAdditions = mutableMapOf<Any, Any?>()
  val iterator = map.asIterable().iterator()
  while(iterator.hasNext()) {
    val item = iterator.next()
    arrayItems.add(mapOf("key" to item.key, "value" to item.value))
    if (item.value is Map<*, *>) {
      mapAdditions.put("${item.key}Array", createArraysForMaps(item.value as MutableMap<Any, Any?>))
    }
  }
  map.putAll(mapAdditions)
  return arrayItems.toTypedArray()
}