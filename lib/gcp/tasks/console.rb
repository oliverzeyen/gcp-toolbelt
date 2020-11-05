### Console Tasks and methods
module GCP
  module Task
    class Console < TaskBase
      LIST_COMMAND = "gcloud app instances list --project %s --service=%s --filter=VM_STATUS:RUNNING --format=json".freeze
      SSH_COMMAND = "gcloud app instances ssh %s --version %s --project %s --service %s".freeze
      # {}"gcloud app instances ssh #{instance_id} --version #{instance_version} --project #{project_name} --service=#{service_name}"

      private

      def tasks
        task console: 'console:staging'

        namespace :console do

          task production: 'console:production:app'
          namespace :production do
            task :app do
              console :production, :app
            end

            task :worker do
              console :production, :worker
            end
          end

          task staging: 'console:staging:app'
          namespace :staging do
            task :app do
              console :staging, :app
            end

            task :worker do
              console :staging, :worker
            end
          end
        end
      end

      def console(project_env, service)
        project_name = config.data[project_env][:project]
        service_name = config.data[project_env][:services][service]

        puts Rainbow('Fetching instance list from GCP API to acquire instance id and version!').yellow
        puts Rainbow('This may take a while…').yellow
        response_body, stderr, status = shell_helper.execute(format(LIST_COMMAND, project_name, service_name))

        if status.success?
          puts Rainbow('List acquired!').yellow
          instance_list = JSON.parse(response_body).first
          instance_id = instance_list['id']
          instance_version = instance_list['version']

          puts Rainbow("Opening SSH session on #{instance_id}…").yellow
          puts Rainbow('Type: ').yellow +
               Rainbow("docker exec -it gaeapp /bin/bash -c 'bundle exec rails c' ").cyan.bright +
               Rainbow('to open the Rails Console, once the SSH session is open').yellow

          sh format(SSH_COMMAND, instance_id, instance_version, project_name, service_name)
        else
          puts "Sorry… Something went wrong! Error: #{stderr}"
        end
      end

    end
  end
end
