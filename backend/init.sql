-- 順番待ちシステム - 初期データベーススキーマ

-- 受付テーブル
CREATE TABLE IF NOT EXISTS reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reception_number VARCHAR(10) NOT NULL UNIQUE,
    reception_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    adult_count INT NOT NULL DEFAULT 0,
    child_count INT NOT NULL DEFAULT 0,
    seat_type ENUM('table', 'counter') NOT NULL,
    smoking ENUM('non_smoking', 'smoking') NOT NULL,
    status ENUM('waiting', 'calling', 'seated', 'cancelled') NOT NULL DEFAULT 'waiting',
    called_datetime DATETIME NULL,
    seated_datetime DATETIME NULL,
    cancelled_datetime DATETIME NULL,
    qr_code_url VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_reception_number (reception_number),
    INDEX idx_status (status),
    INDEX idx_reception_datetime (reception_datetime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 店舗設定テーブル
CREATE TABLE IF NOT EXISTS store_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL DEFAULT '店舗名',
    average_service_time_minutes INT NOT NULL DEFAULT 15,
    opening_time TIME NULL,
    closing_time TIME NULL,
    store_password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ステータス変更履歴テーブル
CREATE TABLE IF NOT EXISTS status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    old_status ENUM('waiting', 'calling', 'seated', 'cancelled') NULL,
    new_status ENUM('waiting', 'calling', 'seated', 'cancelled') NOT NULL,
    changed_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
    INDEX idx_reservation_id (reservation_id),
    INDEX idx_changed_datetime (changed_datetime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初期店舗設定データ挿入（パスワード: admin123）
INSERT INTO store_settings (store_name, average_service_time_minutes, opening_time, closing_time, store_password_hash)
VALUES (
    '順番待ちシステム',
    15,
    '11:00:00',
    '22:00:00',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIAXwdZvaq'
)
ON DUPLICATE KEY UPDATE id=id;

-- サンプルデータ（開発用）
-- INSERT INTO reservations (reception_number, adult_count, child_count, seat_type, smoking, status)
-- VALUES
--     ('001', 2, 0, 'table', 'non_smoking', 'waiting'),
--     ('002', 4, 1, 'table', 'non_smoking', 'waiting'),
--     ('003', 1, 0, 'counter', 'non_smoking', 'calling'),
--     ('004', 3, 2, 'table', 'non_smoking', 'waiting');
