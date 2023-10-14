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
      today_task_title = task.title
      yesterday_task_title = create(:task, :yesterday_task).title
      day_before_yesterday_task_title = create(:task, :day_before_yesterday_task).title
      visit root_path

      within(:test, 'task-list') do
        task_titles = all(:test, 'task-title')
        expect(task_titles.count).to be 3
        expect(task_titles[0].text).to eq today_task_title
        expect(task_titles[1].text).to eq yesterday_task_title
        expect(task_titles[2].text).to eq day_before_yesterday_task_title
      end
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
      due_tomorrow_task_title = create(:task, :due_tomorrow_task).title
      due_two_days_after_tomorrow_task_title = create(:task, :due_two_days_after_tomorrow_task).title
      due_day_after_tomorrow_task_title = create(:task, :due_day_after_tomorrow_task).title

      visit root_path
      click_link '締切が近い順'

      # 設定ファイル: spec/support/wait_for_css
      # 参考: https://qiita.com/johnslith/items/09bb0e5257e06a4bd948
      wait_for_css_appear('.card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 3
          expect(task_titles[0].text).to eq due_tomorrow_task_title
          expect(task_titles[1].text).to eq due_day_after_tomorrow_task_title
          expect(task_titles[2].text).to eq due_two_days_after_tomorrow_task_title
        end
      end
    end
  end

  describe '検索' do
    let!(:task1) { create(:task, title: 'りんご君', description: 'バナナ', deadline: Time.current.since(5.days))}
    let!(:task2) { create(:task, title: 'スイカ', description: '桃太郎', deadline: Time.current.since(3.days))}
    let!(:task3) { create(:task, title: 'メロン', description: '甘いいちご', deadline: Time.current.since(2.days))}
    let!(:task4) { create(:task, title: 'りんごちゃん', description: 'すっぱいいちご', deadline: Time.current.since(4.days))}
    let!(:task5) { create(:task, title: 'パイナップル', description: 'いちご', deadline: Time.current.since(1.day))}

    it 'タイトルからキーワード検索できる' do
      visit root_path
      fill_in 'キーワード', with: 'りんご'
      click_button '検索する'
      wait_for_css_appear('.card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 2
          expect(task_titles[0].text).to match /りんご/
          expect(task_titles[1].text).to match /りんご/
        end
      end
    end

    it '説明からキーワード検索できる' do
      visit root_path
      fill_in 'キーワード', with: '桃'
      click_button '検索する'
      wait_for_css_appear('.card') do
        task_titles = []
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 1
        end
        click_link task_titles[0].text
        expect(page).to have_content('桃太郎')
      end
    end

    it '検索結果を締切が近い順にソートできる' do
      visit root_path
      fill_in 'キーワード', with: 'いちご'
      click_button '検索する'
      click_link '締切が近い順'
      wait_for_css_appear('.card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 3
          expect(task_titles[0].text).to eq task5.title
          expect(task_titles[1].text).to eq task3.title
          expect(task_titles[2].text).to eq task4.title
        end
      end
    end
  end
end
