module GCP
  module Task
    class Log < TaskBase

      private

      def tasks
        task log: 'log:production:app'

        namespace :log do
          namespace :production do
            task :app do
              log :production, :app
            end

            task :worker do
              log :production, :worker
            end
          end

          namespace :staging do
            task :app do
              log :staging, :app
            end

            task :worker do
              log :staging, :worker
            end
          end
        end
      end

      def log(project_env, service)
        sh "gcloud app logs tail --project=#{config.data[project_env][:project]} -s #{service}"
      end
    end
  end
end
