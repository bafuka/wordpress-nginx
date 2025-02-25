server {
	# Ports to listen on, uncomment one.
	listen 443 ssl http2;
	listen [::]:443 ssl http2;

	# Server name to listen for
	server_name shitizhijia.com;

	# Path to document root
	root /sites/shitizhijia.com/public;

	# Paths to certificate files.
    ssl_certificate /etc/letsencrypt/live/shitizhijia.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shitizhijia.com/privkey.pem;

	# File to be used as index
	index index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/shitizhijia.com/logs/access.log;
	error_log /sites/shitizhijia.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	# SSL rules
	include global/server/ssl.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		# Change socket if using PHP pools or different PHP version
        fastcgi_pass unix:/run/php/php7.1-fpm.sock;
        #fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        #fastcgi_pass unix:/var/run/php5-fpm.sock;
	}

    # Rewrite robots.txt
    rewrite ^/robots.txt$ /index.php last;
}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name shitizhijia.com www.shitizhijia.com;

	return 301 https://shitizhijia.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443;
	listen [::]:443;
	server_name www.shitizhijia.com;

	return 301 https://shitizhijia.com$request_uri;
}