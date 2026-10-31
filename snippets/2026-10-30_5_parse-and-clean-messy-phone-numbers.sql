-- Title: Parse and Clean Messy Phone Numbers

-- Business Question: Extract and standardize phone numbers from a contact field
-- that contains mixed formats, extra spaces, and special characters.
-- Technique: String manipulation using TRIM, REPLACE, SUBSTR, and pattern matching.

CREATE TABLE contacts (
  id INTEGER PRIMARY KEY,
  contact_name TEXT,
  phone_raw TEXT
);

INSERT INTO contacts (contact_name, phone_raw) VALUES
  ('Alice Smith', '(555) 123-4567'),
  ('Bob Johnson', '555-123-4568'),
  ('Charlie Brown', '555.123.4569'),
  ('Diana Prince', '  (555)1234570  '),
  ('Eve Wilson', '555 123 4571'),
  ('Frank Miller', '+1-555-123-4572'),
  ('Grace Lee', '(555)  123  -  4573'),
  ('Henry Davis', '5551234574'),
  ('Iris Chen', '   555-123-4575   '),
  ('Jack White', '+1 (555) 123-4576');

WITH cleaned_phones AS (
  SELECT
    id,
    contact_name,
    phone_raw,
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(phone_raw, '+1', ''),
                '(',
                ''
              ),
              ')',
              ''
            ),
            '-',
            ''
          ),
          '.',
          ''
        ),
        ' ',
        ''
      )
    ) AS phone_digits,
    LENGTH(
      TRIM(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(phone_raw, '+1', ''),
                  '(',
                  ''
                ),
                ')',
                ''
              ),
              '-',
              ''
            ),
            '.',
            ''
          ),
          ' ',
          ''
        )
      )
    ) AS digit_count
  FROM contacts
)
SELECT
  id,
  contact_name,
  phone_raw,
  phone_digits AS cleaned_phone,
  CASE
    WHEN digit_count = 10 THEN '(' || SUBSTR(phone_digits, 1, 3) || ') ' || SUBSTR(phone_digits, 4, 3) || '-' || SUBSTR(phone_digits, 7, 4)
    ELSE 'INVALID'
  END AS formatted_phone,
  CASE WHEN digit_count = 10 THEN 'Valid' ELSE 'Invalid' END AS validation_status
FROM cleaned_phones
ORDER BY id;

-- Result (verified in SQLite):
-- id | contact_name | phone_raw | cleaned_phone | formatted_phone | validation_status
-- 1 | Alice Smith | (555) 123-4567 | 5551234567 | (555) 123-4567 | Valid
-- 2 | Bob Johnson | 555-123-4568 | 5551234568 | (555) 123-4568 | Valid
-- 3 | Charlie Brown | 555.123.4569 | 5551234569 | (555) 123-4569 | Valid
-- 4 | Diana Prince |   (555)1234570   | 5551234570 | (555) 123-4570 | Valid
-- 5 | Eve Wilson | 555 123 4571 | 5551234571 | (555) 123-4571 | Valid
-- 6 | Frank Miller | +1-555-123-4572 | 5551234572 | (555) 123-4572 | Valid
-- 7 | Grace Lee | (555)  123  -  4573 | 5551234573 | (555) 123-4573 | Valid
-- 8 | Henry Davis | 5551234574 | 5551234574 | (555) 123-4574 | Valid
-- 9 | Iris Chen |    555-123-4575    | 5551234575 | (555) 123-4575 | Valid
-- 10 | Jack White | +1 (555) 123-4576 | 5551234576 | (555) 123-4576 | Valid
