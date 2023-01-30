guard :shell do
  directories %w(lib test)

  # lib directory
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/lib/#{m[1]}_test.rb" }

  # test directories
  watch(%r{^test/.+_test\.rb$})

  # test_helper
  watch(%r{^test/test_helper\.rb$}) { 'test' }
end

class Guard::Shell
  def run_all
    run_test
  end

  def run_on_modifications(paths = [])
    tests = check_for_test_files(paths)
    run_test(tests) if tests&.any?
  end

  private

  def check_for_test_files(paths)
    paths.select do |path|
      File.exist?(path) ? path : puts("Test file not found - #{path}")
    end
  end

  def run_test(paths = [])
    puts("Running tests #{paths}") if paths&.any?
    system("bin/test #{paths.join(' ')}")
  end
end
