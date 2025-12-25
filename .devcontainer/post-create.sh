#!/bin/bash
set -e

echo "🚀 Setting up development environment..."

# バックエンドのセットアップ
if [ -f "backend/requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."
    cd backend
    pip install -r requirements.txt --quiet
    cd ..
fi

# フロントエンドのセットアップ
if [ -f "frontend/package.json" ]; then
    echo "📦 Installing Node.js dependencies..."
    cd frontend
    npm install --quiet
    cd ..
fi

# 環境変数ファイルのコピー
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
fi

if [ ! -f "backend/.env" ] && [ -f "backend/.env.example" ]; then
    echo "📝 Creating backend/.env file..."
    cp backend/.env.example backend/.env
fi

if [ ! -f "frontend/.env.local" ] && [ -f "frontend/.env.example" ]; then
    echo "📝 Creating frontend/.env.local file..."
    cp frontend/.env.example frontend/.env.local
fi

# MySQLの起動を待つ（別コンテナで起動しているものを確認）
echo "⏳ Waiting for MySQL (db container) to be ready..."
for i in {1..30}; do
    if mysqladmin ping -h db -u root -prootpassword --silent 2>/dev/null; then
        echo "✅ MySQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  MySQL (db container) is not accessible."
        echo "    Make sure the MySQL container is running on the dev-network."
    fi
    sleep 2
done

echo "✅ Development environment setup complete!"
echo ""
echo "📍 Next steps:"
echo "  - Frontend: cd frontend && npm run dev"
echo "  - Backend:  cd backend && uvicorn main:app --reload --host 0.0.0.0"
echo "  - MySQL:    mysql -h db -u queueuser -p queue_system"
echo ""
echo "💡 Note: MySQL is running in a separate container named 'db' on dev-network"
echo ""
