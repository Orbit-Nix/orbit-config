CREATE TABLE IF NOT EXISTS sogo_users (
    c_uid VARCHAR(255) PRIMARY KEY,
    c_name VARCHAR(255),
    c_password VARCHAR(255),
    c_cn VARCHAR(255),
    mail VARCHAR(255)
);

INSERT INTO sogo_users (c_uid, c_name, c_password, c_cn, mail)
VALUES ('hi@muvex.dev', 'hi@muvex.dev', 'MusaMail2026!', 'Musa Murad', 'hi@muvex.dev')
ON CONFLICT (c_uid) DO NOTHING;
