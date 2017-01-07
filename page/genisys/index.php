<?php
date_default_timezone_set("Asia/Taipei");
$info = file_get_contents('https://getpm.reh.tw/api/channel/json.php?channel=Genisys&type=1');
$json_decode = json_decode($info, true);
?>
<html><head>
    <meta name="og:description" content="多 PocketMine 核心下載 For Minecraft 資訊工具網">
    <meta property="og:title" content="Genisys | PocketMine Downloads - Minecraft 資訊工具網">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://getpm.reh.tw/page/genisys/">
    <meta property="og:image" content="https://getpm.reh.tw/images/pm_logo.png">
    <meta property="og:site_name" content="PocketMine Downloads - Minecraft 資訊工具網">
    <meta name="keywords" content="php,PocketMine,core,核心,Minecraft 資訊工具網">
    <meta name="description" content="多 PocketMine 核心下載 For Minecraft 資訊工具網">
    <title>Genisys | PocketMine Downloads - Minecraft 資訊工具網</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
    <script type="text/javascript" src="//netdna.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <link href="//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="//pingendo.github.io/pingendo-bootstrap/themes/default/bootstrap.css" rel="stylesheet" type="text/css">
  </head><body>
    <div class="navbar navbar-default navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-ex-collapse">
            <span class="sr-only">導航欄</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="/"><span>PocketMine Downloads - Minecraft 資訊工具網</span></a>
        </div>
        <div class="collapse navbar-collapse" id="navbar-ex-collapse">
          <ul class="nav navbar-nav navbar-right">
            <li>
              <a href="/">首頁</a>
            </li>
            <li>
              <a href="../pocketmine-mp">PocketMine-MP</a>
            </li>
            <li class="active">
              <a>Genisys</a>
            </li>
            <li>
              <a href="../clearsky">ClearSky</a>
            </li>
            <li></li>
          </ul>
        </div>
      </div>
    </div>
    <div class="section">
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <ul class="breadcrumb">
              <li>
                <a href="/">首頁</a>
              </li>
              <li class="active">Genisys</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <div class="section section-warning">
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <h1>Genisys</h1>
            <p>版本: <?php echo $json_decode['version']; ?> | API: <?php echo $json_decode['api_version']; ?> | 建造第 <?php echo $json_decode['build']; ?>
              <br>發布日期: <?php echo date("Y-m-d H:i:s",$json_decode['date']); ?>
              <br>詳細資料:
              <a href="<?php echo $json_decode['details_url']; ?>" target="_blank"><?php echo $json_decode['details_url']; ?></a>
            </p>
          </div>
        </div>
        <div class="row">
          <div class="col-md-12">
            <a class="btn btn-primary" href="<?php echo $json_decode['download_url']; ?>"><?php echo '下載 Genisys_'.$json_decode['version'].'-'.$json_decode['build'].'_API-'.$json_decode['api_version'].'.phar'; ?></a>
          </div>
        </div>
      </div>
    </div>
    <div class="section section-info">
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <h1>取得 PHP</h1>
            <p>運行 PocketMine 需要安裝 PHP (<a href="../../PocketMine/PHP/" target="_blank">點我前往</a>) - <font color="red">指令安裝無需自行下載</font></p>
          </div>
        </div>
      </div>
    </div>
    <div class="section section-success">
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <h1>Linux / macOS 指令安裝</h1>
            <p class="lead">
              <b>English</b>
            </p>
            <pre>wget -q -O - https://getpm.reh.tw/en-US/ | bash -s - -v Genisys</pre>
            <pre>curl -sL https://getpm.reh.tw/en-US/ | bash -s - -v Genisys</pre>
            <br>
            <p class="lead">
              <b>繁體中文</b>
            </p>
            <pre>wget -q -O - https://getpm.reh.tw/zh-TW/ | bash -s - -v Genisys</pre>
            <pre>curl -sL https://getpm.reh.tw/zh-TW/ | bash -s - -v Genisys</pre>
            <br>
            <p class="lead">
              <b>简体中文</b>
            </p>
            <pre>wget -q -O - https://getpm.reh.tw/zh-CN/ | bash -s - -v Genisys</pre>
            <pre>curl -sL https://getpm.reh.tw/zh-CN/ | bash -s - -v Genisys</pre>
          </div>
        </div>
      </div>
    </div>
    <div class="section">
      <div class="container">
        <div class="row">
          <div class="col-md-12"></div>
        </div>
      </div>
    </div>
    <footer class="section section-danger">
      <div class="container">
        <div class="row">
          <div class="col-sm-6">
            <h1>GetPM System</h1>
            <p>此系統屬於 <a href="https://mc.reh.tw/" target="_blank">Minecraft 資訊工具網</a> 旗下系統
              <br>由 <a href="https://www.facebook.com/TPGoneTone/" target="_blank">旋風之音 (GoneTone)</a> (和其他朋友)編寫開發
              <br>此 GetPM 系統是開源的，放置在 <a href="https://github.com/MCNewsTools/getpm.mcpe.tw-source/" target="_blank">GitHub</a> 歡迎您一起幫助我們開發！</p>
          </div>
          <div class="col-sm-6">
            <p class="text-info text-right">
              <br>
              <br>
            </p>
            <div class="row">
              <div class="col-md-12 hidden-lg hidden-md hidden-sm text-left">
                <a href="https://mc.reh.tw/" target="_blank"><i class="fa fa-3x fa-fw text-inverse fa-globe"></i></a>
                <a href="https://www.facebook.com/MCNewsTools/" target="_blank"><i class="fa fa-3x fa-fw fa-facebook text-inverse"></i></a>
                <a href="https://twitter.com/MCNewsTools/" target="_blank"><i class="fa fa-3x fa-fw fa-twitter text-inverse"></i></a>
                <a href="https://github.com/MCNewsTools/getpm.mcpe.tw-source/" target="_blank"><i class="fa fa-3x fa-fw fa-github text-inverse"></i></a>
              </div>
            </div>
            <div class="row">
              <div class="col-md-12 hidden-xs text-right">
                <a href="https://mc.reh.tw/" target="_blank"><i class="fa fa-3x fa-fw text-inverse fa-globe"></i></a>
                <a href="https://www.facebook.com/MCNewsTools/" target="_blank"><i class="fa fa-3x fa-fw fa-facebook text-inverse"></i></a>
                <a href="https://twitter.com/MCNewsTools/" target="_blank"><i class="fa fa-3x fa-fw fa-twitter text-inverse"></i></a>
                <a href="https://github.com/MCNewsTools/getpm.mcpe.tw-source/" target="_blank"><i class="fa fa-3x fa-fw fa-github text-inverse"></i></a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </footer>
  

</body></html>