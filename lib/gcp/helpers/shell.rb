require 'open3'

module GCP
  module Helper
    class Shell
      attr_accessor :body, :error, :success

      def initialize
      end

      def execute(command)
        result = Open3.capture3(command)

        @body = result[0]
        @error = result[1]
        @status = success?
        self
      end

      def execute_stdout(command)
        Open3.popen2e(command) do |_, stdout_stderr, wait_thread|
          stdout_stderr.each { |l| puts l }
          wait_thread.value
        end
      end

      def success?
        error.empty?
      end
    end
  end
end
