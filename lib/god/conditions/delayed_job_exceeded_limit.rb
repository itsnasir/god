module God
  module Conditions

    # Condition Symbol :delayed_job_exceeded_limit
    # Type: Poll
    #
    # Trigger when the resident delayed job processes is above a specified limit.
    #
    # Paramaters
    #   Required
    #     +pid_file+ is the pid file of the process in question. Automatically
    #                populated for Watches.
    #     +above+ is the amount of resident delayed job processes above which
    #             the condition should trigger.
    #
    # Examples
    #
    # Trigger if the process is using more than 100 megabytes of resident
    # memory (from a Watch):
    #
    #   on.condition(:memory_usage) do |c|
    #     c.above = 100.megabytes
    #   end
    #
    # Non-Watch Tasks must specify a PID file:
    #
    #   on.condition(:memory_usage) do |c|
    #     c.above = 100.megabytes
    #     c.pid_file = "/var/run/mongrel.3000.pid"
    #   end
    class DelayedJobExceededLimit < PollCondition
      attr_accessor :above, :pid_file

      def initialize
        super
        self.above = nil
        self.no_of_records = Delayed::Job.count
      end

      def pid
        self.pid_file ? File.read(self.pid_file).strip.to_i : self.watch.pid
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'pid_file' must be specified", self) if self.pid_file.nil? && self.watch.pid_file.nil?
        valid &= complain("Attribute 'above' must be specified", self) if self.above.nil?
        valid
      end

      def test
        self.info = []

        if self.no_of_records > self.above
          self.info = "delayed job exceeds limit #{self.above}"
          return true
        else
          return false
        end
      end
    end

  end
end