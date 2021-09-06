dir=File.expand_path('../', __FILE__)
worker_processes 1
working_directory "#{dir}"
timeout 20

listen 8080

pid         "#{dir}/../pids/unicorn.pid"

stderr_path "#{dir}/../log/unicorn.stderr.log"
stdout_path "#{dir}/../log/unicorn.stdout.log"
