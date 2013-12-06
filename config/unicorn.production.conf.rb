LOG_PATH="/var/www/fake-clearsale/log"

listen 3000
worker_processes 2
stderr_path "#{LOG_PATH}/unicorn.stderr.log"
stdout_path "#{LOG_PATH}/unicorn.stdout.log"
pid "/tmp/fake-clearsale.pid"
