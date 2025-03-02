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
DROP TABLE IF EXISTS `book_content_pages`;


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
  `avatar_url` VARCHAR(255) DEFAULT NULL,
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
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`user_id`, `book_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `bookmarks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `book_id` VARCHAR(255) NOT NULL,
  `chapter_number` INT NOT NULL,
  `page_number` INT NOT NULL,
  `note` VARCHAR(1000) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (`user_id`, `book_id`, `chapter_number`, `page_number`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `book_chapters` (
  `book_id` VARCHAR(255) NOT NULL,
  `chapter_number` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`book_id`, `chapter_number`),
  FOREIGN KEY (`book_id`) REFERENCES `books`(`id`) ON DELETE CASCADE
);

CREATE TABLE `book_content_pages` (
  `book_id` VARCHAR(255) NOT NULL,
  `chapter_number` INT NOT NULL,
  `page_number` INT NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`book_id`, `chapter_number`, `page_number`),
  FOREIGN KEY (`book_id`, `chapter_number`) REFERENCES `book_chapters`(`book_id`, `chapter_number`) ON DELETE CASCADE
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
('Nina', 'nina@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar40.png'),
('Paul', 'paul@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar09.png'),
('Julia', 'julia@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar04.png'),
('Eddy', 'lee@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar05.png'),
('Lili', 'lili@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar28.png'),
('Steve', 'steve@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar37.png'),
('Anna', 'anna@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar12.png'),
('Law', 'law@gmail.com', '$2a$10$E7FzFP73ImXXFHUmUUmXtuDrJnp0gZ3Zb3XJluLEW7tfnVmh5FLwC', 'https://localhost/images/avatars/avatar07.png'),
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
(5, 'afcIMuetDuzj', '言葉の美しさに何度もページをめくり直した。', 3.5),
(6, 'afcIMuetDuzj', '想像力をかき立てられる素晴らしいストーリーだった。', 3.5),
(7, 'afcIMuetDuzj', '感動しました。何度も読み直したいと思いました。', 3.0),
(8, 'afcIMuetDuzj', '登場人物に感情移入しすぎて泣いてしまった。', 5.0),
(9, 'afcIMuetDuzj', '終わるのが惜しいほど楽しかった。', 4.5),
(10, 'afcIMuetDuzj', '感動的な結末に、読後の余韻が心地よかった。', 3.5),
(1, '9UizZw491wye', '読み進むにつれドンドン引き込まれていきました。', 3.5),
(2, '9UizZw491wye', '首を長くして待っていました。非常に楽しかったです。', 3.0),
(3, '9UizZw491wye', '読んでいる間、時間を忘れるほど夢中になれました。', 3.0),
(4, '9UizZw491wye', '物語の展開が巧妙で、予想を超える展開が続いて面白かったです。', 3.0),
(1, 'pDYIwtdahwkp', '私もこんな経験をしたいと思いました。', 5.0),
(1, 'aBcDeFgHiJkL', 'ドラゴン好きにはたまらない一冊！神話や伝説だけでなく、歴史的な背景や科学的視点からの考察もあり、読み応え抜群。イラストも豊富で、ページをめくるたびにワクワクしました。' ,5.0),
(2, 'aBcDeFgHiJkL', '地域ごとのドラゴンの違いが詳しく解説されていて、とても興味深かったです。もう少し現代のフィクション作品に登場するドラゴンの分析もあると、さらに楽しめたかも。' ,4.5),
(3, 'aBcDeFgHiJkL', '図鑑としての完成度が高く、資料としても役立つ内容でした。ただ、一部の科学的な考察は少し専門的すぎて、難しく感じる部分もありました。' ,4.5),
(4, 'aBcDeFgHiJkL', 'ドラゴンの文化的意義を掘り下げた内容がとても面白かった！西洋と東洋のドラゴンの違いがわかりやすく、歴史を学びながら楽しめました。' ,4.0),
(5, 'aBcDeFgHiJkL', 'ビジュアルがとても美しく、眺めるだけでも価値のある本。ただ、もう少しストーリー仕立てで読みやすい構成だったら、もっと楽しく読めたかもしれません。' ,3.5),
(7, 'aBcDeFgHiJkL', '神話や伝承の部分が特に面白く、各地域ごとのドラゴンの違いを比較できるのが良かった！ファンタジー好きなら楽しめると思います。' ,4.0),
(8, 'aBcDeFgHiJkL', '図鑑というよりも資料集に近い印象。もう少し物語的なエピソードがあると、より楽しめたかもしれません。' ,3.5),
(9, 'aBcDeFgHiJkL', '図鑑としての内容はしっかりしているけど、専門的すぎて途中で飽きてしまった。もう少し初心者向けの解説があると、もっと読みやすかったかも。' ,2.5),
(10, 'aBcDeFgHiJkL', '伝説と科学の両面からドラゴンを解説していて、知的好奇心を刺激されました！ドラゴンのリアルな生態を考察する部分が特に面白かったです。' ,5.0),
(1, 'C4hD3jZ8rK6e', '最後まで予測できない展開に引き込まれました！リゾートの華やかな雰囲気と不穏な空気のコントラストが絶妙で、一気読みしてしまいました。', 5.0),
(2, 'C4hD3jZ8rK6e', 'ミステリーとしての完成度が高く、伏線の回収も見事。特にフラミンゴの羽が象徴する意味が明らかになるシーンにはゾクッとしました！', 4.5),
(3, 'C4hD3jZ8rK6e', 'ジェイク刑事のキャラクターが魅力的で、彼の過去が事件とどう絡むのかも見どころ。もう少し犯人の動機が深掘りされていたら、もっと楽しめたかも。', 4.0),
(4, 'C4hD3jZ8rK6e', 'サスペンス要素と心理描写が絶妙に絡み合い、最後のどんでん返しには驚かされました！読後も余韻が残る素晴らしい作品です。', 5.0),
(5, 'C4hD3jZ8rK6e', '事件の舞台となるリゾートの描写が美しく、雰囲気は抜群。ただ、途中で少し展開が冗長に感じる部分もありました。', 3.5),
(6, 'C4hD3jZ8rK6e', 'ミステリーとしては悪くないけど、登場人物の背景がもう少し掘り下げられていると感情移入しやすかったかも。', 3.0),
(7, 'C4hD3jZ8rK6e', 'フラミンゴの羽の謎が解明される過程が面白かった！セレブたちの秘密が絡むことで、単なる殺人事件以上の深みが出ていたと思います。', 4.0),
(8, 'C4hD3jZ8rK6e', '期待していたほどの緊張感がなく、ストーリーの進行が少し遅く感じました。後半の展開は良かったので、序盤がもう少しテンポよければ…。', 2.5),
(9, 'C4hD3jZ8rK6e', '一見バラバラに見えた手がかりが、最後にひとつの真実へと収束する流れが見事。フラミンゴの羽に隠された意味が明かされた瞬間は鳥肌もの！', 4.5),
(1, 'Hh5r4Kj9Tb8v', '音楽と自然、そして恋愛が美しく絡み合った作品でした。ツルの舞から生まれる旋律の描写が繊細で、読んでいるだけで音が聞こえてくるようでした。', 5.0),
(2, 'Hh5r4Kj9Tb8v', 'サキの芸術への情熱とハヤトとの恋の狭間で揺れる心情が丁寧に描かれていて、とても共感できました。ラストの余韻が素晴らしかったです。', 5.0),
(3, 'Hh5r4Kj9Tb8v', 'ツルの美しさと音楽の表現が見事でした。ただ、恋愛パートがもう少し深掘りされていたら、もっと感情移入できたかもしれません。', 4.5),
(4, 'Hh5r4Kj9Tb8v', '自然の美しさと芸術の力が融合した、心に響く物語。サキの成長が丁寧に描かれていて、彼女の決断に胸が熱くなりました。', 5.0),
(7, 'Hh5r4Kj9Tb8v', 'ツルの舞からインスピレーションを得るという設定がユニークで印象的でした。芸術に生きる人の葛藤がリアルに描かれていたのが良かったです。', 4.5),
(9, 'Hh5r4Kj9Tb8v', '音楽と恋愛のバランスが絶妙で、読んでいて心が温かくなりました。ツルの存在が象徴的で、幻想的な雰囲気を醸し出していたのも素敵。', 5.0),
(10, 'Hh5r4Kj9Tb8v', '芸術家としてのサキの成長が描かれているのは良かったけど、ハヤトのキャラクターがもう少し掘り下げられていたら、恋愛要素にももっと深みが出たと思う。', 4.0),
(2, 'dJ4fLnQ2ZcR3', '画家の残した絵が謎解きの手がかりになっているのが面白かった！ヤギが単なるペットではなく、物語の核心に関わる存在だったのが意外で良かったです。', 4.5),
(3, 'dJ4fLnQ2ZcR3', '美術ミステリーとして楽しめる一冊。もう少し探偵のキャラクターに深みがあると、もっと感情移入できたかも。', 4.0),
(4, 'dJ4fLnQ2ZcR3', 'アイデアは魅力的だけど、途中の展開がややゆっくりで、もう少しテンポよく進んでほしかった。ただ、結末には驚かされました！', 3.5),
(5, 'dJ4fLnQ2ZcR3', 'ミステリーとしては面白かったけど、美術の専門的な部分が多くて少し難しく感じるところも。もう少しライトな読み口だと良かったかも。', 3.0),
(6, 'dJ4fLnQ2ZcR3', 'ヤギがここまでストーリーに絡んでくるとは思わなかった！芸術と動物を絡めたユニークな設定が新鮮で、非常に楽しめました。', 5.0),
(7, 'dJ4fLnQ2ZcR3', '絵画に込められた意味を探るミステリーとして秀逸。ヤギの行動に注目すると、序盤からヒントが散りばめられていて、再読したくなる作品でした。', 4.0),
(8, 'dJ4fLnQ2ZcR3', '画家の失踪の謎には興味を惹かれたけど、全体的に展開がゆったりしていて、もう少し緊迫感が欲しかった。', 2.5),
(10, 'dJ4fLnQ2ZcR3', '山小屋の描写や画家の背景など、雰囲気は抜群。ただ、結末が少しあっさりしていて、もう少し余韻が欲しかった。', 3.5),
(1, 'bU4W2hM7x9D5', '宙を旅するマンドリルという設定が斬新で、ワクワクしながら読み進めました！未知の生物との出会いがスリリングで、最後まで飽きさせません。', 5.0),
(2, 'bU4W2hM7x9D5', 'マンドリルたちの個性がしっかり描かれていて、仲間との絆に感動しました。もう少し科学的な説明があると、さらにリアリティが増したかも？', 4.5),
(3, 'bU4W2hM7x9D5', '宇宙探検と友情の要素がバランスよく描かれていて楽しかった！特に異星人とのやりとりがユーモラスで、読んでいてニヤリとしてしまう場面も。', 4.5),
(4, 'bU4W2hM7x9D5', 'まさかマンドリルが宇宙に行くなんて…！設定の意外性だけでなく、ストーリーも練られていて、熱い冒険譚として大満足の一冊でした。', 5.0),
(5, 'bU4W2hM7x9D5', 'ストーリーは面白かったけど、もう少しキャラクターの掘り下げが欲しかったかも。特に敵キャラの背景が薄く感じました。', 3.5),
(6, 'bU4W2hM7x9D5', '設定はユニークだけど、展開が王道すぎて予想の範囲内だったかな。でも、宇宙の描写は美しくて雰囲気は最高でした！', 3.0),
(7, 'bU4W2hM7x9D5', 'SFとしての魅力もしっかりありつつ、マンドリルたちのユーモラスな掛け合いが楽しかった！続編があるならぜひ読みたいです。', 4.5),
(8, 'bU4W2hM7x9D5', 'マンドリルという設定がユニークすぎて、個人的には感情移入が難しかった…。でも、宇宙の冒険シーンは迫力があって良かったです。', 2.5),
(9, 'bU4W2hM7x9D5', '宇宙の神秘と冒険のワクワク感がたっぷり詰まった一冊！マンドリルたちの成長も丁寧に描かれていて、読み終わった後に爽やかな余韻が残りました。', 5.0),
(10, 'bU4W2hM7x9D5', 'アイデアは素晴らしいけど、物語の後半が少し駆け足に感じました。もっとじっくり惑星探査のシーンを描いてほしかったです。', 3.5);

INSERT INTO `favorites` (`user_id`, `book_id`) VALUES
(1, 'afcIMuetDuzj'),
(2, 'afcIMuetDuzj'),
(3, 'afcIMuetDuzj'),
(4, 'afcIMuetDuzj'),
(4, 'pDYIwtdahwkp'),
(5, 'pDYIwtdahwkp'),
(6, 'pDYIwtdahwkp'),
(3, '9UizZw491wye'),
(1, 'aBcDeFgHiJkL'),
(4, 'aBcDeFgHiJkL'),
(5, 'aBcDeFgHiJkL'),
(7, 'aBcDeFgHiJkL'),
(8, 'aBcDeFgHiJkL'),
(10, 'aBcDeFgHiJkL'),
(2, 'C4hD3jZ8rK6e'),
(4, 'C4hD3jZ8rK6e'),
(5, 'C4hD3jZ8rK6e'),
(6, 'C4hD3jZ8rK6e'),
(9, 'C4hD3jZ8rK6e'),
(1, 'Hh5r4Kj9Tb8v'),
(2, 'Hh5r4Kj9Tb8v'),
(3, 'Hh5r4Kj9Tb8v'),
(4, 'Hh5r4Kj9Tb8v'),
(5, 'Hh5r4Kj9Tb8v'),
(6, 'Hh5r4Kj9Tb8v'),
(7, 'dJ4fLnQ2ZcR3'),
(8, 'dJ4fLnQ2ZcR3'),
(9, 'dJ4fLnQ2ZcR3'),
(10, 'dJ4fLnQ2ZcR3'),
(3, 'ln5NiMJq02V7');

INSERT INTO `bookmarks` (`user_id`, `book_id`, `chapter_number`, `page_number`, `note`) VALUES
(1, 'afcIMuetDuzj', 1, 1, 'もう一度読み直す'),
(3, 'afcIMuetDuzj', 3, 3, 'このページのフレーズが好き'),
(4, 'afcIMuetDuzj', 6, 4, 'この感動を誰かに伝える'),
(4, 'aBcDeFgHiJkL', 1, 1, 'わかりやすい解説だった'),
(3, 'aBcDeFgHiJkL', 1, 1, 'よいね'),
(1, 'aBcDeFgHiJkL', 1, 1, 'ドラゴン謎過ぎる'),
(7, 'aBcDeFgHiJkL', 1, 1, 'かっこいい'),
(8, 'aBcDeFgHiJkL', 1, 1, '神秘的'),
(9, 'aBcDeFgHiJkL', 1, 1, '現代に存在したらどうなっていた'),
(10, 'aBcDeFgHiJkL', 1, 1, '架空の生き物だがかっこいい'),
(1, 'Hh5r4Kj9Tb8v', 1, 1, '春の訪れとともに'),
(2, 'Hh5r4Kj9Tb8v', 2, 1, 'インスピレーションの源'),
(3, 'Hh5r4Kj9Tb8v', 3, 1, '出会いは運命？'),
(4, 'Hh5r4Kj9Tb8v', 4, 1, '音楽か、恋か'),
(5, 'Hh5r4Kj9Tb8v', 5, 1, 'ハヤトの描く世界'),
(6, 'Hh5r4Kj9Tb8v', 6, 1, 'ツルの舞う夜'),
(7, 'Hh5r4Kj9Tb8v', 7, 1, '衝突と迷い'),
(8, 'Hh5r4Kj9Tb8v', 8, 1, 'ツルが導く答え'),
(9, 'Hh5r4Kj9Tb8v', 9, 1, '愛と芸術の融合'),
(10, 'Hh5r4Kj9Tb8v', 10, 1, '旋律は続く'),
(10, 'dJ4fLnQ2ZcR3', 1, 1, '画家の謎の失踪'),
(9, 'dJ4fLnQ2ZcR3', 2, 1, '手がかりは絵の中に？'),
(8, 'dJ4fLnQ2ZcR3', 3, 1, '探偵、動き出す'),
(7, 'dJ4fLnQ2ZcR3', 4, 1, 'ヤギの行動がカギ？'),
(6, 'dJ4fLnQ2ZcR3', 5, 1, '隠されたメッセージ'),
(5, 'dJ4fLnQ2ZcR3', 6, 1, '山小屋の秘密'),
(4, 'dJ4fLnQ2ZcR3', 7, 1, 'ヤギの導く先に…'),
(3, 'dJ4fLnQ2ZcR3', 8, 1, '衝撃の発見！'),
(2, 'dJ4fLnQ2ZcR3', 9, 1, '真実へのラストスパート'),
(1, 'dJ4fLnQ2ZcR3', 10, 1, '最後の一筆'),
(6, 'C4hD3jZ8rK6e', 1, 1, '華やかな幕開け'),
(7, 'C4hD3jZ8rK6e', 2, 1, 'フラミンゴの羽の謎'),
(10, 'C4hD3jZ8rK6e', 3, 1, '刑事ジェイク登場'),
(3, 'C4hD3jZ8rK6e', 4, 1, 'セレブたちの仮面'),
(2, 'C4hD3jZ8rK6e', 5, 1, '証言の食い違い'),
(1, 'C4hD3jZ8rK6e', 6, 1, 'フラミンゴが見ていた？'),
(4, 'C4hD3jZ8rK6e', 7, 1, '隠されたメッセージ'),
(5, 'C4hD3jZ8rK6e', 8, 1, '疑惑のリゾートオーナー'),
(9, 'C4hD3jZ8rK6e', 9, 1, '決定的な証拠'),
(8, 'bU4W2hM7x9D5', 3, 1, '迫られた選択'),
(1, 'bU4W2hM7x9D5', 4, 1, '新たな発見'),
(4, 'bU4W2hM7x9D5', 5, 1, '隠されたメッセージ'),
(5, 'bU4W2hM7x9D5', 6, 1, '絶体絶命'),
(9, 'bU4W2hM7x9D5', 7, 1, '銀河の旅');

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

LOAD DATA INFILE '/docker-entrypoint-initdb.d/book_content_pages.csv'
INTO TABLE book_content_pages
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(`book_id`, `chapter_number`, `page_number`, `content`);