namespace :maintenance do
  desc "Maintenance start (edit config/maintenance.yml to provide parameters)"
  task :start do
    on roles(:web) do
      upload! "config/maintenance.yml", "#{current_path}/tmp/maintenance.yml"
    end
  end

  desc "Maintenance stop"
  task :stop do
    on roles(:web) do
      execute "rm #{current_path}/tmp/maintenance.yml"
    end
  end
end
