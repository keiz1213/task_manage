require 'rails_helper'

RSpec.describe "Tasks" do
  describe 'CRUD' do
    it 'タスクの作成' do
      user = create(:user)
      login_as(user)

      expect {
        click_link '新規タスク'
        fill_in 'タイトル', with: 'test-task'
        fill_in '説明', with: 'test'
        choose '中'
        fill_in '締め切り', with: Time.mktime(2100, 1, 2, 3, 4)
        fill_in 'Tag name', with: 'foo,bar'
        click_button '登録'
        expect(page).to have_content('タスク: test-taskを作成しました')
        expect(page).to have_content('test-task')
        expect(page).to have_content('重要度: 中')
        expect(page.find(:test, 'update-state').value).to eq '未着手'
        expect(page).to have_content('締め切り: 2100/01/02 03:04')
        expect(page).to have_content('foo')
        expect(page).to have_content('bar')
      }.to change(Task, :count).by(1)
    end

    it 'タスクの一覧が作成日が新しい順で表示される' do
      user = create(:user, :with_tasks_for_3_days)
      login_as(user)
      user_tasks = user.tasks.recent
      today_task = user_tasks.first
      yesterday_task = user_tasks.second
      day_before_yesterday_task = user_tasks.last

      within(:test, 'task-list') do
        task_titles = all(:test, 'task-title')
        expect(task_titles.count).to be 3
        expect(task_titles[0].text).to eq today_task.title
        expect(task_titles[1].text).to eq yesterday_task.title
        expect(task_titles[2].text).to eq day_before_yesterday_task.title
      end
    end

    it 'タスクの詳細' do
      user = create(:user)
      task = create(:task, user: user)
      login_as(user)

      click_link task.title
      expect(page).to have_content(task.title)
      expect(page).to have_content(task.description)
      expect(page).to have_content(I18n.t("activerecord.attributes.task.priorities.#{task.priority}"))
      expect(page).to have_content(I18n.l(task.deadline, format: :long))
      expect(page).to have_content(I18n.t("activerecord.attributes.task.states.#{task.state}"))
    end

    it 'タスクの更新' do
      user = create(:user)
      task = create(:task, user: user)
      login_as(user)

      expect {
        click_link task.title
        click_link '編集'
        fill_in 'タイトル', with: 'test'
        choose '高'
        fill_in '締め切り', with: Time.mktime(2200, 1, 2, 3, 4)
        fill_in 'Tag name', with: 'hoge,piyo'
        click_button '更新する'

        expect(page).to have_content('タスク: testを更新しました')
        expect(page).to have_content('test')
        expect(page).to have_content('重要度: 高')
        expect(page.find(:test, 'update-state').value).to eq '未着手'
        expect(page).to have_content('締め切り: 2200/01/02 03:04')
        expect(page).to have_content('hoge')
        expect(page).to have_content('piyo')
      }.not_to change(Task, :count)
    end

    it 'タスクの削除' do
      user = create(:user, :with_tagged_tasks)
      login_as(user)
      task_title = user.tasks[0].title
      click_link task_title

      expect {
        accept_confirm do
          click_link '削除'
        end
        expect(page).to have_content("タスク: #{task_title}を削除しました")
      }.to change(Task, :count).by(-1)
    end

    it 'タスクが削除されるとそのタスクとタグのリレーションも削除されること' do
      user = create(:user, :with_tagged_tasks)
      task = user.tasks[0]
      task_tag_names = task.tags.map(&:name)
      tag_count = task_tag_names.size
      login_as(user)
      click_link task.title

      expect {
        accept_confirm do
          click_link '削除'
        end
        expect(page).to have_content("タスク: #{task.title}を削除しました")
        task_tag_names.each do |tag_name|
          expect(page).not_to have_content(tag_name)
        end
      }.to change(Tagging, :count).by(-tag_count)
    end
  end

  describe 'ソート' do
    it '締切に近い順に並び替えできる' do
      user = create(:user, :with_tasks_separate_due_dates)
      user_tasks = user.tasks.deadline
      due_tomorrow_task = user_tasks.first
      due_day_after_tomorrow_task = user_tasks.second
      due_two_days_after_tomorrow_task = user_tasks.last
      login_as(user)
      click_link '締切が近い順'
      # TODO
      sleep(1)
      # 定義: spec/support/system_helpers
      # 参考: https://qiita.com/johnslith/items/09bb0e5257e06a4bd948
      wait_for_css_appear('.task-card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 3
          expect(task_titles[0].text).to eq due_tomorrow_task.title
          expect(task_titles[1].text).to eq due_day_after_tomorrow_task.title
          expect(task_titles[2].text).to eq due_two_days_after_tomorrow_task.title
        end
      end
    end

    it '重要度の高い順に並び替えできる' do
      user = create(:user, :with_tasks_separate_priority)
      user_tasks = user.tasks.high_priority_first
      high_priority_task = user_tasks.first
      mid_priority_task = user_tasks.second
      low_priority_task = user_tasks.last
      login_as(user)
      click_link '重要度の高い順'
      # TODO
      sleep(1)
      wait_for_css_appear('.task-card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 3
          expect(task_titles[0].text).to eq high_priority_task.title
          expect(task_titles[1].text).to eq mid_priority_task.title
          expect(task_titles[2].text).to eq low_priority_task.title
        end
      end
    end

    it '重要度の低い順に並び替えできる' do
      user = create(:user, :with_tasks_separate_priority)
      user_tasks = user.tasks.low_priority_first
      low_priority_task = user_tasks.first
      mid_priority_task = user_tasks.second
      high_priority_task = user_tasks.last
      login_as(user)
      click_link '重要度の低い順'
      # TODO
      sleep(1)
      wait_for_css_appear('.task-card') do
        within(:test, 'task-list') do
          task_titles = all(:test, 'task-title')
          expect(task_titles.count).to be 3
          expect(task_titles[0].text).to eq low_priority_task.title
          expect(task_titles[1].text).to eq mid_priority_task.title
          expect(task_titles[2].text).to eq high_priority_task.title
        end
      end
    end
  end

  describe '検索' do
    describe 'キーワード検索' do
      it 'タイトルからキーワード検索できる' do
        user = create(:user, :with_tasks_separate_title)
        login_as(user)

        fill_in 'キーワード', with: 'りんご'
        click_button '検索'
        # TODO
        sleep(1)
        wait_for_css_appear('.task-card') do
          within(:test, 'task-list') do
            task_titles = all(:test, 'task-title')
            expect(task_titles.count).to be 2
            task_titles.each do |el|
              expect(el.text).to match(/青りんご|りんごちゃん/)
            end
          end
        end
      end

      it '説明からキーワード検索できる' do
        user = create(:user, :with_tasks_separate_title)
        login_as(user)

        fill_in 'キーワード', with: '桃'
        click_button '検索'
        # TODO
        sleep(1)
        wait_for_css_appear('.task-card') do
          task_titles = []
          within(:test, 'task-list') do
            task_titles = all(:test, 'task-title')
            expect(task_titles.count).to be 1
          end
          click_link task_titles[0].text
          expect(page).to have_content('桃太郎')
        end
      end
    end

    describe 'ステータス検索' do
      let(:user) { create(:user) }

      it '未着手のタスクを検索できる' do
        create(:task, title: '青りんご', state: 'done', user: user)
        create(:task, title: 'スイカ', state: 'not_started', user: user)
        create(:task, title: 'メロン', state: 'not_started', user: user)
        create(:task, title: 'みかん', state: 'in_progress', user: user)
        create(:task, title: 'パイナップル', state: 'in_progress', user: user)
        create(:task, title: 'ぶどう', state: 'in_progress', user: user)

        login_as(user)
        click_link '未着手のタスク'
        # TODO
        sleep(1)
        wait_for_css_appear('.task-card') do
          within(:test, 'task-list') do
            task_titles = all(:test, 'task-title')
            expect(task_titles.count).to be 2
            task_titles.each do |el|
              expect(el.text).to match(/スイカ|メロン/)
            end
          end
        end
      end

      it '着手中のタスクを検索できる' do
        create(:task, title: '青りんご', state: 'done', user: user)
        create(:task, title: 'スイカ', state: 'not_started', user: user)
        create(:task, title: 'メロン', state: 'not_started', user: user)
        create(:task, title: 'みかん', state: 'in_progress', user: user)
        create(:task, title: 'パイナップル', state: 'in_progress', user: user)
        create(:task, title: 'ぶどう', state: 'in_progress', user: user)

        login_as(user)
        click_link '着手しているタスク'
        # TODO
        sleep(1)
        wait_for_css_appear('.task-card') do
          within(:test, 'task-list') do
            task_titles = all(:test, 'task-title')
            expect(task_titles.count).to be 3
            task_titles.each do |el|
              expect(el.text).to match(/みかん|パイナップル|ぶどう/)
            end
          end
        end
      end

      it '完了したタスクを検索できる' do
        create(:task, title: '青りんご', state: 'done', user: user)
        create(:task, title: 'スイカ', state: 'not_started', user: user)
        create(:task, title: 'メロン', state: 'not_started', user: user)
        create(:task, title: 'みかん', state: 'in_progress', user: user)
        create(:task, title: 'パイナップル', state: 'in_progress', user: user)
        create(:task, title: 'ぶどう', state: 'in_progress', user: user)

        login_as(user)
        click_link '完了したタスク'
        # TODO
        sleep(1)
        wait_for_css_appear('.task-card') do
          within(:test, 'task-list') do
            task_titles = all(:test, 'task-title')
            expect(task_titles.count).to be 1
            task_titles.each do |el|
              expect(el.text).to match(/青りんご/)
            end
          end
        end
      end
    end

    describe 'タグ検索' do
      it 'タグでタスクを検索できる' do
        user = create(:user)
        create_list(:task, 3, user: user)
        create(:tagging, task: user.tasks[0], tag: create(:tag, name: 'foo'))
        create(:tagging, task: user.tasks[1], tag: create(:tag, name: 'bar'))
        create(:tagging, task: user.tasks[2], tag: create(:tag, name: 'baz'))
        login_as(user)

        expect(all(:test, 'task-title').count).to be 3

        click_link 'foo'
        # TODO
        sleep(1)
        expect(all(:test, 'task-title').count).to be 1
      end
    end

    describe 'キーワード検索の結果に対する操作' do
      let(:user) { create(:user) }

      describe 'ソート' do
        it '検索結果を締切が近い順に並び替えできる' do
          task1 = create(:task, :due_tomorrow_task, title: '青りんご', user: user)
          task2 = create(:task, :due_two_days_after_tomorrow_task, title: '毒りんご', user: user)
          task3 = create(:task, :due_day_after_tomorrow_task, title: 'りんごちゃん', user: user)
          create(:task, title: 'バナナ', user: user)
          login_as(user)
          fill_in 'キーワード', with: 'りんご'
          click_button '検索'
          # TODO
          sleep(1)
          click_link '締切が近い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/青りんご|毒りんご|りんごちゃん/)
              end
              expect(task_titles[0].text).to eq task1.title
              expect(task_titles[1].text).to eq task3.title
              expect(task_titles[2].text).to eq task2.title
            end
          end
        end

        it '検索結果を重要度の高い順に並び替えできる' do
          task1 = create(:task, title: '青りんご', user: user, priority: 'mid')
          task2 = create(:task, title: '毒りんご', user: user, priority: 'high')
          task3 = create(:task, title: 'りんごちゃん', user: user, priority: 'low')
          create(:task, title: 'バナナ', user: user)
          login_as(user)
          fill_in 'キーワード', with: 'りんご'
          click_button '検索'
          # TODO
          sleep(1)
          click_link '重要度の高い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/青りんご|毒りんご|りんごちゃん/)
              end
              expect(task_titles[0].text).to eq task2.title
              expect(task_titles[1].text).to eq task1.title
              expect(task_titles[2].text).to eq task3.title
            end
          end
        end

        it '検索結果を重要度の低い順に並び替えできる' do
          task1 = create(:task, title: '青りんご', user: user, priority: 'mid')
          task2 = create(:task, title: '毒りんご', user: user, priority: 'high')
          task3 = create(:task, title: 'りんごちゃん', user: user, priority: 'low')
          create(:task, title: 'バナナ', user: user)
          login_as(user)
          fill_in 'キーワード', with: 'りんご'
          click_button '検索'
          # TODO
          sleep(1)
          click_link '重要度の低い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/青りんご|毒りんご|りんごちゃん/)
              end
              expect(task_titles[0].text).to eq task3.title
              expect(task_titles[1].text).to eq task1.title
              expect(task_titles[2].text).to eq task2.title
            end
          end
        end
      end

      describe '絞り込み' do
        describe '検索結果の絞り込み' do
          it '検索結果をステータスで絞り込める' do
            create(:task, title: '青りんご', state: 'done', user: user)
            create(:task, title: '毒りんご', state: 'not_started', user: user)
            create(:task, title: 'りんごの木', state: 'not_started', user: user)
            create(:task, title: '私はりんごが好きです', state: 'in_progress', user: user)
            create(:task, title: 'パイナップル', state: 'in_progress', user: user)
            create(:task, title: 'ぶどう', state: 'in_progress', user: user)
            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link '未着手のタスク'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 2
                task_titles.each do |el|
                  expect(el.text).to match(/毒りんご|りんごの木/)
                end
              end
            end
          end

          it '検索結果をタグで絞り込める' do
            task1 = create(:task, title: '毒りんご', user: user)
            task2 = create(:task, title: 'りんごの木', user: user)
            create(:task, title: '私はりんごが好きです', user: user)
            create(:task, title: '青りんご', user: user)
            create(:task, title: 'パイナップル', user: user)
            create(:task, title: 'ぶどう', user: user)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task2)

            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link 'foo'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 2
                task_titles.each do |el|
                  expect(el.text).to match(/毒りんご|りんごの木/)
                end
              end
            end
          end
        end

        describe 'キーワード検索結果を絞り込み、それをソートする' do
          it 'ステータスで絞り込んで締め切りに近い順に並び替えできる' do
            task1 = create(:task, title: '青りんご', state: 'not_started', deadline: 2.days.from_now, user: user)
            task2 = create(:task, title: '毒りんご', state: 'not_started', deadline: 1.day.from_now, user: user)
            task3 = create(:task, title: 'りんごの木', state: 'not_started', deadline: 3.days.from_now, user: user)
            create(:task, title: '私はりんごが好きです', state: 'in_progress', user: user)
            create(:task, title: 'りんごちゃん', state: 'in_progress', user: user)
            create(:task, title: 'ぶどう', state: 'done', user: user)
            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link '未着手のタスク'
            # TODO
            sleep(1)
            click_link '締切が近い順'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 3
                task_titles.each do |el|
                  expect(el.text).to match(/青りんご|毒りんご|りんごの木/)
                end
                expect(task_titles[0].text).to eq task2.title
                expect(task_titles[1].text).to eq task1.title
                expect(task_titles[2].text).to eq task3.title
              end
            end
          end

          it 'ステータスで絞り込んで重要度で並び替えできる' do
            task1 = create(:task, title: '毒りんご', state: 'not_started', priority: 'low', user: user)
            task2 = create(:task, title: 'りんごの木', state: 'not_started', priority: 'high', user: user)
            task3 = create(:task, title: '私はりんごが好きです', state: 'not_started', priority: 'mid', user: user)
            create(:task, title: '青りんご', state: 'done', priority: 'mid', user: user)
            create(:task, title: 'パイナップル', state: 'in_progress', priority: 'low', user: user)
            create(:task, title: 'ぶどう', state: 'in_progress', priority: 'low', user: user)

            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link '未着手のタスク'
            # TODO
            sleep(1)
            click_link '重要度の高い順'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 3
                task_titles.each do |el|
                  expect(el.text).to match(/毒りんご|りんごの木|私はりんごが好きです/)
                end
                expect(task_titles[0].text).to eq task2.title
                expect(task_titles[1].text).to eq task3.title
                expect(task_titles[2].text).to eq task1.title
              end
            end
          end

          it 'タグで絞り込んで締め切りに近い順に並び替えできる' do
            task1 = create(:task, title: '毒りんご', deadline: 2.days.from_now, user: user)
            task2 = create(:task, title: 'りんごの木', deadline: 1.day.from_now, user: user)
            task3 = create(:task, title: '私はりんごが好きです', deadline: 3.days.from_now, user: user)
            create(:task, title: '青りんご', user: user)
            create(:task, title: 'パイナップル', user: user)
            create(:task, title: 'ぶどう', user: user)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task3)

            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link 'foo'
            # TODO
            sleep(1)
            click_link '締切が近い順'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 3
                task_titles.each do |el|
                  expect(el.text).to match(/毒りんご|りんごの木|私はりんごが好きです/)
                end
                expect(task_titles[0].text).to eq task2.title
                expect(task_titles[1].text).to eq task1.title
                expect(task_titles[2].text).to eq task3.title
              end
            end
          end

          it 'タグで絞り込んで重要度で並び替えできる' do
            task1 = create(:task, title: '毒りんご', priority: 'mid', user: user)
            task2 = create(:task, title: 'りんごの木', priority: 'low', user: user)
            task3 = create(:task, title: '私はりんごが好きです', priority: 'high', user: user)
            create(:task, title: '青りんご', user: user)
            create(:task, title: 'パイナップル', user: user)
            create(:task, title: 'ぶどう', user: user)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
            create(:tagging, tag: create(:tag, name: 'foo'), task: task3)

            login_as(user)
            fill_in 'キーワード', with: 'りんご'
            click_button '検索'
            # TODO
            sleep(1)
            click_link 'foo'
            # TODO
            sleep(1)
            click_link '重要度の高い順'
            # TODO
            sleep(1)
            wait_for_css_appear('.task-card') do
              within(:test, 'task-list') do
                task_titles = all(:test, 'task-title')
                expect(task_titles.count).to be 3
                task_titles.each do |el|
                  expect(el.text).to match(/毒りんご|りんごの木|私はりんごが好きです/)
                end
                expect(task_titles[0].text).to eq task3.title
                expect(task_titles[1].text).to eq task1.title
                expect(task_titles[2].text).to eq task2.title
              end
            end
          end
        end
      end
    end

    describe 'ステータス検索の結果に対する操作' do
      let(:user) { create(:user) }

      describe 'ソート' do
        it '検索結果を締め切りが近い順に並び替えできる' do
          create(:task, title: '青りんご', state: 'done', deadline: 6.days.from_now, user: user)
          create(:task, title: 'スイカ', state: 'not_started', deadline: 4.days.from_now, user: user)
          create(:task, title: 'メロン', state: 'not_started', deadline: 1.day.from_now, user: user)
          create(:task, title: 'みかん', state: 'in_progress', deadline: 5.days.from_now, user: user)
          create(:task, title: 'パイナップル', state: 'in_progress', deadline: 2.days.from_now, user: user)
          create(:task, title: 'ぶどう', state: 'in_progress', deadline: 3.days.from_now, user: user)
          login_as(user)
          click_link '着手しているタスク'
          # TODO
          sleep(1)
          click_link '締切が近い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/パイナップル|ぶどう|みかん/)
              end
              expect(task_titles[0].text).to eq 'パイナップル'
              expect(task_titles[1].text).to eq 'ぶどう'
              expect(task_titles[2].text).to eq 'みかん'
            end
          end
        end

        it '検索結果を重要度で並び替えできる' do
          create(:task, title: '青りんご', state: 'done', priority: 'low', user: user)
          create(:task, title: 'スイカ', state: 'not_started', priority: 'low', user: user)
          create(:task, title: 'メロン', state: 'not_started', priority: 'low', user: user)
          create(:task, title: 'みかん', state: 'in_progress', priority: 'mid', user: user)
          create(:task, title: 'パイナップル', state: 'in_progress', priority: 'high', user: user)
          create(:task, title: 'ぶどう', state: 'in_progress', priority: 'low', user: user)
          login_as(user)
          click_link '着手しているタスク'
          # TODO
          sleep(1)
          click_link '重要度の高い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/パイナップル|ぶどう|みかん/)
              end
              expect(task_titles[0].text).to eq 'パイナップル'
              expect(task_titles[1].text).to eq 'みかん'
              expect(task_titles[2].text).to eq 'ぶどう'
            end
          end
        end
      end

      describe '絞り込み' do
        it '検索結果をタグで絞り込める' do
          task1 = create(:task, state: 'in_progress', user: user)
          task2 = create(:task, state: 'in_progress', user: user)
          create(:task, state: 'in_progress', user: user)
          create(:task, state: 'done', user: user)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
          login_as(user)
          click_link '着手しているタスク'
          # TODO
          sleep(1)
          click_link 'foo'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 2
            end
          end
        end
      end
    end

    describe 'タグ検索の結果に対する操作' do
      let(:user) { create(:user) }

      describe 'ソート' do
        it '検索結果を締め切りが近い順に並び替えできる' do
          task1 = create(:task, title: 'りんご', deadline: 3.days.from_now, user: user)
          task2 = create(:task, title: 'バナナ', deadline: 1.day.from_now, user: user)
          task3 = create(:task, title: 'みかん', deadline: 2.days.from_now, user: user)
          create(:task, user: user)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task3)
          login_as(user)
          click_link 'foo'
          # TODO
          sleep(1)
          click_link '締切が近い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/りんご|バナナ|みかん/)
              end
              expect(task_titles[0].text).to eq task2.title
              expect(task_titles[1].text).to eq task3.title
              expect(task_titles[2].text).to eq task1.title
            end
          end
        end

        it '検索結果を優先度が高い順に並び替えできる' do
          task1 = create(:task, title: 'りんご', priority: 'mid', user: user)
          task2 = create(:task, title: 'バナナ', priority: 'low', user: user)
          task3 = create(:task, title: 'みかん', priority: 'high', user: user)
          create(:task, priority: 'low', user: user)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task3)
          login_as(user)
          click_link 'foo'
          # TODO
          sleep(1)
          click_link '重要度の高い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/りんご|バナナ|みかん/)
              end
              expect(task_titles[0].text).to eq task3.title
              expect(task_titles[1].text).to eq task1.title
              expect(task_titles[2].text).to eq task2.title
            end
          end
        end

        it '検索結果を優先度が低い順に並び替えできる' do
          task1 = create(:task, title: 'りんご', priority: 'mid', user: user)
          task2 = create(:task, title: 'バナナ', priority: 'low', user: user)
          task3 = create(:task, title: 'みかん', priority: 'high', user: user)
          create(:task, priority: 'low', user: user)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task3)
          login_as(user)
          click_link 'foo'
          # TODO
          sleep(1)
          click_link '重要度の低い順'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 3
              task_titles.each do |el|
                expect(el.text).to match(/りんご|バナナ|みかん/)
              end
              expect(task_titles[0].text).to eq task2.title
              expect(task_titles[1].text).to eq task1.title
              expect(task_titles[2].text).to eq task3.title
            end
          end
        end
      end

      describe '絞り込み' do
        it '検索結果をステータスで絞り込める' do
          task1 = create(:task, title: 'りんご', state: 'done', user: user)
          task2 = create(:task, title: 'バナナ', state: 'in_progress', user: user)
          task3 = create(:task, title: 'みかん', state: 'not_started', user: user)
          create(:task, state: 'done', user: user)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task1)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task2)
          create(:tagging, tag: create(:tag, name: 'foo'), task: task3)
          login_as(user)
          click_link 'foo'
          # TODO
          sleep(1)
          click_link '完了したタスク'
          # TODO
          sleep(1)
          wait_for_css_appear('.task-card') do
            within(:test, 'task-list') do
              task_titles = all(:test, 'task-title')
              expect(task_titles.count).to be 1
              task_titles.each do |el|
                expect(el.text).to match(/りんご/)
              end
            end
          end
        end
      end
    end
  end

  describe 'ステータス更新' do
    let(:user) { create(:user) }

    context '現在のステータスが「未着手」の時' do
      it 'ステータスが「着手」に更新される' do
        create(:task, :not_started_task, user: user)
        login_as(user)
        expect(find(:test, 'update-state').value).to eq '未着手'
        click_button '未着手'
        # TODO
        sleep(1)
        expect(find(:test, 'update-state').value).to eq '着手'
      end
    end

    context '現在のステータスが「着手」の時' do
      it 'ステータスが「完了」に更新される' do
        create(:task, :in_progress_task, user: user)
        login_as(user)
        expect(find(:test, 'update-state').value).to eq '着手'
        click_button '着手'
        # TODO
        sleep(1)
        expect(find(:test, 'update-state').value).to eq '完了'
      end
    end

    context '現在のステータスが「完了」の時' do
      it 'ステータスが「未着手」に更新される' do
        create(:task, :done_task, user: user)
        login_as(user)
        expect(find(:test, 'update-state').value).to eq '完了'
        click_button '完了'
        # TODO
        sleep(1)
        expect(find(:test, 'update-state').value).to eq '未着手'
      end
    end
  end
end
