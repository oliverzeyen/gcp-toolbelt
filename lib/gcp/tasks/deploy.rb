module GCP
  module Task
    class Deploy < TaskBase

      private

      def tasks
        task deploy: 'deploy:staging:both'

        namespace :deploy do
          task staging: 'deploy:staging:both'
          task production: 'deploy:production:both'

          namespace :production do
            task :worker do
              deploy :production, [:worker]
            end

            task :app do
              deploy :production, [:app]
            end

            task :both do
              deploy :production, [:app, :worker]
            end
          end

          namespace :staging do
            task :worker do
              deploy :staging, [:worker]
            end

            task :app do
              deploy :staging, [:app]
            end

            task :both do
              deploy :staging, [:app, :worker]
            end
          end

        end
      end

      def deploy(project_env, services)
        sh "gcloud --project #{config.data[project_env][:project]} app deploy #{config.deploy_files_to_s(project_env, services)}"
      end
    end
  end
end
