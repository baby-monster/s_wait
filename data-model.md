# データモデル設計書

順番待ちシステムのデータベース設計

---

## 使用データベース

- **DBMS**: MySQL 8.0
- **文字コード**: utf8mb4
- **照合順序**: utf8mb4_unicode_ci

---

## テーブル一覧

1. **queues** - 受付情報テーブル
2. **settings** - 店舗設定テーブル

---

## 1. queues（受付情報テーブル）

### 概要
顧客の受付情報を管理するメインテーブル

### テーブル定義

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|-----------|------|
| id | INT | NO | AUTO_INCREMENT | 主キー |
| queue_number | INT | NO | - | 受付番号（可変長: 1, 2, 3...） |
| token | VARCHAR(255) | NO | - | QRコード用トークン（UUID） |
| adult_count | INT | NO | - | 大人人数 |
| child_count | INT | NO | 0 | 子供人数 |
| seat_type | ENUM('table', 'counter') | NO | - | 座席タイプ |
| is_non_smoking | BOOLEAN | NO | TRUE | 禁煙/喫煙（TRUE: 禁煙） |
| status | ENUM('waiting', 'calling', 'on_hold', 'completed', 'cancelled') | NO | 'waiting' | ステータス |
| registered_at | DATETIME | NO | CURRENT_TIMESTAMP | 受付日時 |
| called_at | DATETIME | YES | NULL | 呼び出し日時 |
| on_hold_at | DATETIME | YES | NULL | 保留日時 |
| completed_at | DATETIME | YES | NULL | 案内完了日時 |
| cancelled_at | DATETIME | YES | NULL | キャンセル日時 |
| created_at | DATETIME | NO | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | DATETIME | NO | CURRENT_TIMESTAMP ON UPDATE | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_queue_number (queue_number)
UNIQUE INDEX idx_token (token)
INDEX idx_status (status)
INDEX idx_registered_at (registered_at)
```

### ステータス値

| 値 | 説明 | 遷移元 |
|----|------|--------|
| waiting | 待機中 | - (初期状態) |
| calling | 呼び出し中 | waiting, on_hold |
| on_hold | 保留 | calling |
| completed | 案内完了 | calling |
| cancelled | キャンセル | waiting, calling, on_hold |

### 制約

- `adult_count`: 1以上
- `child_count`: 0以上
- `adult_count + child_count`: 8以下
- `token`: UUID v4形式
- `queue_number`: ユニーク、連番

---

## 2. settings（店舗設定テーブル）

### 概要
店舗の設定情報を管理するテーブル（1レコードのみ）

### テーブル定義

| カラム名 | データ型 | NULL | デフォルト | 説明 |
|---------|---------|------|-----------|------|
| id | INT | NO | 1 | 主キー（固定値: 1） |
| store_name | VARCHAR(255) | YES | NULL | 店舗名 |
| password_hash | VARCHAR(255) | NO | - | パスワードハッシュ（bcrypt） |
| business_start_time | TIME | YES | NULL | 営業開始時刻 |
| business_end_time | TIME | YES | NULL | 営業終了時刻 |
| notification_threshold | INT | YES | 3 | Push通知の組数（将来用） |
| created_at | DATETIME | NO | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | DATETIME | NO | CURRENT_TIMESTAMP ON UPDATE | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
```

### 制約

- `id`: 固定値 1（シングルトン）
- `password_hash`: bcryptハッシュ形式
- `notification_threshold`: 1〜10

### 初期データ

```sql
INSERT INTO settings (id, password_hash)
VALUES (1, '$2b$12$...'); -- デフォルトパスワード "admin" のハッシュ
```

---

## ER図（テキスト表現）

```
┌─────────────────┐
│    settings     │
│  (店舗設定)     │
├─────────────────┤
│ id (PK)         │
│ store_name      │
│ password_hash   │
│ ...             │
└─────────────────┘

┌─────────────────┐
│     queues      │
│   (受付情報)    │
├─────────────────┤
│ id (PK)         │
│ queue_number    │
│ token           │
│ adult_count     │
│ child_count     │
│ seat_type       │
│ is_non_smoking  │
│ status          │
│ registered_at   │
│ called_at       │
│ on_hold_at      │
│ completed_at    │
│ cancelled_at    │
│ ...             │
└─────────────────┘
```

---

## 決定事項

### データ保持期間
- **永続保持**
- すべての受付データを削除せず保持
- 削除機能は初期実装では不要

### その他のテーブル
- **WebSocket接続管理テーブル**: 不要（メモリ上で管理）
- **セッション管理テーブル**: 不要（JWTトークンベース認証）

### 最終的なテーブル構成
システムに必要なテーブルは以下の2つのみ：
1. **queues** - 受付情報テーブル
2. **settings** - 店舗設定テーブル

---

## 補足事項

### 受付番号の採番ロジック

受付番号は可変長の連番（リセットなし）：

```sql
-- 最新の受付番号を取得
SELECT MAX(queue_number) FROM queues;

-- 次の番号を生成（アプリケーション層）
next_number = max_number + 1  # 例: 999 → 1000

-- データベースに数値として保存
INSERT INTO queues (queue_number, ...) VALUES (next_number, ...);
```

**表示時の処理:**
- データベースから取得した数値をそのまま文字列に変換
- ゼロパディングなし（1, 2, 3, ..., 999, 1000...）

### QRコードトークンの生成

```python
import uuid

token = str(uuid.uuid4())  # 例: "550e8400-e29b-41d4-a716-446655440000"
```

### パスワードハッシュ化

```python
import bcrypt

password = "admin"
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
```

---
