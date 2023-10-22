require 'rails_helper'

RSpec.describe Tag do
  describe 'build_tag_list' do
    it 'カンマで区切られた文字列を配列にして返す' do
      jointed_tag_names = 'foo,bar,baz'
      tag_list = described_class.build_tag_list(jointed_tag_names)
      expect(tag_list.count).to be 3
      tag_list.each do |tag_name|
        expect(tag_name).to match(/foo|bar|baz/)
      end
    end
  end
end
