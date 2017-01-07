<?php
header('Content-type:text/json');
@$type = $_GET['type'];
@$channel = $_GET['channel'];
if ($type == 1) {
    if ($channel == 'Genisys') {
        $json = array(
            'version' => 'aa04bda',
            'api_version' => '2.1.0',
            'build' => Null,
            'date' => 1483145880,
            'details_url' => urlencode('https://gitlab.com/itxtech/genisys/pipelines?scope=branches'),
            'download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/Genisys/Genisys_aa04bda_2016-12-31_12-58-14.phar'),
            'alternate_download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/Genisys/Genisys_aa04bda_2016-12-31_12-58-14.phar')
        );
    } else if ($channel == 'ClearSky') {
        $json = array(
            'version' => '1.1dev',
            'api_version' => '2.1.0',
            'build' => 579,
            'date' => 1482034447,
            'details_url' => urlencode('http://robskebueba.no-ip.biz/CSPhar.php?type=1&branch=master'),
            'download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/ClearSky/ClearSky_1.1-php7.phar'),
            'alternate_download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/ClearSky/ClearSky_1.1-php7.phar')
        );
    } else if ($channel == 'PocketMine-MP') {
        $json = array(
            'version' => '1.6.1dev',
            'api_version' => '2.1.0',
            'build' => 139,
            'date' => 1483756094,
            'details_url' => urlencode('https://jenkins.pmmp.io/job/PocketMine-MP/139/'),
            'download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/PocketMine-MP/PocketMine-MP_1.6.1dev-139_4ace4b95_API-2.1.0.phar'),
            'alternate_download_url' => urlencode('https://getpm.reh.tw/api/channel/phar/PocketMine-MP/PocketMine-MP_1.6.1dev-139_4ace4b95_API-2.1.0.phar')
        );
    } else {
        $json = array(
            'version' => Null,
            'api_version' => Null,
            'build' => Null,
            'date' => Null,
            'details_url' => Null,
            'download_url' => Null,
            'alternate_download_url' => Null
        );
    }
    echo urldecode(json_encode($json));
} else {
    $info = file_get_contents('https://getpm.reh.tw/api/channel/json.php?channel='.$channel.'&type=1');
    $json_decode = json_decode($info, true);
    $json = '{
    "version": '.$json_decode['version'].',
    "api_version": '.$json_decode['api_version'].',
    "build": '.$json_decode['build'].',
    "date": '.$json_decode['date'].',
    "details_url": '.$json_decode['details_url'].',
    "download_url": '.$json_decode['download_url'].',
    "alternate_download_url": '.$json_decode['alternate_download_url'].',
}';
    echo $json;
}
?>