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
DROP TABLE IF EXISTS `my_lists`;


CREATE TABLE `books` (
  `id` VARCHAR(255) NOT NULL PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL DEFAULT '',
  `description` TEXT NOT NULL,
  `authors` VARCHAR(255) NOT NULL DEFAULT '',
  `publisher` VARCHAR(255) NOT NULL DEFAULT '',
  `published_date` DATE NOT NULL,
  `price` INT NOT NULL DEFAULT 0,
  `page_count` INT NOT NULL DEFAULT 0,
  `isbn` VARCHAR(255) NOT NULL DEFAULT '',
  `image_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE `genres` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0
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
  `email` VARCHAR(255) NOT NULL DEFAULT '',
  `password` VARCHAR(255) NOT NULL DEFAULT '',
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `avatar_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE `user_roles` (
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE
);

CREATE TABLE `reviews` (
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `comment` TEXT NOT NULL,
  `rating` DECIMAL(2, 1) CHECK (`rating` >= 0 AND `rating` <= 5),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `favorites` (
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `my_lists` (
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

-- データのロード
LOAD DATA INFILE '/docker-entrypoint-initdb.d/books.csv'
INTO TABLE books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`id`, `title`, `description`, `authors`, `publisher`, `published_date`, `price`, `page_count`, `isbn`, `image_url`);

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

INSERT INTO `users` (`name`, `email`, `password`, `avatar_url`) VALUES
('Lars', 'lars@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar01.png'),
('Nina', 'nina@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar02.png'),
('Paul', 'paul@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar03.png'),
('Julia', 'julia@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar04.png'),
('Lee', 'lee@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar05.png'),
('Lili', 'lili@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar06.png'),
('Steve', 'steve@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar07.png'),
('Anna', 'anna@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar08.png'),
('Law', 'law@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar09.png'),
('Alisa', 'alisa@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar10.png');

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

INSERT INTO `reviews` (`user_id`, `book_id`, `comment`, `rating`) VALUES
(1, 'afcIMuetDuzj', '知識の宝庫で、読み終える頃には少し賢くなった気がした。', 4.5),
(2, 'afcIMuetDuzj', '人生観が変わるほどの深い洞察が詰まっていました。', 3.0),
(3, 'afcIMuetDuzj', '読む手が止まらないほど引き込まれた。', 3.5),
(4, 'afcIMuetDuzj', '心に響く言葉が何度も胸を打った。', 5.0),
(5, 'afcIMuetDuzj', '言葉の美しさに何度もページをめくり直した。', 4.0),
(6, 'afcIMuetDuzj', '想像力をかき立てられる素晴らしいストーリーだった。', 4.5),
(7, 'afcIMuetDuzj', '感動しました。何度も読み直したいと思いました。', 3.0),
(8, 'afcIMuetDuzj', '登場人物に感情移入しすぎて泣いてしまった。', 5.0),
(9, 'afcIMuetDuzj', '終わるのが惜しいほど楽しかった。', 4.5),
(10, 'afcIMuetDuzj', '感動的な結末に、読後の余韻が心地よかった。', 3.5),
(1, '9UizZw491wye', '読み進むにつれドンドン引き込まれていきました。', 3.5),
(2, '9UizZw491wye', '首を長くして待っていました。非常に楽しかったです。', 3.0),
(3, '9UizZw491wye', '読んでいる間、時間を忘れるほど夢中になれました。', 3.0),
(4, '9UizZw491wye', '物語の展開が巧妙で、予想を超える展開が続いて面白かったです。', 3.0),
(1, 'pDYIwtdahwkp', '私もこんな経験をしたいと思いました。', 5.0);

INSERT INTO `favorites` (`user_id`, `book_id`) VALUES
(4, 'afcIMuetDuzj'),
(4, 'pDYIwtdahwkp'),
(3, '9UizZw491wye'),
(3, 'ln5NiMJq02V7');

INSERT INTO `my_lists` (`user_id`, `book_id`) VALUES
(4, '3BndPAiEFnjB'),
(4, '3gNJnRcrwrUH'),
(3, 'v21pjIlzDua1');