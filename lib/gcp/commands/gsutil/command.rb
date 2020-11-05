module GCP
  module Command
    class Gsutil < GCP::Command::CommandBase
      EXECUTABLE = :gsutil

      attr_accessor :source_path, :chained_command

      def initialize
        super

        @source_path = nil
        @target_path = nil
        @chained_command = nil
      end

      # Not used yet! For validation!
      COMMANDS = [
        'acl' =>              'Get, set, or change bucket and/or object ACLs',
        'bucketpolicyonly' => 'Configure uniform bucket-level access',
        'cat' =>              'Concatenate object content to stdout',
        'compose' =>          'Concatenate a sequence of objects into a new composite object.',
        'config' =>           'Obtain credentials and create configuration file',
        'cors' =>             'Get or set a CORS JSON document for one or more buckets',
        'cp' =>               'Copy files and objects',
        'defacl' =>           'Get, set, or change default ACL on buckets',
        'defstorageclass' =>  'Get or set the default storage class on buckets',
        'du' =>               'Display object size usage',
        'hash' =>             'Calculate file hashes',
        'help' =>             'Get help about commands and topics',
        'hmac' =>             'CRUD operations on service account HMAC keys.',
        'iam' =>              'Get, set, or change bucket and/or object IAM permissions.',
        'kms' =>              'Configure Cloud KMS encryption',
        'label' =>            'Get, set, or change the label configuration of a bucket.',
        'lifecycle' =>        'Get or set lifecycle configuration for a bucket',
        'logging' =>          'Configure or retrieve logging on buckets',
        'ls' =>               'List providers, buckets, or objects',
        'mb' =>               'Make buckets',
        'mv' =>               'Move/rename objects',
        'notification' =>     'Configure object change notification',
        'perfdiag' =>         'Run performance diagnostic',
        'rb' =>               'Remove buckets',
        'requesterpays' =>    'Enable or disable requester pays for one or more buckets',
        'retention' =>        'Provides utilities to interact with Retention Policy feature.',
        'rewrite' =>          'Rewrite objects',
        'rm' =>               'Remove objects',
        'rsync' =>            'Synchronize content of two buckets/directories',
        'setmeta' =>          'Set metadata on already uploaded objects',
        'signurl' =>          'Create a signed url',
        'stat' =>             'Display object status',
        'test' =>             'Run gsutil unit/integration tests (for developers)',
        'ubla' =>             'Configure Uniform bucket-level access',
        'update' =>           'Update to the latest gsutil release',
        'version' =>          'Print version info about gsutil',
        'versioning' =>       'Enable or suspend versioning for one or more buckets',
        'web' =>              'Set a main page and/or error page for one or more buckets'
        ].freeze

      def ls(path, *options)
        result = shell.execute(to_executable(:ls, path, *options))
        multi_line_result(result.body)
      end

      def cp(path)
        start_copy_process
        @source_path = path
        return self
      end

      def to(path)
        return unless source_path_present? && copy_in_progress?

        from = source_path
        end_copy_process
        to_executable(:cp, from, path)
      end

      def recent_file(bucket_name)
        bucket = to_gs_path(bucket_name)
        executable = to_executable('ls -l', bucket, '| sort -k 2', '| tail -n 2', '| head -1')
        result = shell.execute(executable)

        if result.success?
          parse_gs_filename(result.body)
        else
          abort result.error
        end
      end

      private

      ## gs path helpers
      def to_gs_file(*path_segements)
        format("gs://%s", path_segements.join('/'))
      end

      def to_gs_path(*path_segements)
        to_gs_file(*path_segements) + '/'
      end

      ## List helpers
      # TDOD: Replace withdedicated result object
      def multi_line_result(result_body)
        result_body.split("\n")
      end

      ## Sanitizer
      def parse_gs_filename(raw_file_string)
        raw_file_string.match(%r{gs://(.*)})[0]
      end

      # Copy helpers
      def start_copy_process
        @chained_command = :cp
      end

      def end_copy_process
        @source_path = nil
        @chained_command = nil
      end

      def copy_in_progress?
        chained_command == :cp
      end

      def source_path_present?
        !!source_path
      end
    end
  end
end
