# 申請フロー

ここでは申請およびバージョン発行・データ管理のフロー表示を行います。

```mermaid
graph TD
    %% --- ① 申請データ作成 ---
    subgraph S1["① 申請データ作成・保存"]
        id13["申請データを入カ"]
        id14{"申請方法の選択"}
        id15["即時申請を選ぶ"]
        id16["下書き保存を選択"]
    end

    %% --- ② 申請データ作成確認モーダル ---
    subgraph S2["② 申請データ作成確認モーダル"]
        id17["申請データ、リテンション値の確認"]
        id18["申請データ、リテンション値の確認"]
        id19{"リテンション値が<br>基準値を超えるか?"}
        id20{"リテンション値が<br>基準値を超えるか?"}
        id21["リテンション値用<br>確認メッセージ表示"]
        id22["リテンション値用<br>確認メッセージ表示"]
        id23["申請者基本情報 <br> レビュー前確認事項を入力"]
        id24["基本情報・確認事項の<br>入力は不要"]
        id25["申請を完了<br>(application_id発行)"]
        id26["下書き保存を完了<br>(application_id発行)"]
    end

    %% --- ③ 申請一覧画面 ---
    subgraph S3["③ 申請一覧画面"]
        id28["申請前データ表示<br>Jiraステータス: 申請前<br>投入ステータス: (空欄)"]
        id27["申請後データ表示<br>Jiraステータス: オープン<br>投入ステータス: 承認待ち"]
        
        id29["起票前の複数申請データを選択"]
        id30["複製する申請データを選択"]
        id31["編集する申請データを選択"]
        id32["詳細画面の「編集申請」ボタンをクリック"]
        
        id_approve["【レビュアー操作】<br>Jiraチケットを承認する"]
        id_target["投入ステータスを<br>「投入対象」に変更"]
        
        %% バージョン発行フロー（申請一覧画面内で独立した起点）
        id_release_btn["【管理者操作】<br>「バージョン発行」ボタン押下"]
        id_admin_check["管理者コードを入力"]
        id_admin_auth{"管理者コードは<br>正しいか？"}
        id_admin_fail["エラー表示<br>(処理中断)"]
        
        id_batch_insert["投入ステータスが『投入対象』に<br>なっているレコード（＝前回バージョン発行から<br>新たに承認された更新分）をまとめて抽出。<br>新規バージョンとして各データ管理テーブル<br>(backuptbl/nandtbl等)へ一括格納"]
        id_status_done["reviewtblの投入ステータスを<br>「投入完了」に更新"]
    end

    %% --- ④ 複数申請起票フロー ---
    subgraph S5["④ 申請起票モーダル / 確認モーダル"]
        id33["申請データ、リテンション値の確認"]
        id34{"リテンション値が<br>基準値を超えるか?"}
        id35["リテンション値用<br>確認メッセージ表示"]
        id36["申請者基本情報 <br> レビュー前確認事項を入力"]
        id37["申請データ・基本情報・<br>確認事項の最終確認"]
        id38["「申請」ボタンをクリック"]
        id53["Jiraチケットを起票<br>(jira_urlの確定)"]
        id54["Jiraステータスを<br>「オープン」に更新"]
    end

    %% --- ⑤ 複製・編集・再申請フロー ---
    subgraph S4["⑤ 複製・編集・再申請処理"]
        %% 複製
        id39["複製データの内容確認・編集"]
        id40["複製内容の最終確認"]
        id41["「複製」ボタンをクリック"]
        id55["複製データを新規作成"]
        %% 再申請
        id42["複数の申請データに対して、編集を加える"]
        id43["申請データ変更分、リテンション値の確認"]
        id44{"リテンション値が<br>基準値を超えるか?"}
        id45["リテンション値用<br>確認メッセージ表示"]
        id47["レビュー前確認事項の入力"]
        id56["Jiraチケットの更新申請"]
        %% 編集
        id48["申請データの再編集"]
        id49["データ、リテンション値の確認"]
        id50{"リテンション値が<br>基準値を超えるか?"}
        id51["リテンション値用<br>確認メッセージ表示"]
        id52["「保存」ボタンをクリック"]
        id57["申請データを更新保存"]
    end

    %% --- ⑥ データ管理一覧画面 ---
    subgraph S6["⑥ データ管理一覧画面"]
        id_data_view["データ管理一覧画面<br>(最新バージョンに基づき表示)"]
        id_user_check["【申請者操作】<br>データ投入を確認し、<br>Jiraチケットをクローズする"]
    end

    %% --- ⑦ 定期実行バッチ ---
    subgraph S7["⑦ 定期実行バッチ (自動同期)"]
        id_cron["定期実行バッチが起動<br>(クローズされていないJiraを監視)"]
        id_jira_api["Jira APIを叩いてステータスを確認"]
        id_cron_check{"Jira側がクローズ<br>されているか?"}
        id_db_finish["applicationtblのjira_statusを<br>「完了」に更新"]
    end

    %% --- 処理のフロー（接続関係） ---
    id13 --> id14
    id14 -->|即時申請| id15
    id14 -->|下書き保存| id16
    id15 --> id17
    id16 --> id18
    id17 --> id19
    id18 --> id20
    
    id19 -->|Yes| id21
    id19 -->|No| id23
    id21 --> id23
    
    id20 -->|Yes| id22
    id20 -->|No| id24
    id22 --> id24
    
    id23 --> id25
    id24 --> id26
    
    id25 --> id27
    id26 --> id28
    
    %% 申請一覧からの分岐
    id28 --> id29
    id28 --> id30
    id28 --> id31
    id27 --> id32
    
    %% 複数申請起票
    id29 --> id33
    id33 --> id34
    id34 -->|Yes| id35
    id34 -->|No| id36
    id35 --> id36
    id36 --> id37
    id37 --> id38
    id38 --> id53
    id53 --> id54
    id54 --> id27
    
    %% 複製フロー
    id30 --> id39
    id39 --> id40
    id40 --> id41
    id41 --> id55
    id55 --> id28
    
    %% 再申請フロー
    id32 --> id42
    id42 --> id43
    id43 --> id44
    id44 -->|Yes| id45
    id44 -->|No| id47
    id45 --> id47
    id47 --> id56
    id56 --> id27
    
    %% 編集フロー
    id31 --> id48
    id48 --> id49
    id49 --> id50
    id50 -->|Yes| id51
    id50 -->|No| id52
    id51 --> id52
    id52 --> id57
    id57 --> id28

    %% --- 承認フロー ---
    id27 --> id_approve
    id_approve --> id_target
    
    %% バージョン発行フロー（完全に独立したボタン押下が起点）
    id_release_btn --> id_admin_check
    id_admin_check --> id_admin_auth
    id_admin_auth -->|No: 認証失敗| id_admin_fail
    id_admin_auth -->|Yes: 認証成功| id_batch_insert
    
    id_batch_insert --> id_status_done
    id_status_done --> id_data_view
    
    id_data_view --> id_user_check
    
    %% 定期実行バッチ（他の画面フローから独立してループ）
    id_cron --> id_jira_api
    id_jira_api --> id_cron_check
    id_cron_check -->|Yes| id_db_finish
    id_cron_check -->|No| id_cron