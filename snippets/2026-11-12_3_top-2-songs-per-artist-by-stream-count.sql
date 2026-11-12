-- Title: Top 2 Songs Per Artist by Stream Count

-- Business Question: For each music artist, find their top 2 most-streamed songs.
-- Technique: Use window function ROW_NUMBER() to rank songs within each artist group,
-- then filter for rank <= 2 to get the top N rows per group.

CREATE TABLE songs (
  song_id INTEGER PRIMARY KEY,
  song_name TEXT NOT NULL,
  artist_id INTEGER NOT NULL,
  artist_name TEXT NOT NULL,
  stream_count INTEGER NOT NULL,
  release_year INTEGER
);

INSERT INTO songs (song_id, song_name, artist_id, artist_name, stream_count, release_year)
VALUES
  (1, 'Midnight Dreams', 101, 'Luna Echo', 5200000, 2022),
  (2, 'Starlight Path', 101, 'Luna Echo', 3800000, 2021),
  (3, 'Whispered Hope', 101, 'Luna Echo', 2100000, 2023),
  (4, 'Electric Pulse', 102, 'Neon Vibes', 6100000, 2023),
  (5, 'Neon Nights', 102, 'Neon Vibes', 5900000, 2022),
  (6, 'City Lights', 102, 'Neon Vibes', 4200000, 2021),
  (7, 'Ocean Breeze', 103, 'Coastal Harmony', 2800000, 2023),
  (8, 'Wave Rider', 103, 'Coastal Harmony', 2400000, 2022),
  (9, 'Sandy Shores', 103, 'Coastal Harmony', 1900000, 2021),
  (10, 'Digital Rain', 104, 'Synth Masters', 7100000, 2023),
  (11, 'Chrome Soul', 104, 'Synth Masters', 6800000, 2022),
  (12, 'Glass Heart', 104, 'Synth Masters', 5500000, 2021);

WITH ranked_songs AS (
  SELECT
    artist_name,
    song_name,
    stream_count,
    release_year,
    ROW_NUMBER() OVER (PARTITION BY artist_id ORDER BY stream_count DESC) AS rank
  FROM songs
)
SELECT
  artist_name,
  song_name,
  stream_count,
  release_year,
  rank
FROM ranked_songs
WHERE rank <= 2
ORDER BY artist_name, rank;

-- Result (verified in SQLite):
-- artist_name | song_name | stream_count | release_year | rank
-- Coastal Harmony | Ocean Breeze | 2800000 | 2023 | 1
-- Coastal Harmony | Wave Rider | 2400000 | 2022 | 2
-- Luna Echo | Midnight Dreams | 5200000 | 2022 | 1
-- Luna Echo | Starlight Path | 3800000 | 2021 | 2
-- Neon Vibes | Electric Pulse | 6100000 | 2023 | 1
-- Neon Vibes | Neon Nights | 5900000 | 2022 | 2
-- Synth Masters | Digital Rain | 7100000 | 2023 | 1
-- Synth Masters | Chrome Soul | 6800000 | 2022 | 2
