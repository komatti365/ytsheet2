#!/usr/bin/perl
######################################################################
##  ゆとシートⅡ 一括パーミッション設定（セットアップスクリプト）
##  さくらのレンタルサーバ等でアップロード後にブラウザから1回実行してください
######################################################################
use strict;
use utf8;
use CGI::Carp qw(fatalsToBrowser);

binmode STDOUT, ':utf8';
print "Content-Type: text/html; charset=UTF-8\n\n";

print <<"HTML";
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>ゆとシートⅡ パーミッション一括設定</title>
  <style>
    body { font-family: sans-serif; background: #f4f7f9; color: #333; margin: 40px auto; max-width: 800px; line-height: 1.6; }
    .card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 30px; }
    h1 { color: #1976d2; border-bottom: 2px solid #1976d2; padding-bottom: 10px; font-size: 22px; }
    .success { background: #e8f5e9; border: 1px solid #c8e6c9; color: #2e7d32; padding: 15px; border-radius: 5px; font-weight: bold; margin: 20px 0; }
    table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px; }
    th, td { border: 1px solid #ddd; padding: 6px 10px; text-align: left; }
    th { background: #f0f4f8; }
    .log-box { max-height: 250px; overflow-y: auto; background: #263238; color: #eceff1; padding: 10px; border-radius: 5px; font-family: monospace; font-size: 12px; }
    .del-btn { display: inline-block; background: #d32f2f; color: #fff; padding: 10px 20px; border-radius: 4px; text-decoration: none; font-weight: bold; margin-top: 15px; }
    .del-btn:hover { background: #b71c1c; }
  </style>
</head>
<body>
  <div class="card">
    <h1>ゆとシートⅡ パーミッション一括設定ツール</h1>
HTML

# 削除リクエスト処理
my $query = $ENV{'QUERY_STRING'} || '';
if ($query eq 'delete') {
    unlink $0;
    print "<div class=\"success\">setup.cgi を正常に削除しました。セットアップ完了です！</div>";
    print "<p><a href=\"./aa/\">⇒ アフターアーカイブ トップへ移動</a></p>";
    print "<p><a href=\"./sw2.5/\">⇒ ソードワールド2.5 トップへ移動</a></p>";
    print "</div></body></html>";
    exit;
}

my @logs;
my $dir_count = 0;
my $cgi_count = 0;
my $file_count = 0;
my $data_count = 0;

sub process_dir {
    my ($dir) = @_;
    opendir(my $dh, $dir) or return;
    my @entries = readdir($dh);
    closedir($dh);

    foreach my $entry (@entries) {
        next if $entry eq '.' || $entry eq '..';
        my $path = "$dir/$entry";
        $path =~ s|^\./||;

        if (-d $path) {
            if ($entry eq 'data') {
                chmod 0707, $path;
                push @logs, "【データフォルダ】 707 -> $path";
                $data_count++;
            } else {
                chmod 0705, $path;
                push @logs, "【ディレクトリ】   705 -> $path";
                $dir_count++;
            }
            process_dir($path);
        } elsif (-f $path) {
            if ($entry =~ /\.cgi$/) {
                chmod 0705, $path;
                push @logs, "【CGIファイル】    705 -> $path";
                $cgi_count++;
            } else {
                chmod 0604, $path;
                $file_count++;
            }
        }
    }
}

# カレントディレクトリから再帰処理
chmod 0705, '.';
process_dir('.');

print <<"HTML";
    <div class="success">
      パーミッションの一括設定が完了しました！<br>
      （CGI: ${cgi_count}件 / ディレクトリ: ${dir_count}件 / データフォルダ: ${data_count}件 / 通常ファイル: ${file_count}件）
    </div>

    <h3>設定結果サマリー</h3>
    <table>
      <tr><th>設定種別</th><th>パーミッション</th><th>対象</th><th>件数</th></tr>
      <tr><td>CGIプログラム</td><td><b>705</b> (rwx---r-x)</td><td>*.cgi</td><td>${cgi_count} 件</td></tr>
      <tr><td>データ保存フォルダ</td><td><b>707</b> (rwx---rwx)</td><td>*/data</td><td>${data_count} 件</td></tr>
      <tr><td>通常ディレクトリ</td><td><b>705</b> (rwx---r-x)</td><td>全フォルダ</td><td>${dir_count} 件</td></tr>
      <tr><td>設定・通常ファイル</td><td><b>604</b> (rw----r--)</td><td>*.pl, *.html, *.css 等</td><td>${file_count} 件</td></tr>
    </table>

    <h3>処理ログ</h3>
    <div class="log-box">
HTML

foreach my $log (@logs) {
    print "$log<br>\n";
}

print <<"HTML";
    </div>

    <div style="margin-top: 25px; text-align: center;">
      <p>セキュリティのため、設定完了後はこの setup.cgi を削除してください。</p>
      <a href="?delete" class="del-btn">このツール (setup.cgi) を削除して完了する</a>
    </div>
  </div>
</body>
</html>
HTML
