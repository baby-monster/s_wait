"""
順番待ちシステム - FastAPI バックエンド
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

# FastAPIアプリケーションの作成
app = FastAPI(
    title="順番待ちシステム API",
    description="飲食店向け順番待ち管理システムのバックエンドAPI",
    version="1.0.0"
)

# CORS設定
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    """
    ルートエンドポイント - APIの動作確認用
    """
    return {
        "message": "順番待ちシステム API",
        "status": "running",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """
    ヘルスチェックエンドポイント
    """
    return {
        "status": "healthy",
        "database": "connected"  # TODO: 実際のDB接続チェックを実装
    }


# TODO: 以下のエンドポイントを実装
# - 受付管理 (/api/reservations)
# - 店舗設定 (/api/settings)
# - WebSocket (/ws/queue)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
