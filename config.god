pwd = File.dirname(__FILE__)
apps_root = '/srv'
log_dir = "#{apps_root}/logs"

God.pid_file_directory = "#{apps_root}/pids"

God.load "#{pwd}/extensions/**/*.god"
God.load "#{pwd}/servers/*.god"