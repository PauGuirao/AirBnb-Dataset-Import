-- IMPORTACIO DE DADES

DROP TABLE IF EXISTS imp_reviews;
CREATE TABLE imp_reviews(
	id INT,
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	street VARCHAR(255),
	neighbourhood_cleansed VARCHAR(255),
	city VARCHAR(255),
	date_review DATE,
	reviewer_id INT,
	reviewer_name VARCHAR(255),
	comments TEXT
);

COPY imp_reviews FROM 'C:\Users\Public\review.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS imp_hosts;
CREATE TABLE imp_hosts(
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	host_id INT,
	host_url VARCHAR(255),
	host_name VARCHAR(255),
	host_since DATE,
	host_about TEXT,
	host_response_time VARCHAR(255),
	host_response_rate VARCHAR(255),
	host_is_superhost CHAR(1),
	host_picture_url VARCHAR(255),
	host_listings_count INT,
	host_verifications VARCHAR(255),
	host_identity_verified VARCHAR(255)
);

COPY imp_hosts FROM 'C:\Users\Public\hosts.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS imp_apartments;
CREATE TABLE imp_apartments(
	id INT,
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	street VARCHAR(255),
	neighbourhood_cleansed VARCHAR(255),
	city VARCHAR(255),
	state VARCHAR(255),
	zipcode VARCHAR(255),
	country_code VARCHAR(255),
	country VARCHAR(255),
	property_type VARCHAR(255),
	accommodates INT,
	bathrooms FLOAT,
	bedrooms INT,
	beds INT,
	amenities TEXT,
	square_feet INT,
	price VARCHAR(255),
	weekly_price VARCHAR(255),
	monthly_price VARCHAR(255),
	security_deposit VARCHAR(255),
	cleaning_fee VARCHAR(255),
	minimum_nights INT,
	maximum_nights INT
);

COPY imp_apartments FROM 'C:\Users\Public\apartments.csv' DELIMITER ',' CSV HEADER;

UPDATE imp_apartments
SET state = ''
WHERE state IS NULL;

UPDATE imp_apartments
SET price = RIGHT(TRANSLATE(price, ',', ''),-1);

UPDATE imp_apartments
SET weekly_price = RIGHT(TRANSLATE(weekly_price, ',', ''),-1);

UPDATE imp_apartments
SET monthly_price = RIGHT(TRANSLATE(monthly_price, ',', ''),-1);

UPDATE imp_apartments
SET security_deposit = RIGHT(TRANSLATE(security_deposit, ',', ''),-1);

UPDATE imp_apartments
SET cleaning_fee = RIGHT(TRANSLATE(cleaning_fee, ',', ''),-1);

ALTER TABLE imp_apartments
ALTER COLUMN price TYPE FLOAT USING price::FLOAT;

ALTER TABLE imp_apartments
ALTER COLUMN weekly_price TYPE FLOAT USING weekly_price::FLOAT;

ALTER TABLE imp_apartments
ALTER COLUMN monthly_price TYPE FLOAT USING monthly_price::FLOAT;

ALTER TABLE imp_apartments
ALTER COLUMN security_deposit TYPE FLOAT USING security_deposit::FLOAT;

ALTER TABLE imp_apartments
ALTER COLUMN cleaning_fee TYPE FLOAT USING cleaning_fee::FLOAT;

-- INSERCIO DE DADES

-- Insert de Country
INSERT INTO Country (Country_code, Country_name)
SELECT DISTINCT country_code, country
FROM imp_apartments;

SELECT * FROM Country;

-- Insert de State
INSERT INTO State (State_code,Country_code)
SELECT DISTINCT state,country_code
FROM imp_apartments;

SELECT * FROM State;

-- Insert de Location
INSERT INTO Location (street_name, neighbourhood_name, city_name, state_code)
SELECT DISTINCT street, neighbourhood_cleansed, city, state
FROM imp_apartments;

SELECT * FROM Location;

-- Insert de Image
INSERT INTO Image(Url_image)
SELECT DISTINCT picture_url
FROM imp_reviews;

INSERT INTO Image (Url_image)
SELECT DISTINCT picture_url
FROM imp_apartments
WHERE picture_url NOT IN (SELECT Url_image FROM Image);

INSERT INTO Image (Url_image)
SELECT DISTINCT host_picture_url
FROM imp_hosts
WHERE host_picture_url NOT IN (SELECT Url_image FROM Image);

SELECT * FROM Image;

-- Insert de User
INSERT INTO "User" (ID_user, User_name)
SELECT DISTINCT host_id, host_name
FROM imp_hosts;

INSERT INTO "User" (ID_user, User_name)
SELECT DISTINCT ir.reviewer_id, ir.reviewer_name
FROM imp_reviews AS ir
WHERE ir.reviewer_id NOT IN (SELECT ID_user FROM "User");

UPDATE "User"
SET ID_image = i.id_image
FROM Image AS i, imp_hosts AS ih
WHERE i.url_image = ih.host_picture_url AND ih.host_id = ID_user;

SELECT * FROM "User";

-- Insert de Host
INSERT INTO Host (ID_host, Host_url, Host_since, Host_about, Host_response_time, Host_response_rate, Host_is_superhost, Host_listings_count, Host_identity_verified)
SELECT DISTINCT host_id, h.host_url, h.host_since, h.host_about, h.host_response_time, h.host_response_rate, h.host_is_superhost, h.host_listings_count, h.host_identity_verified
FROM imp_hosts AS h;

SELECT * FROM Host;

-- Insert de Verifications
DROP TABLE IF EXISTS Verifications_aux CASCADE;
CREATE TABLE Verifications_aux (
	ID_verification SERIAL,
	Verification_name VARCHAR(255),
  Host_url VARCHAR(255),
	PRIMARY KEY (ID_verification)
);

INSERT INTO Verifications_aux (Verification_name, Host_url)
SELECT regexp_split_to_table(h.host_verifications, ','), h.host_url
FROM imp_hosts AS h;

UPDATE Verifications_aux
SET Verification_name = REPLACE(Verification_name, ' ', '');

UPDATE Verifications_aux
SET Verification_name = REPLACE(Verification_name, '''', '');

UPDATE Verifications_aux
SET Verification_name = REPLACE(Verification_name, '[', '');

UPDATE Verifications_aux
SET Verification_name = REPLACE(Verification_name, ']', '');

INSERT INTO Verifications (Verification_name)
SELECT DISTINCT Verification_name
FROM Verifications_aux;

SELECT * FROM Verifications;

-- Insert de hostVerifications
INSERT INTO hostVerifications (ID_host, ID_verification)
SELECT h.ID_host, v.ID_verification
FROM Host AS h, Verifications AS v, Verifications_aux AS va
WHERE h.host_url = va.Host_url AND v.Verification_name = va.Verification_name
GROUP BY h.ID_host, v.ID_verification;

DROP TABLE IF EXISTS Verifications_aux CASCADE;

SELECT * FROM hostVerifications;

-- Insert de Apartment
INSERT INTO Apartment (id_apartment, Apartment_name, Description, Property_type, Accomodities, Bathroom, Bedroom, Beds, Square_feet, Advertisement_url, Daily_price, Weekly_price, Monthly_price, Minimum_nights, Maximum_nights, Security_deposit, Cleaning_fee)
SELECT DISTINCT a.id, a.name, a.description, a.property_type, a.accommodates, a.bathrooms, a.bedrooms, a.beds, a.square_feet, a.listing_url, a.price, a.weekly_price, a.monthly_price, a.minimum_nights, a.maximum_nights, a.security_deposit, a.cleaning_fee
FROM imp_apartments AS a;

UPDATE Apartment
SET ID_image = i.ID_image
FROM imp_apartments AS ia, Image AS i
WHERE ia.listing_url = advertisement_url AND i.Url_image = ia.picture_url;

UPDATE Apartment
SET ID_host = ih.host_id
FROM imp_hosts AS ih
WHERE ih.listing_url = advertisement_url;

UPDATE Apartment
SET ID_location = l.ID_location
FROM imp_apartments AS ia, Location AS l
WHERE id_apartment = ia.id
	AND l.street_name = ia.street
	AND l.neighbourhood_name = ia.neighbourhood_cleansed
	AND l.city_name = ia.city
	AND l.state_code = ia.state;

SELECT * FROM Apartment;

-- Insert de Amenities
DROP TABLE IF EXISTS Amenities_aux CASCADE;
CREATE TABLE Amenities_aux (
	ID_amenity SERIAL,
	Amenity_name VARCHAR(255),
  Listing_url VARCHAR(255),
	PRIMARY KEY (ID_amenity)
);

INSERT INTO Amenities_aux (Amenity_name, Listing_url)
SELECT regexp_split_to_table(a.amenities, ','), a.listing_url
FROM imp_apartments AS a;

UPDATE Amenities_aux
SET Amenity_name = REPLACE(Amenity_name, '"', '');

UPDATE Amenities_aux
SET Amenity_name = REPLACE(Amenity_name, '{', '');

UPDATE Amenities_aux
SET Amenity_name = REPLACE(Amenity_name, '}', '');

INSERT INTO Amenities (Amenity_name)
SELECT DISTINCT Amenity_name
FROM Amenities_aux;

SELECT * FROM Amenities;

-- Insert de apartmentAmenities
INSERT INTO apartmentAmenities (ID_apartment, ID_amenity)
SELECT ap.ID_apartment, am.ID_amenity
FROM Apartment AS ap, Amenities AS am, Amenities_aux AS aa
WHERE ap.advertisement_url = aa.Listing_url AND am.Amenity_name = aa.Amenity_name
GROUP BY ap.ID_apartment, am.ID_amenity;

DROP TABLE IF EXISTS Amenities_aux CASCADE;

SELECT * FROM apartmentAmenities;

-- Insert de review
INSERT INTO Review (ID_user, ID_apartment, Comments, Data_review)
SELECT r.reviewer_id, r.id, r.comments, r.date_review
FROM imp_reviews AS r;

SELECT * FROM Review;

-- Select de les taules
SELECT * FROM Country;
SELECT * FROM State;
SELECT * FROM Location;
SELECT * FROM Image;
SELECT * FROM "User";
SELECT * FROM Host;
SELECT * FROM Verifications;
SELECT * FROM hostVerifications;
SELECT * FROM Apartment;
SELECT * FROM Amenities;
SELECT * FROM apartmentAmenities;
SELECT * FROM Review;

-- Eliminacio de taules d'importacio
/*
DROP TABLE IF EXISTS imp_reviews;
DROP TABLE IF EXISTS imp_apartments;
DROP TABLE IF EXISTS imp_hosts;
*/

-- Verificacio importacio de dades
/*
SELECT COUNT(ia.id) AS num_imp_apartments
FROM imp_apartments AS ia;

SELECT COUNT(a.id_apartment) AS num_Apartment
FROM Apartment AS a;

SELECT COUNT(DISTINCT ih.host_id) AS num_imp_hosts
FROM imp_hosts AS ih;

SELECT COUNT(h.id_host) AS num_Host
FROM Host AS h;

SELECT COUNT(ir.comments) AS num_imp_reviews
FROM imp_reviews AS ir;

SELECT COUNT(r.id_review) AS num_Review
FROM Review AS r;

SELECT * FROM Apartment
WHERE id_apartment = '10022934';

SELECT * FROM Host
WHERE id_host = '15785687';

SELECT * FROM "User"
WHERE id_user = '15785687';

SELECT i.Url_image
FROM Image AS i, "User" AS u
WHERE i.ID_image = u.ID_image AND u.ID_user = '15785687';

SELECT i.Url_image
FROM Image AS i, Apartment AS a
WHERE i.ID_image = a.ID_image AND a.ID_apartment = '10022934';

SELECT * FROM Review
WHERE id_apartment = '10022934';

SELECT l.street_name, l.neighbourhood_name, l.city_name, s.state_code, c.country_name
FROM Location AS l, Apartment AS a, State AS s, Country AS c
WHERE l.id_location = a.id_location AND l.state_code = s.state_code AND s.country_code = c.country_code AND a.id_apartment = '10022934';

SELECT am.amenity_name
FROM Amenities AS am, apartmentAmenities AS aa, Apartment AS a
WHERE am.id_amenity = aa.id_amenity AND a.id_apartment = aa.id_apartment AND a.id_apartment = '10022934';

SELECT v.Verification_name
FROM verifications AS v, hostverifications AS hv, Host AS h
WHERE v.id_verification = hv.id_verification AND h.id_host = hv.id_host AND h.id_host = '15785687';
*/