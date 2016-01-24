class Utility
  @generateArray:(x, y = null, val = null)->
    y = x if y is null
    res = []
    yAry = []
    for yy in [0...y]
      yAry[yy] = val
    for xx in [0...x]
      res[xx] = yAry.concat()
    res

  @militime:(get_as_float = false)->
    +new Date() / (if get_as_float then 1000 else 1)

  @rand:(min, max)->
    Math.round()
    Math.floor(Math.random() * (max - min + 1)) + min

  @count:(object)->
    Object.keys(object).length

  @randPick:(object)->
    limit = @rand(0, @count(object)-1)
    i = 0
    for key, value of object
      return [key, value] if i is limit
      i++
    false

Array::shuffle = ()->
  n = @length
  while n
    n--
    i = Utility.rand(0, n)
    [@[i], @[n]] = [@[n], @[i]]
  @

Array::in_array = (value)->
  for v in @
    return true if v is value
  false

Array::copy = ()->
  res = []
  for v in @
    res2 = []
    for v2 in v
      res2.push v2
    res.push res2
  res

