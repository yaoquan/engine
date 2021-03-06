require 'spec_helper'

describe Locomotive::Liquid::Filters::Resize do
  before :each do
    @site               = FactoryGirl.create(:site)
    @theme_asset        = FactoryGirl.create(:theme_asset, source: FixturedAsset.open('5k.png'), site: @site)
    @theme_asset_path   = "/sites/#{@theme_asset.site_id}/theme/images/5k.png"
    @asset              = FactoryGirl.create(:asset, source: FixturedAsset.open('5k.png'), site: @site)
    @asset_url          = @asset.source.url
    @asset_url_with_ts  = "#{@asset.source.url}?24e29997bcb00e97d8252cdd29d14e2d"
    @asset_path         = "/sites/#{@asset.site_id}/assets/#{@asset.id}/5k.png"
    @context            = Liquid::Context.new( { }, { 'asset_url' => @asset_url, 'asset_url_with_ts' => @asset_url_with_ts, 'theme_asset' => @theme_asset.to_liquid }, { site: @site })
  end

  describe '#resize' do
    context 'when an asset url string is given' do
      before :each do
        @template = Liquid::Template.parse('{{ asset_url | resize: "40x30" }}')
      end

      it 'returns the location of the resized image' do
        expect(@template.render(@context)).to match(/images\/dynamic\/.*\/5k.png/)
      end

      it 'uses the path in the public folder to generate a location' do
        expect(@template.render(@context)).to eq(Locomotive::Dragonfly.resize_url(@asset_path, '40x30'))
      end

      it 'accepts strings with leading and trailing empty characters' do
        @context['asset_url'] = "  \t #{@context['asset_url']}   \n\n  "
        expect(@template.render(@context)).to eq(Locomotive::Dragonfly.resize_url(@asset_path, '40x30'))
      end

    end

    context 'when an asset url with a timestamp is given' do

      subject { Liquid::Template.parse('{{ asset_url_with_ts | resize: "40x30" }}').render(@context) }

      it 'returns the location of the resized image' do
        expect(subject).to match(/images\/dynamic\/.*\/5k.png/)
      end

    end

    context 'when a theme asset is given' do
      before :each do
        @template = Liquid::Template.parse("{{ theme_asset | resize: '300x400' }}")
      end

      it 'returns the location of the resized image' do
        expect(@template.render(@context)).to match(/images\/dynamic\/.*\/5k.png/)
      end

      it 'uses the path of the theme asset to generate a location' do
        expect(@template.render(@context)).to eq(Locomotive::Dragonfly.resize_url(@theme_asset_path, '300x400'))
      end
    end

    context 'when no resize string is given' do

      before :each do
        @template = Liquid::Template.parse('{{ asset | resize: }}')
      end

      it 'returns a liquid error' do
        expect(@template.render(@context)).to include 'Liquid error: wrong number of arguments'
      end

    end

  end
end
