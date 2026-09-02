#!/usr/bin/perl
######################################################################
##  ゆとシートⅡ OAuth2 認証エンドポイント (blp)
######################################################################
use strict;
use utf8;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:all/;

our $core_dir = '../_core';
use lib '../_core/module';

require $core_dir.'/lib/config-default.pl';
if (-e './config.cgi') {
  require './config.cgi';
}
require $core_dir.'/lib/subroutine.pl';
require $core_dir.'/lib/oauth.pl';

my $code = param("code");
my $state = param("state") || './';
my $redirect_to = $state;
if ($redirect_to !~ /^[a-zA-Z0-9_\-\.\/\?=&%#]+$/ || $redirect_to =~ /^\/\//) {
  $redirect_to = './';
}

if (!$code) {
  &error("認証コードが見つかりません。やり直してみてください。");
  exit;
}

my $token = &getAccessToken($code);

if ($token) {
  my @userinfo = &getUserInfo($token);

  if ( ($set::oauth_service eq 'Discord') && (@set::oauth_discord_login_servers) ) {
    if ( &isDiscordServerIncluded($token, @set::oauth_discord_login_servers) ) {
      # 指定したサーバに所属している
    } else {
      &error("指定されたDiscordサーバに所属していないため利用できません。");
      exit;
    }
  }

  if (! &isIdExist($userinfo[0]) ) {
    &registerUser(@userinfo);
  }

  my $session_token = &generateToken();
  my $cookie_header = &registerToken($userinfo[0], $session_token);

  print "Status: 302 Found\n";
  print $cookie_header;
  print "Location: $redirect_to\n";
  print "Content-Type: text/html; charset=UTF-8\n\n";

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
  &error("ログインに失敗しました。認証トークンを取得できませんでした。");
}
