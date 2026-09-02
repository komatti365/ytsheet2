use strict;
use utf8;
use LWP::UserAgent;
use JSON::PP;
use Fcntl qw(:DEFAULT :flock);
use File::Path qw(mkpath);
use File::Basename qw(dirname);

my $browser = LWP::UserAgent->new(
  ssl_opts => {
    SSL_verify_mode => 0,
    verify_hostname => 0,
  },
  timeout => 15,
);

my %token_url_list = (
  'Discord' => 'https://discord.com/api/oauth2/token',
  'Google'  => 'https://accounts.google.com/o/oauth2/token'
);
my %client_name_list = (
  'Discord' => 'DiscordBot (ytsheet, 6)',
  'Google'  => 'Google API Request (ytsheet)'
);


sub getAccessToken {  
  my $code = $_[0];
  my $token_url = $token_url_list{$set::oauth_service};
  return '' unless $token_url;

  my $token_request = HTTP::Request->new(POST => $token_url);
  $token_request->content_type('application/x-www-form-urlencoded');
  $token_request->header("User-Agent" => $client_name_list{$set::oauth_service});
  my $body = "redirect_uri=$set::oauth_redirect_url&scope=$set::oauth_scope&client_id=$set::oauth_client_id&client_secret=$set::oauth_secret_id&grant_type=authorization_code&code=$code";
  $token_request->content($body);
  my $token_response = $browser->request($token_request);
  
  if (!$token_response->is_success) {
    return '';
  }
  
  my $parsed;
  eval {
    $parsed = decode_json($token_response->content);
  };
  if ($parsed && ref($parsed) eq 'HASH' && $parsed->{'access_token'}) {
    return $parsed->{'access_token'};
  }
  return '';
}

sub getUserInfo {
  my $token = $_[0];
  return () unless $token;

  if ( $set::oauth_service eq 'Discord' ) {
    my $id_request = HTTP::Request->new(GET => 'https://discord.com/api/users/@me');
    $id_request->content_type('application/x-www-form-urlencoded');
    $id_request->header("User-Agent" => $client_name_list{$set::oauth_service});
    $id_request->header("Authorization" => "Bearer $token");
    my $id_response = $browser->request($id_request);
    
    if (!$id_response->is_success) {
      return ();
    }
    
    my $parsed;
    eval {
      $parsed = decode_json($id_response->content);
    };
    if ($parsed && ref($parsed) eq 'HASH') {
      my $id   = $parsed->{'id'};
      my $name = $parsed->{'username'};
      my $mail = $parsed->{'email'} || '';
      if ($id) {
        return ($id, $name, $mail);
      }
    }
  }
  if ( $set::oauth_service eq 'Google' ) {
    my $id_request = HTTP::Request->new(GET => 'https://www.googleapis.com/oauth2/v1/userinfo');
    $id_request->content_type('application/x-www-form-urlencoded');
    $id_request->header("User-Agent" => $client_name_list{$set::oauth_service});
    $id_request->header("Authorization" => "Bearer $token");
    my $id_response = $browser->request($id_request);
    
    if (!$id_response->is_success) {
      return ();
    }
    
    my $parsed;
    eval {
      $parsed = decode_json($id_response->content);
    };
    if ($parsed && ref($parsed) eq 'HASH') {
      my $id   = $parsed->{'id'};
      my $name = $parsed->{'name'};
      my $mail = $parsed->{'email'} || '';
      if ($id) {
        return ($id, $name, $mail);
      }
    }
  }
  return ();
}

sub isDiscordServerIncluded {
  my ($token, @list) = @_;
  return 1 unless @list;
  
  my $server_request = HTTP::Request->new(GET => 'https://discord.com/api/users/@me/guilds');
  $server_request->content_type('application/x-www-form-urlencoded');
  $server_request->header("User-Agent" => $client_name_list{$set::oauth_service});
  $server_request->header("Authorization" => "Bearer $token");
  my $server_response = $browser->request($server_request);
  return 0 unless $server_response->is_success;
  
  my $parsedServerList;
  eval {
    $parsedServerList = decode_json($server_response->content);
  };
  if ($parsedServerList && ref($parsedServerList) eq 'ARRAY') {
    foreach my $serverInfo (@$parsedServerList) {
      foreach my $serverId (@list) {
        if ($serverInfo->{'id'} eq $serverId) {
          return 1;
        }
      }
    }
  }
  return 0;
}

sub isIdExist {
  my $id = $_[0];
  return 0 unless -e $set::userfile;
  open (my $FH, '<', $set::userfile) or return 0;
  my $isUsed = 0;
  while (<$FH>){ 
    if ($_ =~ /^$id<>/){ $isUsed = 1; last; }
  }
  close ($FH);
  return $isUsed;
}

sub registerUser {
  my $id = $_[0];
  my $name = $_[1];
  my $mail = $_[2] || '';
  my $password = "";
  my @salt = ('0'..'9','A'..'Z','a'..'z','.','/');
  1 while (length($password .= $salt[rand(@salt)] ) < 12);
  
  my $dir = dirname($set::userfile);
  mkpath($dir) unless -d $dir;

  appendFile($set::userfile, sub {
    my ($WRITE) = @_;
    print $WRITE "$id<>".&encrypt($password)."<>$name<>$mail<>".time."<>\n";
  });

  if($set::player_dir){
    if (!-d $set::player_dir.$id){ mkpath($set::player_dir.$id); }
    if (sysopen (my $FH, $set::player_dir.$id.'/data.cgi', O_WRONLY | O_APPEND | O_CREAT, 0666)) {
      print $FH "id<>$id\n";
      print $FH "name<>$name\n";
      close ($FH);
    }
  }
}

sub generateToken {
  my $s;
  my @salt = ('0'..'9','A'..'Z','a'..'z','.','/');
  1 while (length($s .= $salt[rand(@salt)] ) < 12);
  return $s;
}

sub registerToken {
  my $id = $_[0];
  my $key = $_[1];
  my $now = time;
  
  my $dir = dirname($set::login_users);
  mkpath($dir) unless -d $dir;

  if (open (my $FH, '+<', $set::login_users)) {
    flock($FH, 2);
    my @list = <$FH>;
    seek($FH, 0, 0);
    foreach (@list){
      my @line = (split/<>/, $_);
      if (@line >= 3 && ($now - $line[2] < 60*60*24*365)){
        print $FH $_;
      }
    }
    print $FH "$id<>$key<>$now<>\n";
    truncate($FH, tell($FH));
    close ($FH);
  }
  elsif (open (my $FH, '>', $set::login_users)) {
    flock($FH, 2);
    print $FH "$id<>$key<>$now<>\n";
    close ($FH);
  }
  return &setCookie($set::cookie, $id, $key, '+365d');
}

1;