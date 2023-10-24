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

    it 'カンマで区切られた文字列の先頭、末尾に空白がある場合削除する' do
      jointed_tag_names = ' foo,bar ,  baz'
      tag_list = described_class.build_tag_list(jointed_tag_names)
      expect(tag_list.count).to be 3
      tag_list.each do |tag_name|
        expect(tag_name.start_with?(' ')).to be_falsey
        expect(tag_name.end_with?(' ')).to be_falsey
      end
    end

    it 'カンマで区切られた文字列が重複していた場合1つにする' do
      jointed_tag_names = 'foo,foo,baz'
      tag_list = described_class.build_tag_list(jointed_tag_names)
      expect(tag_list.count).to be 2
      tag_list.each do |tag_name|
        expect(tag_name).to match(/foo|baz/)
      end
    end
  end
end
