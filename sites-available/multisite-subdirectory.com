server {
	# Ports to listen on
	listen 80;
	listen [::]:80;

	# Server name to listen for
	server_name shitizhijia.com;

	# Path to document root
	root /sites/shitizhijia.com/public;

	# File to be used as index
	index index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/shitizhijia.com/logs/access.log;
	error_log /sites/shitizhijia.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	# Multisite subdirectory install
	include global/server/multisite-subdirectory.conf;

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

# Redirect www to non-www
server {
	listen 80;
	listen [::]:80;
	server_name www.shitizhijia.com;

	return 301 $scheme://shitizhijia.com$request_uri;
}