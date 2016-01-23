class Map
  # マップサイズ
  @MAP_X = 1000
  @MAP_Y = 800
  
  # 街の数
  @TOWN_NUM = 15
  # 街の最低距離
  @TOWN_DISTANCE_MIN = 40

  # 陸地面積の割合
  @LAND_RATE = 0.02


  # 街
  @towns : []

  @init:->


  @drawLand:->
    start = Utility.militime(true)
    $('#map').css({
      width : @MAP_X+'px'
      height : @MAP_Y+'px'
    })
    posAry = @generateLand()
    for [x, y] in posAry
      img = $('<img>').attr('src', './img/land.png').addClass('town').css({
        left: ''+x+'px'
        top : ''+y+'px'
      })
      $('#map').append img
    end = Utility.militime(true)
    console.log(""+(end - start)+" sec")

  @drawTown:->
    start = Utility.militime(true)
    $('#map').css({
      width : @MAP_X+'px'
      height : @MAP_Y+'px'
    })
    posAry = @generatePos()
    for [x, y] in posAry
      img = $('<img>').attr('src', './img/town.png').addClass('town').css({
        left: ''+x+'px'
        top : ''+y+'px'
      })
      $('#map').append img
    end = Utility.militime(true)
    console.log(""+(end - start)+" sec")

  # 陸地を決める
  @generateLand:->
    # 陸地は何マスになるか
    landNum = Math.floor @MAP_X * @MAP_Y * @LAND_RATE

    # ルンバを10台走らせて指定面積になるまでやる
    lumbaScale = 3 # ルンバの大きさ
    landHash = {}
    lumba = []
    lumba.push [Math.floor(@MAP_X/2), Math.floor(@MAP_Y/2)] for t in [0...10]
    while Utility.count(landHash) < landNum
      for lu in [0...lumba.length]
        newX = lumba[lu][0] + Utility.rand(-1, 1)
        newY = lumba[lu][1] + Utility.rand(-1, 1)
        continue unless 0 <= newX < @MAP_X-(lumbaScale-1) and 0 <= newY < @MAP_Y-(lumbaScale-1)
        lumba[lu] = [newX, newY]
        for xPlus in [0...lumbaScale]
          for yPlus in [0...lumbaScale]
            landHash[''+(newX+xPlus)+'.'+(newY+yPlus)] = true
    # 精算
    res = []
    for key, value of landHash
      [x, y] = key.split('.')
      res.push [Number(x), Number(y)]
    res


  # 街の数、最低距離を守りながら、座標を決定
  @generatePos:->
    posAry = []

    # ランダムに置く方法
    randomPut = =>
      [pickX, pickY] = [Utility.rand(0, @MAP_X-1), Utility.rand(0, @MAP_Y-1)]
      flag = false
      for [x, y] in posAry
        # ダメだった
        if (pickX - x) ** 2 + (pickY - y) ** 2 < @TOWN_DISTANCE_MIN ** 2
          return false
      [pickX, pickY]
    # 全走査する
    checkPut = =>
      mapAry = Utility.generateArray @MAP_X, @MAP_Y, true
      # 配置不可能な座標をぜんぶ塗る
      for [posX, posY] in posAry
        for x in [posX-@TOWN_DISTANCE_MIN..posX+@TOWN_DISTANCE_MIN]
          continue unless 0 <= x < @MAP_X
          for y in [posY-@TOWN_DISTANCE_MIN...posY+@TOWN_DISTANCE_MIN]
            continue unless 0 <= y < @MAP_Y
            mapAry[x][y] = false if (posX - x) ** 2 + (posY - y) ** 2 < @TOWN_DISTANCE_MIN ** 2
      # 配置可能な座標を列挙
      canPut = []
      for x in [0...mapAry.length]
        for y in [0...mapAry[x].length]
          canPut.push [x, y] if mapAry[x][y]
      # 配置できない場合はfalse
      return false if canPut.length is 0
      # できる場合はそれを返す
      canPut.shuffle().pop()

    # 街の数だけ生成
    for t in [0...@TOWN_NUM]
      # 100回ランダムに試す
      randomComplete = false
      for rt in [0...100]
        res = randomPut()
        # ランダムに失敗したら次
        if res is false
          continue
        # 成功したら終わり
        posAry.push res
        randomComplete = true
        break
      # 100回以内にランダムでいけたら次
      continue if randomComplete

      # ダメだったので全通り
      res = checkPut()
      # 全通りでもダメだったら生成できなかった
      return false if res is false
      # いけた
      posAry.push res

    posAry




