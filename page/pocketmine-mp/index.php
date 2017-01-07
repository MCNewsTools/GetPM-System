<?php
date_default_timezone_set("Asia/Taipei");
$info = file_get_contents('https://getpm.reh.tw/api/channel/json.php?channel=PocketMine-MP&type=1');
$json_decode = json_decode($info, true);
?>
<html><head>
    <meta name="og:description" content="多 PocketMine 核心下載 For Minecraft 資訊工具網">
    <meta property="og:title" content="PocketMine-MP (PMMP) | PocketMine Downloads - Minecraft 資訊工具網">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://getpm.reh.tw/page/pocketmine-mp/">
    <meta property="og:image" content="https://getpm.reh.tw/images/pm_logo.png">
    <meta property="og:site_name" content="PocketMine Downloads - Minecraft 資訊工具網">
    <meta name="keywords" content="php,PocketMine,core,核心,Minecraft 資訊工具網">
    <meta name="description" content="多 PocketMine 核心下載 For Minecraft 資訊工具網">
    <title>PocketMine-MP (PMMP) | PocketMine Downloads - Minecraft 資訊工具網</title>
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
            <li class="active">
              <a>PocketMine-MP (PMMP)</a>
            </li>
            <li>
              <a href="../genisys">Genisys</a>
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
              <li class="active">PocketMine-MP (PMMP)</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <div class="section section-warning">
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <h1>PocketMine-MP (PMMP)</h1>
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
  

</body></html>