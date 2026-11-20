require 'spec_helper'
require 'digest'
require 'fileutils'
require 'open3'
require 'rbconfig'
require 'tmpdir'

RSpec.describe 'public release download' do
  around do |example|
    Dir.mktmpdir("casteml-spec-") do |directory|
      @work_dir = directory
      example.run
    end
  end

  let(:script) { File.expand_path('../script/download_release.sh', __dir__) }
  let(:filename) { 'casteml-1.1.3.gem' }

  before do
    @fake_bin = File.join(@work_dir, 'tools')
    @output = File.join(@work_dir, 'downloads')
    FileUtils.mkdir_p([@fake_bin, @output])
    File.binwrite(File.join(@work_dir, filename), 'verified gem bytes')
    @digest = Digest::SHA256.hexdigest('verified gem bytes')
    File.write(File.join(@work_dir, "#{filename}.sha256"), "#{@digest}  #{filename}\n")
    # Only the network is stubbed. Hashing and filesystem operations are real.
    File.write(File.join(@fake_bin, 'curl'), <<~'SH')
      #!/bin/bash
      set -eu
      output=
      for argument; do
        case "$argument" in
          *Authorization*|*api.github.com*) exit 91 ;;
        esac
      done
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --output) output=$2; shift 2 ;;
          https://*) url=$1; shift ;;
          *) shift ;;
        esac
      done
      [ "${FAIL_CURL:-0}" = 0 ] || exit 22
      case "$url" in
        https://github.com/misasa/casteml/releases/latest)
          printf '%s' "${LATEST_URL:-https://github.com/misasa/casteml/releases/tag/v1.1.3}" ;;
        https://github.com/misasa/casteml/releases/download/v1.1.3/*)
          cp "$FIXTURE_DIR/${url##*/}" "$output" ;;
        *) exit 92 ;;
      esac
    SH
    FileUtils.chmod(0755, Dir[File.join(@fake_bin, '*')])
  end

  def download(*arguments, env: {})
    Open3.capture3({
      'PATH' => "#{@fake_bin}:#{ENV.fetch('PATH')}",
      'FIXTURE_DIR' => @work_dir
    }.merge(env), '/bin/bash', script, '--output-dir', @output, *arguments)
  end

  it 'downloads the latest stable gem and checksum without authentication' do
    _, stderr, status = download
    expect(status.success?).to be(true), stderr
    expect(File.binread(File.join(@output, filename))).to eq('verified gem bytes')
    expect(File.read(File.join(@output, "#{filename}.sha256"))).to include(@digest)
  end

  %w[1.1.3 v1.1.3].each do |version|
    it "accepts explicit version #{version}" do
      _, stderr, status = download('--version', version)
      expect(status.success?).to be(true), stderr
    end
  end

  it 'rejects corrupt downloads before saving them' do
    File.write(File.join(@work_dir, filename), 'corrupt')
    _, stderr, status = download
    expect(status.success?).to be(false)
    expect(stderr).to match(/SHA-256/i)
    expect(Dir.children(@output)).to be_empty
  end

  it 'rejects a checksum manifest naming another file' do
    File.write(File.join(@work_dir, "#{filename}.sha256"), "#{@digest}  other.gem\n")
    _, _, status = download
    expect(status.success?).to be(false)
    expect(Dir.children(@output)).to be_empty
  end

  it 'preserves existing files, including symlinks' do
    File.symlink(File.join(@work_dir, filename), File.join(@output, filename))
    _, stderr, status = download
    expect(status.success?).to be(false)
    expect(stderr).to match(/exists/)
    expect(File.symlink?(File.join(@output, filename))).to be(true)
    expect(File.read(File.join(@work_dir, filename))).to eq('verified gem bytes')
  end

  it 'reports a missing public release or network failure clearly' do
    _, stderr, status = download(env: {'FAIL_CURL' => '1'})
    expect(status.success?).to be(false)
    expect(stderr).to match(/public.*Release/i)
    expect(Dir.children(@output)).to be_empty
  end

  it 'rejects an unexpected latest redirect' do
    _, _, status = download(env: {'LATEST_URL' => 'https://github.com/misasa/casteml/releases'})
    expect(status.success?).to be(false)
  end

  it 'rejects invalid or incomplete arguments' do
    [%w[--version ../oops], %w[--version 1.1.3.rc1], %w[--version v],
     %w[--version], %w[--output-dir], %w[--unknown]].each do |args|
      _, _, status = download(*args)
      expect(status.success?).to be(false), args.inspect
    end
  end
end
