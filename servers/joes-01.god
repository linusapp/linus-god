apps_root = "/srv"
site_root = "#{apps_root}/linusapp/current"

pids = {
  :linus_web => "#{apps_root}/linusapp/shared/tmp/pids/server.pid",
  :linus_workers => "#{apps_root}/linusapp/shared/tmp/pids/sidekiq.pid"
}

logs = {
  :linus_web => "#{apps_root}/linusapp/shared/log/development.log",
  :linus_workers => "#{apps_root}/linusapp/shared/log/sidekiq.log"
}

God.watch do |w|
  w.name = "linus_web"
  w.group = "linus_site"
  w.interval = 30.seconds
  w.dir = site_root
  w.log = logs[:linus_web]
  w.pid_file = pids[:linus_web]
  w.start = "bundle exec rails server -d -p 3000"
  w.stop = "kill $(cat #{pids[:linus_web]})"
  w.behavior(:clean_pid_file)

  w.transition(:init, { true => :up, false => :start}) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition(:up, :restart) do |on|
    on.condition(:file_touched) do |c|
      c.interval = 5.seconds
      c.path = File.join(site_root, 'tmp', 'restart.txt')
    end
  end
end

God.watch do |w|
  w.name = "linus_workers"
  w.group = "linus_site"
  w.interval = 30.seconds
  w.dir = site_root
  w.log = logs[:linus_workers]
  w.pid_file = pids[:linus_workers]
  w.start = "bundle exec sidekiq -d -L log/sidekiq.log -P #{pids[:linus_workers]}"
  w.stop = "bundle exec sidekiqctl stop #{pids[:linus_workers]} 5"
  w.behavior(:clean_pid_file)

  w.transition(:init, { true => :up, false => :start}) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition(:up, :restart) do |on|
    on.condition(:file_touched) do |c|
      c.interval = 5.seconds
      c.path = File.join(site_root, 'tmp', 'restart.txt')
    end
  end
end