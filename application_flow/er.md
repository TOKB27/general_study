# ER図

ER図の表示を行います。

```mermaid
erDiagram
    %% 申請一覧（Jiraチケット単位）を管理するテーブル
    applicationtbl {
        int application_id PK "申請ID（自動採番）"
        string jira_url "JiraチケットのURL"
        string applicant "申請者"
        string jira_status "Jiraステータス（オープン/承認/完了など。バッチで同期）"
        datetime applied_at "申請日時"
    }

    %% 各データの申請データを管理するテーブル
    reviewtbl {
        int review_id PK "レビューデータID"
        int application_id FK "申請ID"
        string target_table "対象テーブル名（backuptbl等）"
        int target_resource_number "対象のresource_number (新規時はNULL可)"
        string application_type "申請種別（新規/更新/削除など）"
        string input_status "投入ステータス（承認待ち / 投入対象 / 投入完了）"
        jsonb from_data "申請前データ"
        jsonb to_data "申請データ"
        datetime updated_at "更新日時"
    }

    %% 【新規追加】バージョン（世代）そのものを管理するテーブル
    version_managertbl {
        int version_id PK "バージョン内部ID（自動採番）"
        string version_name "バージョン名（例: 260706_DCS_24su2）"
        string project_code "識別子（例: DCS_24su2 ※4種類存在）"
        date release_date "発行年月日（例: 2026-07-06）"
        datetime created_at "発行日時"
    }

    %% データ管理テーブル：backuptbl
    backuptbl {
        int resource_number PK "自動採番ID"
        int version_id PK "外部キー：発行されたバージョンID"
        int application_id FK "元となった申請ID"
        jsonb resource_data "resourceデータ"
        datetime updated_at "バージョン発行日時（格納日）"
        string is_deleted "削除フラグ"
    }

    %% データ管理テーブル：nandtbl
    nandtbl {
        int resource_number PK "自動採番ID"
        int version_id PK "外部キー：発行されたバージョンID"
        int application_id FK "元となった申請ID"
        jsonb resource_data "resourceデータ"
        datetime updated_at "バージョン発行日時（格納日）"
        string is_deleted "削除フラグ"
    }

    %% データ管理テーブル：propertymanagertbl
    propertymanagertbl {
        int resource_number PK "自動採番ID"
        int version_id PK "外部キー：発行されたバージョンID"
        int application_id FK "元となった申請ID"
        jsonb resource_data "resourceデータ"
        datetime updated_at "バージョン発行日時（格納日）"
        string is_deleted "削除フラグ"
    }

    %% データ管理テーブル：biltbl
    biltbl {
        int resource_number PK "自動採番ID"
        int version_id PK "外部キー：発行されたバージョンID"
        int application_id FK "元となった申請ID"
        jsonb resource_data "resourceデータ"
        datetime updated_at "バージョン発行日時（格納日）"
        string is_deleted "削除フラグ"
    }

    %% リレーションシップの定義
    applicationtbl ||--o{ reviewtbl : "application_id で紐付け"
    version_managertbl ||--o{ backuptbl : "version_id で世代を紐付け"
    version_managertbl ||--o{ nandtbl : "version_id で世代を紐付け"
    version_managertbl ||--o{ propertymanagertbl : "version_id で世代を紐付け"
    version_managertbl ||--o{ biltbl : "version_id で世代を紐付け"
    applicationtbl ||--o{ backuptbl : "監査用 (application_id)"
    applicationtbl ||--o{ nandtbl : "監査用 (application_id)"
    applicationtbl ||--o{ propertymanagertbl : "監査用 (application_id)"
    applicationtbl ||--o{ biltbl : "監査用 (application_id)"