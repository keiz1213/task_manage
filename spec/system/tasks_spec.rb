require 'rails_helper'

RSpec.describe "Tasks" do
  describe 'タスクのCRUD' do
    let!(:task) { create(:task) }

    it 'タスクの作成' do
      visit root_path

      expect {
        click_link '新規タスク'
        fill_in 'Title', with: 'test-task'
        fill_in 'Description', with: 'test'
        choose 'mid'
        fill_in 'Deadline', with: Time.mktime(2100, 1, 2, 3, 4)
        click_button 'Create Task'

        expect(page).to have_content('タスク: test-taskを作成しました')
        expect(page).to have_content('tasks#index!')
        expect(page).to have_content('test-task')
        expect(page).to have_content('mid')
        expect(page).to have_content('ステータス: not_started')
        expect(page).to have_content("期限: 2100-01-02 03:04:00")
      }.to change(Task, :count).by(1)
    end

    it 'タスクの詳細' do
      visit root_path

      click_link task.title
      expect(page).to have_content(task.title)
      expect(page).to have_content(task.description)
      expect(page).to have_content(task.priority)
      expect(page).to have_content(task.deadline)
      expect(page).to have_content(task.state)
    end

    it 'タスクの更新' do
      visit root_path

      expect {
        click_link task.title
        click_link '編集'
        fill_in 'Title', with: 'foo'
        choose 'high'
        fill_in 'Deadline', with: Time.mktime(2200, 1, 2, 3, 4)
        click_button 'Update Task'
        expect(page).to have_content('foo')
        expect(page).to have_content('タスク: fooを更新しました')
        expect(page).to have_content('tasks#index!')
        expect(page).to have_content('foo')
        expect(page).to have_content('high')
        expect(page).to have_content('ステータス: not_started')
        expect(page).to have_content('期限: 2200-01-02 03:04:00')
      }.not_to change(Task, :count)
    end

    it 'タスクの削除' do
      visit root_path

      expect {
        click_link task.title
        accept_confirm do
          click_link '削除'
        end
        task.reload
      }.to change(Task, :count).by(-1)

      expect(page).to have_content("タスク: #{task.title}を削除しました")
      expect(page).to have_content('tasks#index!')
    end
  end
end
