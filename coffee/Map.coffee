class Map
  # マップサイズ
  @MAP_X = 1000
  @MAP_Y = 800
  
  # 街の数
  @TOWN_NUM = 15
  # 街の最低距離
  @TOWN_DISTANCE_MIN = 200


  # 街
  @towns : []

  @init:->


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




