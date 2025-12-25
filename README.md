# 順番待ちシステム

飲食店向けの順番待ち管理システムです。

## クイックスタート

VS Code Dev Containersで即座に開発を開始:

1. このリポジトリをクローン
2. **MySQLコンテナを起動**（別ターミナルで）:
   ```bash
   docker-compose -f docker-compose.db.yml up -d
   ```
3. VS Codeで開く
4. `Ctrl+Shift+P` → `Dev Containers: Reopen in Container`
5. コンテナ起動後、ターミナルで:
   - バックエンド: `cd backend && uvicorn main:app --reload --host 0.0.0.0`
   - フロントエンド: `cd frontend && npm run dev`

開発環境（Node.js、Python）が自動的にセットアップされ、別コンテナのMySQLに接続します。

## 技術スタック

- **バックエンド**: Python 3.11 + FastAPI
- **フロントエンド**: Next.js 14 + React
- **データベース**: MySQL 8.0
- **リアルタイム通信**: WebSocket
- **開発環境**: VS Code Dev Containers

## 機能

- 受付・発券機能（QRコード生成）
- 順番管理機能（待ち状況一覧、ソート）
- 呼び出し機能（手動呼び出し、ステータス変更）
- 顧客向け待ち状況確認画面（リアルタイム更新）
- 店舗側管理画面（ダッシュボード、受付、一覧管理）

## セットアップ

### 前提条件

- Docker Desktop
- Visual Studio Code
- VS Code拡張機能: Dev Containers (ms-vscode-remote.remote-containers)

### 開発環境のセットアップ（推奨）

VS Code Dev Containersを使用すると、すべての開発環境が自動的にセットアップされます。

1. **リポジトリをクローン**

```bash
git clone <repository-url>
cd queue-system
```

2. **MySQLコンテナを起動**

Dev Container環境とは別にMySQLコンテナを起動します:

```bash
# dev-networkを作成（初回のみ）
docker network create dev-network

# MySQLコンテナを起動
docker-compose -f docker-compose.db.yml up -d

# 起動確認
docker-compose -f docker-compose.db.yml ps
```

3. **VS Codeで開く**

```bash
code .
```

4. **Dev Containerで再度開く**

- VS Codeで `Ctrl+Shift+P` (Mac: `Cmd+Shift+P`)
- `Dev Containers: Reopen in Container` を選択
- 初回は数分かかります（Node.js、Pythonのセットアップとパッケージインストール）
- MySQLコンテナへの接続確認も自動で行われます

5. **開発サーバーの起動**

コンテナ内のターミナルで：

```bash
# バックエンドの起動
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# 別のターミナルでフロントエンドの起動
cd frontend
npm run dev
```

5. **ブラウザでアクセス**

- フロントエンド: http://localhost:3000
- バックエンドAPI: http://localhost:8000
- API ドキュメント: http://localhost:8000/docs

### 本番環境のセットアップ（Docker Composeのみ）

開発コンテナを使わない場合の起動手順：

1. リポジトリをクローン

```bash
git clone <repository-url>
cd queue-system
```

2. 環境変数ファイルをコピー

```bash
cp .env.example .env
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

3. 環境変数を編集（必要に応じて）

```bash
# .envファイルを編集
nano .env
```

4. Dockerコンテナを起動

```bash
docker-compose up -d
```

5. ブラウザでアクセス

- フロントエンド: http://localhost:3000
- バックエンドAPI: http://localhost:8000
- API ドキュメント: http://localhost:8000/docs

## 開発環境の詳細

### Dev Container環境の構成

- **開発コンテナ (app)**: Node.js 20 + Python 3.11（開発環境）
- **MySQLコンテナ (db)**: MySQL 8.0（別コンテナとして起動）
- **ネットワーク**: dev-network（両コンテナが通信可能）

開発コンテナとMySQLコンテナは独立して起動し、`dev-network`で接続されます。
これにより、MySQLを再起動せずに開発環境のみを再構築できます。

### 環境変数

環境変数は自動的にコピーされます:
- `.env.example` → `.env`
- `backend/.env.example` → `backend/.env`
- `frontend/.env.example` → `frontend/.env.local`

手動で設定する場合は、各`.env`ファイルを編集してください。

### データベース接続

Dev Container内からMySQLに接続（MySQLは別コンテナ `db` として起動）:

```bash
mysql -h db -u queueuser -p queue_system
# パスワード: queuepass
```

または：

```bash
# rootユーザーとして
mysql -h db -u root -p
# パスワード: rootpassword
```

ホストマシンからMySQLに接続:

```bash
mysql -h localhost -P 3306 -u queueuser -p queue_system
# パスワード: queuepass
```

## 本番環境での開発

### ログの確認

```bash
# 全てのログ
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### コンテナの再起動

```bash
# 全てのコンテナ
docker-compose restart

# 特定のコンテナ
docker-compose restart backend
```

### コンテナの停止

```bash
docker-compose down

# ボリュームも削除する場合
docker-compose down -v
```

### データベースに接続

```bash
docker-compose exec db mysql -u queueuser -p queue_system
# パスワード: queuepass (デフォルト)
```

## プロジェクト構造

```
.
├── .devcontainer/           # VS Code Dev Container設定
│   ├── Dockerfile          # 開発環境用コンテナ
│   ├── docker-compose.yml  # 開発環境用Compose設定
│   ├── devcontainer.json   # Dev Container設定
│   └── post-create.sh      # 初期セットアップスクリプト
├── backend/                # FastAPIバックエンド
│   ├── Dockerfile          # 本番環境用
│   ├── requirements.txt    # Python依存パッケージ
│   ├── main.py            # FastAPIアプリケーション
│   ├── init.sql           # データベース初期化SQL
│   └── .env.example       # バックエンド環境変数
├── frontend/               # Next.jsフロントエンド
│   ├── Dockerfile          # 本番環境用
│   ├── package.json        # Node.js依存パッケージ
│   └── .env.example        # フロントエンド環境変数
├── docker-compose.yml      # 本番環境用Compose設定
├── .env.example           # 環境変数テンプレート
├── .gitignore
├── spec.md                # 仕様書
└── README.md
```

## トラブルシューティング

### Dev Container関連

#### コンテナが起動しない

1. Docker Desktopが起動しているか確認
2. VS Codeを再起動
3. コンテナを再ビルド: `Ctrl+Shift+P` → `Dev Containers: Rebuild Container`

#### MySQLに接続できない

```bash
# MySQLの状態を確認
docker ps

# MySQLのログを確認
docker logs <mysql-container-id>

# MySQLが起動するまで待つ（通常30秒程度）
```

#### ポートが既に使用されている

ポート3000、8000、3306が既に使用されている場合:
- 既存のプロセスを停止
- または `.devcontainer/docker-compose.yml` でポート設定を変更

#### 環境変数が反映されない

```bash
# Dev Containerを再起動
Ctrl+Shift+P → Dev Containers: Rebuild Container
```

### 本番環境（Docker Compose）関連

#### データベース接続エラー

1. データベースコンテナが起動しているか確認
2. 環境変数が正しく設定されているか確認
3. データベースのヘルスチェックが完了するまで待つ

#### コンテナのビルドエラー

```bash
# キャッシュをクリアして再ビルド
docker-compose build --no-cache
```

## ライセンス

MIT
