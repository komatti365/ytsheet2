#!/usr/bin/perl
######################################################################
##  ゆとシートⅡ 共通 OAuth2 認証エンドポイント
######################################################################
use strict;
use utf8;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:all/;

binmode STDOUT, ':utf8';

our $core_dir = './_core';
use lib './_core/module';

require $core_dir.'/lib/config-default.pl';
if (-e $core_dir.'/config.cgi') {
  require $core_dir.'/config.cgi';
}
require $core_dir.'/lib/subroutine.pl';
require $core_dir.'/lib/oauth.pl';

my $code = param("code");
my $state = param("state") || './';

# リダイレクト先URLのバリデーション
my $redirect_to = $state;
if ($redirect_to !~ /^[a-zA-Z0-9_\-\.\/\?=&%#]+$/ || $redirect_to =~ /^\/\//) {
  $redirect_to = './';
}

sub oauthError {
  my ($msg) = @_;
  print "Content-Type: text/html; charset=UTF-8\n\n";
  print <<"HTML";
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>ログインエラー - ゆとシートⅡ</title>
  <style>
    body { font-family: sans-serif; background: #f8f9fa; color: #333; margin: 50px auto; max-width: 600px; line-height: 1.6; }
    .card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 30px; border-top: 4px solid #d32f2f; }
    h1 { font-size: 20px; color: #d32f2f; margin-top: 0; }
    p { margin: 15px 0; }
    a.btn { display: inline-block; background: #1976d2; color: #fff; padding: 10px 20px; border-radius: 4px; text-decoration: none; font-weight: bold; margin-top: 15px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>ログインに失敗しました</h1>
    <p>$msg</p>
    <a href="$redirect_to" class="btn">トップページに戻る</a>
  </div>
</body>
</html>
HTML
  exit;
}

if (!$code) {
  oauthError("Discordからの認証コードが取得できませんでした。ログインをやり直してください。");
}

my $token = &getAccessToken($code);

if ($token) {
  my @userinfo = &getUserInfo($token);
  
  if (!@userinfo || !$userinfo[0]) {
    oauthError("Discordユーザー情報の取得に失敗しました。");
  }

  if ( ($set::oauth_service eq 'Discord') && (@set::oauth_discord_login_servers) ) {
    if ( &isDiscordServerIncluded($token, @set::oauth_discord_login_servers) ) {
      # 指定したサーバに所属している
    } else {
      oauthError("指定されたDiscordサーバに所属していないため利用できません。");
    }
  }

  if (! &isIdExist($userinfo[0]) ) {
    &registerUser(@userinfo);
  }

  my $session_token = &generateToken();
  my $cookie_header = &registerToken($userinfo[0], $session_token);

  # HTTPレスポンスヘッダー出力
  print "Status: 302 Found\n";
  print "Cache-Control: no-store, no-cache, must-revalidate, max-age=0\n";
  print "Pragma: no-cache\n";
  print $cookie_header;
  print "Location: $redirect_to\n";
  print "Content-Type: text/html; charset=UTF-8\n\n";

  # HTML/JS フォールバック
  print <<"HTML";
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0;url=$redirect_to">
  <title>ログイン完了</title>
</head>
<body>
  <p>ログインが完了しました。<a href="$redirect_to">元の画面に戻らない場合はここをクリックしてください。</a></p>
  <script>location.replace("$redirect_to");</script>
</body>
</html>
HTML
  exit;
} else {
  oauthError("アクセストークンの取得に失敗しました。DiscordのOAuth設定（Client SecretやRedirect URI）をご確認ください。");
}
