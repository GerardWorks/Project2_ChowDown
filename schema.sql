CREATE TABLE users(
  id SERIAL4 PRIMARY KEY,
  first_name VARCHAR(200) NOT NULL,
  last_name VARCHAR(200) NOT NULL,
  date_of_birth VARCHAR(200) NOT NULL,
  email VARCHAR(400) NOT NULL,
  mobile VARCHAR(200) NOT NULL,
  address VARCHAR(400) NOT NULL,
  suburb VARCHAR(400) NOT NULL,
  city VARCHAR(400) NOT NULL,
  password_digest VARCHAR(400) NOT NULL,
  points INTEGER NOT NULL
);

CREATE TABLE restaurants(
  id SERIAL4 PRIMARY KEY,
  first_name VARCHAR(200) NOT NULL,
  last_name VARCHAR(200) NOT NULL,
  email VARCHAR(400) NOT NULL,
  mobile VARCHAR(200) NOT NULL,
  restaurant_name VARCHAR(400) NOT NULL,
  address VARCHAR(400) NOT NULL,
  suburb VARCHAR(400) NOT NULL,
  city VARCHAR(400) NOT NULL,
  password_digest VARCHAR(400) NOT NULL
);

CREATE TABLE comments(
  id SERIAL4 PRIMARY KEY,
  body VARCHAR(500),
  rating INTEGER,
  restaurant_id INTEGER,
  user_id INTEGER
);

CREATE TABLE invitations(
  id SERIAL4 PRIMARY KEY,
  invite VARCHAR(1000) NOT NULL,
  user_id INTEGER NOT NULL,
  restaurant_id INTEGER NOT NULL,
  time_start VARCHAR(200) NOT NULL,
  time_end VARCHAR(200) NOT NULL,
  discount_code_id INTEGER NOT NULL
);

CREATE TABLE open_promos(
  id SERIAL4 PRIMARY KEY,
  restaurant_id INTEGER NOT NULL,
  time_start VARCHAR(200) NOT NULL,
  time_end VARCHAR(200) NOT NULL,
  promotion_headline VARCHAR(200) NOT NULL,
  promotion VARCHAR(2000) NOT NULL
);

CREATE TABLE wish_lists(
  id SERIAL4 PRIMARY KEY,
  restaurant_id INTEGER,
  user_id INTEGER,
  time_start VARCHAR(200) NOT NULL,
  time_end VARCHAR(200) NOT NULL
);

CREATE TABLE discount_codes(
  id SERIAL4 PRIMARY KEY,
  restaurant_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  code INTEGER NOT NULL,
  claim VARCHAR(200) NOT NULL
);

CREATE TABLE bookings(
  id SERIAL4 PRIMARY KEY,
  restaurant_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  code_id INTEGER,
  booking_date VARCHAR(200) NOT NULL,
  booking_time VARCHAR(200) NOT NULL,
  confirmation VARCHAR(200) NOT NULL,
  person INTEGER NOT NULL
);
