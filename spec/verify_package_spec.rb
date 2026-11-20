require 'spec_helper'
require 'open3'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'

RSpec.describe 'built gem verification' do
  let(:root) { File.expand_path('..', __dir__) }
  let(:script) { File.join(root, 'script/verify_package.rb') }

  def verify(exclude: nil, filename: nil)
    Dir.mktmpdir('casteml-package-spec-') do |directory|
      archive = Dir.chdir(root) do
        spec = Gem::Specification.load('casteml.gemspec')
        spec.files -= [exclude] if exclude
        path = File.join(directory, filename || spec.file_name)
        Gem::Package.build(spec, false, false, path)
        path
      end
      Open3.capture3(RbConfig.ruby, script, archive, chdir: directory)
    end
  end

  it 'installs and runs the built gem outside the source tree' do
    stdout, stderr, status = verify
    expect(status.success?).to be(true), stdout + stderr
    expect(stdout).to include('installed casteml')
  end

  it 'rejects an archive named differently from its metadata' do
    _, stderr, status = verify(filename: 'renamed.gem')
    expect(status.success?).to be(false)
    expect(stderr).to include('Archive filename differs')
  end

  it 'rejects an archive without a runtime template' do
    _, stderr, status = verify(exclude: 'template/spots.tex.erb')
    expect(status.success?).to be(false)
    expect(stderr).to include('template/spots.tex.erb')
  end
end
