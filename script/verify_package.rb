# Run after bundle install: bundle exec ruby script/verify_package.rb [path.gem]
require 'bundler/setup'
require 'open3'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'

abort 'Expected at most one gem archive path' if ARGV.length > 1
root = File.expand_path('..', __dir__)
expected = Dir.chdir(root) { Gem::Specification.load('casteml.gemspec') }
archive = File.expand_path(ARGV.first || File.join(root, 'pkg', expected.file_name))
package = Gem::Package.new(archive)
package.verify
spec = package.spec
abort 'Unexpected gem name or version' unless spec.full_name == expected.full_name
abort 'Archive filename differs from gemspec' unless File.basename(archive) == spec.file_name
abort 'Unexpected executable list' unless spec.executables == ['casteml']

missing = expected.files - package.contents
extra = package.contents - expected.files
abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?
abort "Unexpected packaged files: #{extra.join(', ')}" unless extra.empty?

dependency_paths = (Gem.path + Gem.loaded_specs.values.map(&:base_dir)).uniq
Dir.mktmpdir('casteml-package-') do |directory|
  gem_home = File.join(directory, 'gems')
  environment = {
    'HOME' => directory,
    'GEM_HOME' => gem_home,
    'GEM_PATH' => ([gem_home] + dependency_paths).join(File::PATH_SEPARATOR),
    'PATH' => [RbConfig::CONFIG.fetch('bindir'), ENV.fetch('PATH')].join(File::PATH_SEPARATOR),
    'OROCHI_PWD' => nil,
    'RUBYLIB' => nil,
    'RUBYOPT' => nil
  }
  File.write(File.join(directory, '.orochirc'), "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
  run = lambda do |*args|
    stdout, stderr, status = Open3.capture3(environment, RbConfig.ruby, *args, chdir: directory)
    abort "Command failed (#{status.exitstatus}): #{args.inspect}\n#{stdout}\n#{stderr}" unless status.success?
    stdout
  end

  # Bundler's Git dependencies are invisible to RubyGems outside Bundler.
  client = Gem.loaded_specs.fetch('medusa_rest_client')
  unless File.file?(client.spec_file)
    client_archive = File.join(directory, client.file_name)
    Dir.chdir(client.full_gem_path) do
      Gem::Package.build(client.dup, false, false, client_archive)
    end
  end

  Bundler.with_unbundled_env do
    [client_archive, archive].compact.each do |gemfile|
      run.call('-S', 'gem', 'install', '--local', '--no-document', '--ignore-dependencies', gemfile)
    end
    executable = File.join(gem_home, 'bin', 'casteml')
    abort 'Missing installed executable: casteml' unless File.file?(executable)
    command = [executable, "_#{spec.version}_"]
    help = run.call(*command, '--help')
    abort "Unexpected help from casteml:\n#{help}" unless help.include?('Usage:') && help.include?('--version')

    %w[convert download join plot split spots upload].each do |subcommand|
      help = run.call(*command, subcommand, '--help')
      abort "Unexpected help from casteml #{subcommand}:\n#{help}" unless help.include?("casteml #{subcommand}") && help.include?('--help')
    end

    File.write(File.join(directory, 'sample.pml'),
               '<acquisition><session>package-check</session></acquisition>')
    csv = run.call(*command, 'convert', '-f', 'csv', 'sample.pml')
    abort "Unexpected CSV from installed casteml:\n#{csv}" unless csv.lines.any? { |line| line.include?('package-check') }

    version = run.call(*command, '--version')
    abort "Unexpected CLI version: #{version}" unless version.lines.first&.strip == "version: #{spec.version}"

    run.call('-e', <<~'CHECK', spec.version.to_s, gem_home, client_archive ? client.version.to_s : '')
      version, gem_home, client_version = ARGV
      gem 'casteml', "= #{version}"
      require 'casteml'
      require 'medusa_rest_client'
      installed = Gem.loaded_specs.fetch('casteml')
      abort 'casteml loaded from outside the temporary installation' unless File.realpath(installed.base_dir) == File.realpath(gem_home)
      abort 'Installed casteml version differs' unless Casteml::VERSION == version
      unless client_version.empty?
        client = Gem.loaded_specs.fetch('medusa_rest_client')
        abort 'Git-sourced dependency was not loaded from the temporary installation' unless
          File.realpath(client.base_dir) == File.realpath(gem_home) && client.version.to_s == client_version
      end
    CHECK
  end
end
puts "PASS #{spec.full_name}: archive, installed casteml help and PML-to-CSV conversion (Ruby #{RUBY_VERSION})"
