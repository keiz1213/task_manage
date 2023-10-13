require 'rails_helper'

RSpec.describe "Tasks" do
  describe 'タスクのCRUD' do
    let!(:task) { create(:task) }

    it 'タスクの作成' do
      visit root_path

      expect {
        click_link '新規タスク'
        fill_in 'タイトル', with: 'test-task'
        fill_in '説明', with: 'test'
        choose '中'
        fill_in '締め切り', with: Time.mktime(2100, 1, 2, 3, 4)
        click_button '登録'
        expect(page).to have_content('タスク: test-taskを作成しました')
        expect(page).to have_content('tasks#index!')
        expect(page).to have_content('test-task')
        expect(page).to have_content('重要度: 中')
        expect(page).to have_content('ステータス: 未着手')
        expect(page).to have_content("締め切り: 2100/01/02 03:04")
      }.to change(Task, :count).by(1)
    end

    it 'タスクの一覧が作成日の降順で表示される' do
      yesterday_task = create(:task, :yesterday_task)
      day_before_yesterday_task = create(:task, :day_before_yesterday_task)
      visit root_path

      titles = page.text.scan(/(#{task.title}|#{yesterday_task.title}|#{day_before_yesterday_task.title})/)
      expect(titles[0][0]).to eq task.title
      expect(titles[1][0]).to eq yesterday_task.title
      expect(titles[2][0]).to eq day_before_yesterday_task.title
    end

    it 'タスクの詳細' do
      visit root_path

      click_link task.title
      expect(page).to have_content(task.title)
      expect(page).to have_content(task.description)
      expect(page).to have_content('低')
      expect(page).to have_content('2100/01/02 03:04')
      expect(page).to have_content('未着手')
    end

    it 'タスクの更新' do
      visit root_path

      expect {
        click_link task.title
        click_link '編集'
        fill_in 'タイトル', with: 'foo'
        choose '高'
        fill_in '締め切り', with: Time.mktime(2200, 1, 2, 3, 4)
        click_button '更新する'
        expect(page).to have_content('foo')
        expect(page).to have_content('タスク: fooを更新しました')
        expect(page).to have_content('tasks#index!')
        expect(page).to have_content('foo')
        expect(page).to have_content('重要度: 高')
        expect(page).to have_content('ステータス: 未着手')
        expect(page).to have_content('締め切り: 2200/01/02 03:04')
      }.not_to change(Task, :count)
    end

    it 'タスクの削除' do
      visit root_path

      expect {
        click_link task.title
        accept_confirm do
          click_link '削除'
        end
        expect(page).to have_content("タスク: #{task.title}を削除しました")
        expect(page).to have_content('tasks#index!')
      }.to change(Task, :count).by(-1)
    end
  end

  describe 'ソート' do
    it '締切に近い順に並び替える' do
      due_tomorrow_task = create(:task, :due_tomorrow_task)
      due_two_days_after_tomorrow_task = create(:task, :due_two_days_after_tomorrow_task)
      due_day_after_tomorrow_task = create(:task, :due_day_after_tomorrow_task)

      visit root_path
      click_link '締切が近い順'
      titles = page.text.scan(/(#{due_tomorrow_task.title}|#{due_day_after_tomorrow_task.title}|#{due_two_days_after_tomorrow_task.title})/)
      expect(titles[0][0]).to eq due_tomorrow_task.title
      expect(titles[1][0]).to eq due_day_after_tomorrow_task.title
      expect(titles[2][0]).to eq due_two_days_after_tomorrow_task.title
    end
  end
end
