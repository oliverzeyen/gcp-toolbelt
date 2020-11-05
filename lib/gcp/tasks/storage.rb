module GCP
  module Task
    class Storage < TaskBase
      COPY_COMMAND = 'gsutil cp "%s" "%s"'.freeze
      LIST_COMMAND = 'gsutil ls gs://%s'.freeze
      RECENT_FILE_COMMAND = 'gsutil ls -l gs://%s | sort -k 2 | tail -n 2 | head -1'.freeze
      BUCKET_FILE = 'gs//%s/%s'.freeze

      private

      def tasks
        namespace :storage do
          namespace :sql_dump do
            task :production_to_staging do
              cp_env_sql_dump :production, :staging
            end

            task :download do
              download_sql_dump :production
            end
          end
        end
      end

      def cp_env_sql_dump(source_project_env, target_project_env)
        source_bucket = config.data[source_project_env][:db_export_bucket]
        recent_dump_file = gsutil.recent_file(source_bucket)
        source = format(BUCKET_FILE, source_bucket, recent_dump_file)

        target_bucket = config.data[target_project_env][:db_import_bucket]
        target = format(BUCKET_FILE, target_bucket, recent_dump_file)

        shell.execute_stdout(format(COPY_COMMAND, source, target))
      end

      def download_sql_dump(source_project_env)
        source_bucket = config.data[source_project_env][:db_export_bucket]
        download_dir = config.data[:sql_dump_download_dir]
        source_file = gsutil.recent_file(source_bucket)
        shell.execute_stdout(format(COPY_COMMAND, source_file, download_dir))
      end
    end
  end
end
