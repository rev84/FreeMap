class Map
  # マップサイズ
  @MAP_X = 500
  @MAP_Y = 400
  
  # 街の数
  @TOWN_NUM = 10
  # 街の最低距離
  @TOWN_DISTANCE_MIN = 40

  # 陸地面積の割合
  @LAND_RATE = 0.5


  # 街
  @towns : []

  @init:->


  @drawLand:->
    $('#land').attr({
      width : @MAP_X+'px'
      height : @MAP_Y+'px'
    })
    posAry = @generateLand()
    for [x, y] in posAry
      $('#land').drawRect({
        strokeStyle : '#7cfc00'
        x : x
        y : y
        width : 1
        height : 1
      })
      
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
    start = Utility.militime(true)
    
    # 陸地は何マスになるか
    landNum = Math.floor @MAP_X * @MAP_Y * @LAND_RATE

    # 陸地面積の10%のパーツを10個作る
    parts = []
    for t in [0...5]
      tempLandNum = Math.floor(landNum/10)
      # ルンバで作る
      lumbaScale = 5  # ルンバの大きさ
      lumbaNum   = 5
      tempLandHash = {}
      lumba = []
      lumba.push [Math.floor(@MAP_X/2), Math.floor(@MAP_Y/2)] for ln in [0...lumbaNum]
      while Utility.count(tempLandHash) < tempLandNum
        for lu in [0...lumba.length]
          newX = lumba[lu][0] + Utility.rand(-1, 1)
          newY = lumba[lu][1] + Utility.rand(-1, 1)
          continue unless 0 <= newX < tempLandNum-(lumbaScale-1) and 0 <= newY < tempLandNum-(lumbaScale-1)
          lumba[lu] = [newX, newY]
          for xPlus in [0...lumbaScale]
            for yPlus in [0...lumbaScale]
              tempLandHash[''+(newX+xPlus)+'.'+(newY+yPlus)] = true
      # 登録
      parts[t] = []
      minX = @MAP_X
      minY = @MAP_Y
      for key, value of tempLandHash
        [x, y] = key.split('.')
        x = Number x
        y = Number y
        minX = x if x < minX
        minY = y if y < minY
        parts[t].push [x, y]
      parts[t][i] = [parts[t][i][0] - minX, parts[t][i][1] - minY] for i in [0...parts[t].length]

    console.log("part:"+(Utility.militime(true) - start)+" sec")
    # 陸地面積を満たすまでつなげまくる
    landHash = {}
    landHash[''+Math.floor(@MAP_X/2)+'.'+Math.floor(@MAP_Y/2)] = true  # 中心をコアにする
    while Utility.count(landHash) < landNum
      # 既存マップからひとつピック
      [tempPosStr, _] = Utility.randPick(landHash)
      [x, y] = tempPosStr.split('.')
      [x, y] = [Number(x), Number(y)]
      # 新規マップからひとつピック
      newMapPosArray = (parts.shuffle())[0]
      # 新規マップのマス目をピック
      [newX, newY] = (newMapPosArray.shuffle())[0]
      # マップをオーバーしないかチェック
      isOver = false
      for pos in newMapPosArray
        unless 0 <= x + (pos[0] - newX) < @MAP_X
          isOver = true
          break
        unless 0 <= y + (pos[1] - newY) < @MAP_Y
          isOver = true
          break
      # オーバーしてたら別のを試す
      continue if isOver
      # いよいよ継ぎ足す
      for pos in newMapPosArray
        landHash[''+(x + (pos[0] - newX))+'.'+(y + (pos[1] - newY))] = true
    # 精算
    res = []
    for key, value of landHash
      [x, y] = key.split('.')
      res.push [Number(x), Number(y)]
    console.log("genEnd:"+(Utility.militime(true) - start)+" sec")
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




