DROP DATABASE IF EXISTS `my-books-db`;
CREATE DATABASE `my-books-db`;

USE `my-books-db`;

DROP TABLE IF EXISTS `books`;
DROP TABLE IF EXISTS `genres`;
DROP TABLE IF EXISTS `book_genres`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `user_roles`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `favorites`;
DROP TABLE IF EXISTS `bookmarks`;
DROP TABLE IF EXISTS `book_chapters`;
DROP TABLE IF EXISTS `book_chapter_page_contents`;


CREATE TABLE `books` (
  `id` VARCHAR(255) NOT NULL PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL DEFAULT '',
  `description` TEXT NOT NULL,
  `authors` VARCHAR(255) NOT NULL DEFAULT '',
  `publisher` VARCHAR(255) NOT NULL DEFAULT '',
  `publication_date` DATE NOT NULL,
  `price` BIGINT NOT NULL DEFAULT 0,
  `page_count` BIGINT NOT NULL DEFAULT 0,
  `isbn` VARCHAR(255) NOT NULL DEFAULT '',
  `image_path` VARCHAR(255) DEFAULT NULL,
  `average_rating` DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
  `review_count` BIGINT NOT NULL DEFAULT 0,
  `popularity` DECIMAL(8, 2) NOT NULL DEFAULT 0.000,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE `genres` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE `book_genres` (
  `book_id` VARCHAR(255) NOT NULL,
  `genre_id` BIGINT NOT NULL,
  PRIMARY KEY (`book_id`, `genre_id`),
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`genre_id`) REFERENCES `genres`(`id`) ON DELETE CASCADE
);

CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL DEFAULT '',
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `avatar_path` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE `user_roles` (
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE
);

CREATE TABLE `reviews` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `comment` VARCHAR(1000) NOT NULL DEFAULT '',
  `rating` DECIMAL(2, 1) NOT NULL DEFAULT 0.0 CHECK (`rating` >= 0 AND `rating` <= 5),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `favorites` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `book_chapters` (
  `book_id` VARCHAR(255) NOT NULL,
  `chapter_number` BIGINT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`book_id`, `chapter_number`),
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `book_chapter_page_contents` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `book_id` VARCHAR(255) NOT NULL,
  `chapter_number` BIGINT NOT NULL,
  `page_number` BIGINT NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (`book_id`, `chapter_number`, `page_number`),
  FOREIGN KEY (`book_id`, `chapter_number`) REFERENCES `book_chapters`(`book_id`, `chapter_number`) ON DELETE CASCADE
);

CREATE TABLE `bookmarks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `page_content_id` BIGINT NOT NULL,
  `note` VARCHAR(1000) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (`user_id`, `page_content_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`page_content_id`) REFERENCES `book_chapter_page_contents`(`id`) ON DELETE CASCADE
);

-- データのロード
LOAD DATA INFILE '/docker-entrypoint-initdb.d/books.csv'
INTO TABLE books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`id`, `title`, `description`, `authors`, `publisher`, `publication_date`, `price`, `page_count`, `isbn`, `image_path`);

INSERT INTO `genres` (`name`, `description`) VALUES
('ミステリー', '謎解きや推理をテーマにした作品'),
('サスペンス', '緊張感や驚きを伴う作品'),
('ロマンス', '恋愛をテーマにした作品'),
('ファンタジー', '魔法や異世界を舞台にした作品'),
('SF', '科学技術や未来をテーマにした作品'),
('ホラー', '恐怖をテーマにした作品'),
('歴史', '歴史的な出来事や人物をテーマにした作品'),
('絵本', '子供向けのイラストが多い本'),
('教科書', '教育機関で使用される教材'),
('専門書', '特定の分野に特化した書籍'),
('研究書', '学術的な研究をまとめた書籍'),
('環境', '自然や環境問題をテーマにした作品'),
('冒険', '冒険や探検をテーマにした作品'),
('図鑑', '特定のテーマに関する情報を集めた書籍'),
('音楽', '音楽に関する書籍'),
('ドラマ', '人間関係や感情を描いた作品'),
('教育', '教育に関する書籍');

LOAD DATA INFILE '/docker-entrypoint-initdb.d/book_genres.csv'
INTO TABLE book_genres
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`book_id`, `genre_id`);

INSERT INTO `users` (`name`, `email`, `password`, `avatar_path`) VALUES
('Lars', 'lars@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar01.png'),
('Nina', 'nina@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar40.png'),
('Paul', 'paul@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar09.png'),
('Julia', 'julia@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar04.png'),
('Eddy', 'lee@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar05.png'),
('Lili', 'lili@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar28.png'),
('Steve', 'steve@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar37.png'),
('Anna', 'anna@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar12.png'),
('Law', 'law@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar07.png'),
('Alisa', 'alisa@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', '/avatar10.png');

INSERT INTO `roles` (`name`, `description`) VALUES
('ROLE_ADMIN', '管理者権限'),
('ROLE_USER', 'ユーザー権限');

INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
(1, 2),
(2, 2),
(3, 2),
(4, 2),
(5, 2),
(6, 2),
(7, 2),
(8, 2),
(9, 2),
(10, 2),
(3, 1),
(4, 1);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/book_reviews.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`user_id`, `book_id`, `comment`, `rating`);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/book_favorites.csv'
INTO TABLE favorites
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`user_id`, `book_id`);

INSERT INTO `book_chapters` (`book_id`, `chapter_number`, `title`) VALUES
('afcIMuetDuzj', 1, 'プロローグ'),
('afcIMuetDuzj', 2, '湖畔の招待状'),
('afcIMuetDuzj', 3, '運命の出会い'),
('afcIMuetDuzj', 4, '舞踏会の奇跡'),
('afcIMuetDuzj', 5, '消えゆく光'),
('afcIMuetDuzj', 6, '新たな誓い'),
('aBcDeFgHiJkL', 1, 'ドラゴンとは何か？'),
('aBcDeFgHiJkL', 2, '世界のドラゴン伝承'),
('aBcDeFgHiJkL', 3, 'ドラゴンと人類の歴史'),
('aBcDeFgHiJkL', 4, 'ドラゴンの姿と能力'),
('aBcDeFgHiJkL', 5, 'ドラゴンと文化・信仰'),
('aBcDeFgHiJkL', 6, 'ドラゴンの科学的解釈と実在の可能性'),
('aBcDeFgHiJkL', 7, '現代社会におけるドラゴンの影響'),
('C4hD3jZ8rK6e', 1, '沈黙の楽園'),
('C4hD3jZ8rK6e', 2, '血に染まる羽'),
('C4hD3jZ8rK6e', 3, '華やかな仮面'),
('C4hD3jZ8rK6e', 4, 'フラミンゴの秘密'),
('C4hD3jZ8rK6e', 5, '沈黙の目撃者'),
('C4hD3jZ8rK6e', 6, '遺言の行方'),
('C4hD3jZ8rK6e', 7, '奪われた遺言'),
('C4hD3jZ8rK6e', 8, 'フラミンゴの夜'),
('C4hD3jZ8rK6e', 9, '沈んだ証拠'),
('C4hD3jZ8rK6e', 10, 'フラミンゴの遺言'),
('Hh5r4Kj9Tb8v', 1, '春の訪問者'),
('Hh5r4Kj9Tb8v', 2, '旋律の源'),
('Hh5r4Kj9Tb8v', 3, '画家との邂逅'),
('Hh5r4Kj9Tb8v', 4, '交差する芸術'),
('Hh5r4Kj9Tb8v', 5, '心の葛藤'),
('Hh5r4Kj9Tb8v', 6, '失われた旋律'),
('Hh5r4Kj9Tb8v', 7, 'ツルの帰還'),
('Hh5r4Kj9Tb8v', 8, '二つの世界'),
('Hh5r4Kj9Tb8v', 9, '共鳴する心'),
('Hh5r4Kj9Tb8v', 10, '永遠の旋律'),
('dJ4fLnQ2ZcR3', 1, '失踪'),
('dJ4fLnQ2ZcR3', 2, '画家の軌跡'),
('dJ4fLnQ2ZcR3', 3, '山への道'),
('dJ4fLnQ2ZcR3', 4, '絵の中の秘密'),
('dJ4fLnQ2ZcR3', 5, '伝説の追跡'),
('dJ4fLnQ2ZcR3', 6, 'ヤギの足跡'),
('dJ4fLnQ2ZcR3', 7, '境界の絵'),
('dJ4fLnQ2ZcR3', 8, '扉が開く時'),
('dJ4fLnQ2ZcR3', 9, '芸術家の選択'),
('dJ4fLnQ2ZcR3', 10, '残された絵'),
('bU4W2hM7x9D5', 1, '覚醒'),
('bU4W2hM7x9D5', 2, '宇宙への出発'),
('bU4W2hM7x9D5', 3, '異星の生命体'),
('bU4W2hM7x9D5', 4, '神殿の秘密'),
('bU4W2hM7x9D5', 5, 'クリスタルの探索'),
('bU4W2hM7x9D5', 6, '最後の決断'),
('bU4W2hM7x9D5', 7, '帰還と新たな旅立ち');

LOAD DATA INFILE '/docker-entrypoint-initdb.d/book_chapter_page_contents.csv'
INTO TABLE book_chapter_page_contents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`book_id`, `chapter_number`, `page_number`, `content`);

-- ブックマーク用のサブクエリでpage_content_idを取得してINSERT
INSERT INTO `bookmarks` (`user_id`, `page_content_id`, `note`)
SELECT 1, pc.id, 'もう一度読み直す' FROM book_chapter_page_contents pc WHERE pc.book_id = 'afcIMuetDuzj' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 3, pc.id, 'このページのフレーズが好き' FROM book_chapter_page_contents pc WHERE pc.book_id = 'afcIMuetDuzj' AND pc.chapter_number = 3 AND pc.page_number = 3
UNION ALL SELECT 4, pc.id, 'この感動を誰かに伝える' FROM book_chapter_page_contents pc WHERE pc.book_id = 'afcIMuetDuzj' AND pc.chapter_number = 6 AND pc.page_number = 4
UNION ALL SELECT 4, pc.id, 'わかりやすい解説だった' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 3, pc.id, 'よいね' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 1, pc.id, 'ドラゴン謎過ぎる' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 7, pc.id, 'かっこいい' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 8, pc.id, '神秘的' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 9, pc.id, '現代に存在したらどうなっていた' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 10, pc.id, '架空の生き物だがかっこいい' FROM book_chapter_page_contents pc WHERE pc.book_id = 'aBcDeFgHiJkL' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 1, pc.id, '春の訪れとともに' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 2, pc.id, 'インスピレーションの源' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 2 AND pc.page_number = 1
UNION ALL SELECT 3, pc.id, '出会いは運命？' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 3 AND pc.page_number = 1
UNION ALL SELECT 4, pc.id, '音楽か、恋か' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 4 AND pc.page_number = 1
UNION ALL SELECT 5, pc.id, 'ハヤトの描く世界' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 5 AND pc.page_number = 1
UNION ALL SELECT 6, pc.id, 'ツルの舞う夜' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 6 AND pc.page_number = 1
UNION ALL SELECT 7, pc.id, '衝突と迷い' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 7 AND pc.page_number = 1
UNION ALL SELECT 8, pc.id, 'ツルが導く答え' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 8 AND pc.page_number = 1
UNION ALL SELECT 9, pc.id, '愛と芸術の融合' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 9 AND pc.page_number = 1
UNION ALL SELECT 10, pc.id, '旋律は続く' FROM book_chapter_page_contents pc WHERE pc.book_id = 'Hh5r4Kj9Tb8v' AND pc.chapter_number = 10 AND pc.page_number = 1
UNION ALL SELECT 10, pc.id, '画家の謎の失踪' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 9, pc.id, '手がかりは絵の中に？' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 2 AND pc.page_number = 1
UNION ALL SELECT 8, pc.id, '探偵、動き出す' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 3 AND pc.page_number = 1
UNION ALL SELECT 7, pc.id, 'ヤギの行動がカギ？' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 4 AND pc.page_number = 1
UNION ALL SELECT 6, pc.id, '隠されたメッセージ' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 5 AND pc.page_number = 1
UNION ALL SELECT 5, pc.id, '山小屋の秘密' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 6 AND pc.page_number = 1
UNION ALL SELECT 4, pc.id, 'ヤギの導く先に…' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 7 AND pc.page_number = 1
UNION ALL SELECT 3, pc.id, '衝撃の発見！' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 8 AND pc.page_number = 1
UNION ALL SELECT 2, pc.id, '真実へのラストスパート' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 9 AND pc.page_number = 1
UNION ALL SELECT 1, pc.id, '最後の一筆' FROM book_chapter_page_contents pc WHERE pc.book_id = 'dJ4fLnQ2ZcR3' AND pc.chapter_number = 10 AND pc.page_number = 1
UNION ALL SELECT 6, pc.id, '華やかな幕開け' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 1 AND pc.page_number = 1
UNION ALL SELECT 7, pc.id, 'フラミンゴの羽の謎' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 2 AND pc.page_number = 1
UNION ALL SELECT 10, pc.id, '刑事ジェイク登場' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 3 AND pc.page_number = 1
UNION ALL SELECT 3, pc.id, 'セレブたちの仮面' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 4 AND pc.page_number = 1
UNION ALL SELECT 2, pc.id, '証言の食い違い' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 5 AND pc.page_number = 1
UNION ALL SELECT 1, pc.id, 'フラミンゴが見ていた？' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 6 AND pc.page_number = 1
UNION ALL SELECT 4, pc.id, '隠されたメッセージ' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 7 AND pc.page_number = 1
UNION ALL SELECT 5, pc.id, '疑惑のリゾートオーナー' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 8 AND pc.page_number = 1
UNION ALL SELECT 9, pc.id, '決定的な証拠' FROM book_chapter_page_contents pc WHERE pc.book_id = 'C4hD3jZ8rK6e' AND pc.chapter_number = 9 AND pc.page_number = 1
UNION ALL SELECT 8, pc.id, '迫られた選択' FROM book_chapter_page_contents pc WHERE pc.book_id = 'bU4W2hM7x9D5' AND pc.chapter_number = 3 AND pc.page_number = 1
UNION ALL SELECT 1, pc.id, '新たな発見' FROM book_chapter_page_contents pc WHERE pc.book_id = 'bU4W2hM7x9D5' AND pc.chapter_number = 4 AND pc.page_number = 1
UNION ALL SELECT 4, pc.id, '隠されたメッセージ' FROM book_chapter_page_contents pc WHERE pc.book_id = 'bU4W2hM7x9D5' AND pc.chapter_number = 5 AND pc.page_number = 1
UNION ALL SELECT 5, pc.id, '絶体絶命' FROM book_chapter_page_contents pc WHERE pc.book_id = 'bU4W2hM7x9D5' AND pc.chapter_number = 6 AND pc.page_number = 1
UNION ALL SELECT 9, pc.id, '銀河の旅' FROM book_chapter_page_contents pc WHERE pc.book_id = 'bU4W2hM7x9D5' AND pc.chapter_number = 7 AND pc.page_number = 1;

-- ================================================
-- パフォーマンス最適化のためのインデックス追加
-- ================================================

-- 書籍関連の基本インデックス
CREATE INDEX idx_books_deleted ON books(is_deleted);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_authors ON books(authors);
CREATE INDEX idx_books_isbn ON books(isbn);

-- 書籍の並び替え用インデックス
CREATE INDEX idx_books_popularity_desc ON books(popularity DESC, is_deleted);
CREATE INDEX idx_books_publication_date_desc ON books(publication_date DESC, is_deleted);
CREATE INDEX idx_books_average_rating_desc ON books(average_rating DESC, is_deleted);
CREATE INDEX idx_books_review_count_desc ON books(review_count DESC, is_deleted);

-- 書籍検索の複合インデックス
CREATE INDEX idx_books_search_combo ON books(title, authors, is_deleted);

-- ユーザー関連インデックス
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted ON users(is_deleted);

-- レビュー関連インデックス
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_book_id ON reviews(book_id);
CREATE INDEX idx_reviews_book_deleted ON reviews(book_id, is_deleted);
CREATE INDEX idx_reviews_user_book ON reviews(user_id, book_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_updated_at_desc ON reviews(updated_at DESC);
CREATE INDEX idx_reviews_created_at_desc ON reviews(created_at DESC);

-- 統計更新クエリ用の最適化インデックス
CREATE INDEX idx_reviews_stats ON reviews(book_id, is_deleted, rating);

-- お気に入り関連インデックス
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_book_id ON favorites(book_id);
CREATE INDEX idx_favorites_user_book ON favorites(user_id, book_id);
CREATE INDEX idx_favorites_user_deleted ON favorites(user_id, is_deleted);
CREATE INDEX idx_favorites_book_deleted ON favorites(book_id, is_deleted);
CREATE INDEX idx_favorites_updated_at_desc ON favorites(updated_at DESC);
CREATE INDEX idx_favorites_created_at_desc ON favorites(created_at DESC);

-- ブックマーク関連インデックス
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_page_content_id ON bookmarks(page_content_id);
CREATE INDEX idx_bookmarks_user_deleted ON bookmarks(user_id, is_deleted);
CREATE INDEX idx_bookmarks_updated_at_desc ON bookmarks(updated_at DESC);
CREATE INDEX idx_bookmarks_created_at_desc ON bookmarks(created_at DESC);

-- 書籍とジャンルの関係インデックス
CREATE INDEX idx_book_genres_book_id ON book_genres(book_id);
CREATE INDEX idx_book_genres_genre_id ON book_genres(genre_id);

-- ジャンル関連インデックス
CREATE INDEX idx_genres_name ON genres(name);
CREATE INDEX idx_genres_deleted ON genres(is_deleted);

-- ユーザーとロールの関係インデックス
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- ロール関連インデックス
CREATE INDEX idx_roles_name ON roles(name);
CREATE INDEX idx_roles_deleted ON roles(is_deleted);

-- 書籍章関連インデックス
CREATE INDEX idx_book_chapters_book_id ON book_chapters(book_id);
CREATE INDEX idx_book_chapters_deleted ON book_chapters(is_deleted);

-- 書籍ページコンテンツ関連インデックス
CREATE INDEX idx_book_chapter_page_contents_book_chapter ON book_chapter_page_contents(book_id, chapter_number);
CREATE INDEX idx_book_chapter_page_contents_deleted ON book_chapter_page_contents(is_deleted);

-- フルテキスト検索用インデックス（書籍の高度な検索機能用）
CREATE FULLTEXT INDEX idx_books_fulltext ON books(title, description, authors);

-- 評価点平均
UPDATE books b
SET average_rating = (
    SELECT COALESCE(ROUND(AVG(r.rating), 2), 0.00)
    FROM reviews r 
    WHERE r.book_id = b.id AND r.is_deleted = false
);

-- レビュー数
UPDATE books b
SET review_count = (
    SELECT COUNT(*)
    FROM reviews r 
    WHERE r.book_id = b.id AND r.is_deleted = false
);

-- 人気度（基本的な重み付きスコア: 平均点数 × log(レビュー数 + 1) × 20）
UPDATE books b
SET popularity = (
    CASE 
        WHEN b.review_count = 0 OR b.average_rating = 0.0 THEN 0.00
        ELSE ROUND(b.average_rating * LN(b.review_count + 1) * 20, 2)
    END
);

-- ================================================
-- パフォーマンス分析用のコメント
-- ================================================

/*
追加されたインデックスの効果:

1. 書籍検索の高速化:
   - タイトル検索: idx_books_title
   - 著者検索: idx_books_authors
   - 複合検索: idx_books_search_combo
   - フルテキスト検索: idx_books_fulltext

2. ソート性能の向上:
   - 人気順: idx_books_popularity_desc
   - 新着順: idx_books_publication_date_desc
   - 評価順: idx_books_average_rating_desc

3. ユーザー関連クエリの最適化:
   - マイレビュー取得: idx_reviews_user_id, idx_reviews_updated_at_desc
   - マイお気に入り取得: idx_favorites_user_id, idx_favorites_updated_at_desc
   - マイブックマーク取得: idx_bookmarks_user_id, idx_bookmarks_updated_at_desc

4. 統計更新処理の高速化:
   - 書籍統計更新: idx_reviews_stats
   - レビュー集計: idx_reviews_book_deleted

5. ジャンル検索の最適化:
   - ジャンル別書籍検索: idx_book_genres_genre_id, idx_book_genres_book_id

これらのインデックスにより、大量データでも高速なクエリ実行が可能になります。
*/