class Map
  # マップサイズ
  @MAP_X = 1000
  @MAP_Y = 800
  
  # 街の数
  @TOWN_NUM = 15
  # 街の最低距離
  @TOWN_DISTANCE_MIN = 100


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
    mapAry = Utility.generateArray @MAP_X, @MAP_Y, true
    posAry = []

    # 任意回生成
    for t in [0...@TOWN_NUM]
      # 配置可能な座標
      canPut = []

      # 配置可能な座標を列挙
      for x in [0...mapAry.length]
        for y in [0...mapAry[x].length]
          canPut.push [x, y] if mapAry[x][y]

      # 配置できない場合はfalse
      return false if canPut.length is 0

      # ランダムな座標を選定
      [pickX, pickY] = canPut.shuffle().pop()
      posAry.push [pickX, pickY]

      # 周囲を塗る
      for x in [pickX-@TOWN_DISTANCE_MIN..pickX+@TOWN_DISTANCE_MIN]
        continue unless 0 <= x < @MAP_X
        for y in [pickY-@TOWN_DISTANCE_MIN...pickY+@TOWN_DISTANCE_MIN]
          continue unless 0 <= y < @MAP_Y
          mapAry[x][y] = false if (pickX - x) ** 2 + (pickY - y) ** 2 < @TOWN_DISTANCE_MIN ** 2

    posAry