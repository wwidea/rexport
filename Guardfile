guard :minitest, autorun: false do
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^lib/rexport/(.*)\.rb$})   { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/test_helper\.rb$})   { 'test' }
  watch(%r{^test/factories\.rb$})     { 'test' }
end
