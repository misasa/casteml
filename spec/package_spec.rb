require 'spec_helper'

RSpec.describe 'casteml gem package' do
  let(:root) { File.expand_path('..', __dir__) }
  let(:specification) { Dir.chdir(root) { Gem::Specification.load('casteml.gemspec') } }

  it 'declares the license granted by LICENSE.txt' do
    expect(specification.licenses).to eq(['GPL-3.0-or-later'])
  end

  it 'requires Ruby 2.6.0 or later' do
    expect(specification.required_ruby_version).to eq(Gem::Requirement.new('>= 2.6.0'))
  end

  it 'installs the casteml executable' do
    expect(specification.executables).to eq(['casteml'])
  end

  it 'packages the runtime code, data, templates, README and license' do
    expected = Dir.chdir(root) { Dir['lib/**/*.rb'] } + %w[
      LICENSE.txt
      README.md
      bin/casteml
      config/alchemist/abundance.yml
      remote_dump/MedusaRestClient/MeasurementCategory.marshal
      remote_dump/MedusaRestClient/MeasurementItem.marshal
      remote_dump/MedusaRestClient/Unit.marshal
      template/plot/default.R.erb
      template/plot/lead.R.erb
      template/plot/oxygen.R.erb
      template/plot/trace.R.erb
      template/spots.tex.erb
    ]
    expect(specification.files).to match_array(expected)
  end
end
