--1
--#&&
SELECT l.city_name AS name, 100 - AVG(a.weekly_price / 7 / a.daily_price * 100) AS savings_percentage
FROM Apartment AS a, Location AS l, Host AS h
WHERE a.id_location = l.id_location AND a.id_host = h.id_host AND h.host_identity_verified LIKE 't'
GROUP BY l.city_name
HAVING 100 - AVG(a.weekly_price / 7 / a.daily_price * 100) IS NOT NULL
ORDER BY savings_percentage DESC
LIMIT 3;

--Verificacio
--#&&
SELECT ia.city AS name, 100 - AVG(ia.weekly_price / 7 / ia.price * 100) AS savings_percentage
FROM imp_apartments AS ia, imp_hosts AS ih
WHERE ia.listing_url = ih.listing_url AND ih.host_identity_verified LIKE 't'
GROUP BY ia.city
HAVING 100 - AVG(ia.weekly_price / 7 / ia.price * 100) IS NOT NULL
ORDER BY savings_percentage DESC
LIMIT 3;


--2
--#&&
SELECT a.Apartment_name AS name, (a.Daily_price/a.Square_feet) AS price_m2, COUNT(r.id_review) AS reviews
FROM Apartment AS a, Review AS r
WHERE a.id_apartment = r.id_apartment AND a.square_feet <> '0'
GROUP BY a.id_apartment
HAVING COUNT(r.id_review) >= 200
ORDER BY (a.Daily_price/a.Square_feet) DESC
LIMIT 2;


--3
--#&&
SELECT a.Apartment_name AS name, a.Advertisement_url AS url, a.Daily_price * '5' * '6' + a.Cleaning_fee + a.Security_deposit * '0.1' AS price
FROM Apartment AS a, Location AS l, Host AS h, Amenities AS am, apartmentAmenities AS aa
WHERE a.id_location = l.id_location AND a.id_host = h.id_host AND aa.id_apartment = a.id_apartment AND aa.id_amenity = am.id_amenity
  AND h.host_response_rate <> 'N/A' AND a.accomodities = '6' AND l.neighbourhood_name LIKE 'Port Phillip' AND am.amenity_name LIKE 'Balcony' AND a.bathroom > '1.5' AND CAST(LEFT(h.host_response_rate,-1) AS INT) > '90'
ORDER BY price ASC
LIMIT 1;

--Verificacio
--#&&
SELECT ia.name AS name, ia.listing_url AS url, ia.price * '5' * '6' + ia.Cleaning_fee + ia.Security_deposit * '0.1' AS price
FROM imp_apartments AS ia, imp_hosts AS ih
WHERE ia.listing_url = ih.listing_url AND ih.host_response_rate <> 'N/A' AND ia.accommodates = '6' AND ia.neighbourhood_cleansed LIKE 'Port Phillip' AND ia.amenities LIKE '%Balcony%' AND ia.bathrooms > '1.5' AND CAST(LEFT(ih.host_response_rate,-1) AS INT) > '90'
ORDER BY price ASC
LIMIT 1;


--4
UPDATE Host
SET Host_is_superhost = 'f'
WHERE host_is_superhost = 't';

UPDATE Host
SET Host_is_superhost = 't'
WHERE host_since LIKE '2014%' OR host_since LIKE '2013%' OR host_since LIKE '2012%'
   OR host_since LIKE '2011%' OR host_since LIKE '2010%' OR host_since LIKE '2009%';

--#&&
SELECT COUNT(id_host) AS superhosts
FROM Host
WHERE Host_is_superhost = 't'
GROUP BY Host_is_superhost;

--#&&
SELECT COUNT(id_host) AS normal_hosts
FROM Host
WHERE Host_is_superhost = 'f'
GROUP BY Host_is_superhost;


--5
--#&&
SELECT l.Street_name AS street, COUNT(a.id_apartment) AS num, AVG(a.daily_price) AS price
FROM Apartment AS a, Location AS l
WHERE a.id_location = l.id_location
GROUP BY l.street_name
HAVING AVG(a.daily_price) < '100'
ORDER BY COUNT(a.id_apartment) DESC
LIMIT 3;

--Verificacio
--#&&
SELECT Street AS street, COUNT(id) AS num, AVG(price) AS price
FROM imp_apartments
GROUP BY street
HAVING AVG(price) < '100'
ORDER BY COUNT(id) DESC
LIMIT 3;


--6
--#&&
SELECT u.User_name AS name_reviewer, a.Advertisement_url AS url, COUNT(r.id_review) AS num_reviews
FROM "User" AS u, Apartment AS a, Review AS r
WHERE u.id_user = r.id_user AND r.id_apartment = a.id_apartment
GROUP BY u.id_user, a.id_apartment
ORDER BY COUNT(r.id_review) DESC
LIMIT 3;

--Cameron deixa varies reviews al mateix mes i totes son molt semblants.

--Verificacio
--#&&
SELECT u.user_name AS name_reviewer, ir.listing_url AS url, COUNT(ir.comments) AS num_reviews
FROM imp_reviews AS ir, "User" AS u
WHERE ir.reviewer_id = u.id_user
GROUP BY u.id_user, ir.listing_url
ORDER BY COUNT(comments) DESC
LIMIT 4;


--7
--#&&
SELECT a.id_apartment AS id, a.apartment_name AS name, a.Daily_price * '2' * '2' + a.Cleaning_fee + a.Security_deposit * '0.1' AS price
FROM Apartment AS a, Location AS l, Host AS h, Amenities AS am, apartmentAmenities AS aa, hostverifications AS hv, Verifications AS v
WHERE a.id_location = l.id_location AND a.id_host = h.id_host AND aa.id_apartment = a.id_apartment AND aa.id_amenity = am.id_amenity AND hv.id_host = h.id_host AND hv.id_verification = v.id_verification
  AND a.accomodities >= '2' AND a.beds >= 2 AND l.city_name LIKE 'Saint Kilda' AND am.amenity_name LIKE 'Kitchen' AND v.verification_name LIKE 'phone' AND (a.Daily_price * '2' * '2' + a.Cleaning_fee + a.Security_deposit * '0.1') < '5000'
ORDER BY price DESC;


--8
--#&&
SELECT u.user_name AS name, SUM(1/a.daily_price) * (1 + CASE WHEN h.host_is_superhost = 't' THEN 1 ELSE 0 END) * COUNT(DISTINCT hv.ID_verification) * COUNT(DISTINCT a.ID_apartment) AS score
FROM "User" AS u, apartment AS a, Host AS h, hostverifications AS hv
WHERE u.id_user = h.id_host AND h.id_host = a.id_host AND h.id_host = hv.id_host AND daily_price <> 0
GROUP BY u.id_user, h.id_host
ORDER BY score DESC;


SELECT ih.host_id AS name, SUM(1/ia.price) * (1 + CASE WHEN ih.host_is_superhost = 't' THEN 1 ELSE 0 END) * COUNT(DISTINCT hs.id_verification) * COUNT(DISTINCT ia.id) AS score
FROM imp_apartments as ia, imp_hosts AS ih, hostverifications AS hs
WHERE ia.listing_url = ih.listing_url AND hs.id_host = ih.host_id AND ia.price <> 0
GROUP BY ih.host_id, ih.host_is_superhost
ORDER BY score DESC;

SELECT * FROM imp_apartments;
SELECT * FROM imp_hosts;

SELECT count(*) FROM apartment WHERE id_host = 9082;
SELECT count(*) FROM hostverifications WHERE id_host = 9082;

SELECT * FROM host WHERE id_host = 90729398;
SELECT * FROM apartment WHERE id_host = 90729398;
SELECT * FROM hostverifications WHERE id_host = 90729398;

SELECT * FROM host WHERE id_host = 8530753;
SELECT * FROM apartment WHERE id_host = 8530753;
SELECT * FROM hostverifications WHERE id_host = 8530753;

SELECT * FROM host WHERE id_host = 22860147;
SELECT * FROM apartment WHERE id_host = 22860147;
SELECT * FROM hostverifications WHERE id_host = 22860147;

SELECT SUM(daily_price) FROM apartment WHERE id_host = 90729398;

--9
DROP TABLE IF EXISTS Points10 CASCADE;
CREATE TABLE Points10 (
  ID INT,
  Points INT
);

DROP TABLE IF EXISTS Points15 CASCADE;
CREATE TABLE Points15 (
  ID INT,
  Points INT
);

INSERT INTO Points10 (ID, Points)
SELECT r.ID_user, COUNT(r.ID_review) * '10'
FROM Review AS r
WHERE LENGTH(r.comments) < '100'
GROUP BY r.ID_user;

INSERT INTO Points15 (ID, Points)
SELECT r.ID_user, COUNT(r.ID_review) * '15'
FROM Review AS r
WHERE LENGTH(r.comments) >= '100'
GROUP BY r.ID_user;

--#&&
SELECT u.User_name AS name, (p10.Points + p15.Points) AS points
FROM Points10 AS p10, Points15 AS p15, "User" AS u
WHERE u.id_user = p10.id AND u.id_user = p15.id
ORDER BY points DESC
LIMIT 10;

--Verificacio
DROP TABLE IF EXISTS Points10 CASCADE;
CREATE TABLE Points10 (
  ID INT,
  Points INT
);

DROP TABLE IF EXISTS Points15 CASCADE;
CREATE TABLE Points15 (
  ID INT,
  Points INT
);

INSERT INTO Points10 (ID, Points)
SELECT ir.reviewer_id, COUNT(ir.comments) * '10'
FROM imp_reviews AS ir
WHERE LENGTH(ir.comments) < '100'
GROUP BY ir.reviewer_id;

INSERT INTO Points15 (ID, Points)
SELECT ir.reviewer_id, COUNT(ir.comments) * '15'
FROM imp_reviews AS ir
WHERE LENGTH(ir.comments) >= '100'
GROUP BY ir.reviewer_id;

--#&&
SELECT distinct ir.reviewer_name AS name, (p10.Points + p15.Points) AS points
FROM Points10 AS p10, Points15 AS p15, imp_reviews AS ir
WHERE ir.reviewer_id = p10.id AND ir.reviewer_id = p15.id
ORDER BY points DESC
LIMIT 10;


--10
-- Selecciona el nom del host, del seu apartament i el nombre de reviews obtingudes de tots els hosts que no siguin super-host,
-- que el seu apartament estigui a la ciutat de Melbourne amb 2.5 lavabos o mes i amb wifi,
-- i que el seu nom no sigui mes llarg que el nombre de reviews obtingudes, ordenats per llargada de nom limitat per 5.
--#&&
SELECT u.user_name AS name, a.apartment_name AS Apartment, COUNT(r.ID_review) AS num_reviews
FROM Apartment AS a, Location AS l, Host AS h, Amenities AS am, apartmentAmenities AS aa,"User" AS u,review as r
WHERE u.id_user = h.id_host
  AND a.id_host = h.id_host
  AND a.id_location = l.id_location
  AND a.id_apartment = aa.id_apartment
  AND am.id_amenity = aa.id_amenity
  AND r.id_apartment = a.id_apartment
  AND h.host_is_superhost = 'f'
  AND l.city_name = 'Melbourne'
  AND a.bathroom >= '2.5'
  AND am.amenity_name LIKE 'Wifi'
GROUP BY u.id_user, a.apartment_name
HAVING COUNT(r.ID_review) > LENGTH(u.user_name)
ORDER BY LENGTH(u.user_name) DESC
LIMIT 5;
