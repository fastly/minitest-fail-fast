require "minitest"

module Minitest
  def self.plugin_fail_fast_options opts, _options
    opts.on "-f", "--fail-fast", "Halt running the test suite when a test fails" do
      FailFastReporter.fail_fast!
    end
    opts.on "-F", "--show-failures", "Display failure output when it occurs" do
      FailFastReporter.show_failures!
    end
  end

  def self.plugin_fail_fast_init options
    io = options.fetch(:io, $stdout)
    self.reporter.reporters << FailFastReporter.new(io, options)
  end

  class FailFastReporter < Reporter
    def self.show_failures!
      @show_failures = true
    end

    def self.show_failures?
      @show_failures ||= false
    end

    def self.fail_fast!
      @fail_fast = true
    end

    def self.fail_fast?
      @fail_fast ||= false
    end

    def record result
      failures = result.failures.reject { |failure| failure.kind_of?(Minitest::Skip)}
      if failures.any?
        if self.class.show_failures?
          io.puts
          failures.each do |failure|
            io.puts "#{failure.result_label}:\n#{failure.location}:\n#{failure.message}\n"
          end
        end
        if self.class.fail_fast?
          io.puts
          raise Interrupt
        end
      else
        super
      end
    end
  end
end
