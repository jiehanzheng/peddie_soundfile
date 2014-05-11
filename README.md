Peddie Sound File Manager
=========================

Installation
------------

### System package requirements
Recommended Debian / Ubuntu packages are noted in parenthesis.

* MySQL and libmysql Ruby bindings (`mysql-server` `mysql-client` `libmysql-ruby` `libmysqlclient-dev`)
* Ogg Vorbis tools (`vorbis-tools`)
* Nginx web server with X-Accel-Redirect support (`nginx`)

#### Database
You need to create a MySQL database on server and create a `database.yml`.

#### Nginx as a reverse proxy
```nginx
upstream soundfile_puma {
  server unix:/path/to/peddie_soundfile/shared/tmp/sockets/puma.sock;
}

server {
  # ...
  root /path/to/peddie_soundfile/current/public;

  client_max_body_size 100M;

  try_files $uri/index.html $uri.html $uri @rails;

  location @rails {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://soundfile_puma;
  }
}
```

Sound files are uploaded from client as raw WAV files, and uploading 1 minute of sound file takes roughly 5 MB of data traffic.  100M of client_max_body_size should, in theory, allow users to upload around 20 minutes of sound file per request.

Once uploaded, sound files are then converted to Ogg Vorbis to save disk space.

### secrets.yml
Although we store session data in the database, it is still recommended that you have a secret `secrets.yml`.

```ruby
development:
  secret_key_base: 
  
test:
  secret_key_base: 
  
production:
  secret_key_base: 
```

Generate, copy and paste secret_key_bases for each environment by running `rake secret`.

### Google OAuth 2.0 application key
Register your application with Google and fill out your client ID and secret in `config/initializers/omniauth.rb`.

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
    "<CLIENT_ID>", 
    "<CLIENT_SECRET>",
    :access_type => :online
end
```

### Deployment
```bash
bundle exec cap production deploy
```
