-- CREACIO DE TAULES NORMALITZADES

DROP TABLE IF EXISTS Country CASCADE;
CREATE TABLE Country (
	Country_code VARCHAR(255),
	Country_name VARCHAR(255),
	PRIMARY KEY (Country_code)
);

DROP TABLE IF EXISTS State CASCADE;
CREATE TABLE State (
	State_code VARCHAR(255),
	Country_code VARCHAR(255),
	PRIMARY KEY (State_code),
	FOREIGN KEY (Country_code) REFERENCES Country (Country_code)
);

DROP TABLE IF EXISTS Location CASCADE;
CREATE TABLE Location (
	ID_location SERIAL,
	Street_name VARCHAR(255),
	Neighbourhood_name VARCHAR(255),
	City_name VARCHAR(255),
	State_code VARCHAR(255),
	PRIMARY KEY (ID_location),
	FOREIGN KEY (State_code) REFERENCES State (State_code)
);

DROP TABLE IF EXISTS Image CASCADE;
CREATE TABLE Image (
	ID_image SERIAL,
	Url_image VARCHAR(255),
	PRIMARY KEY (ID_image)
);

DROP TABLE IF EXISTS "User" CASCADE;
CREATE TABLE "User" (
	ID_user INT,
	User_name VARCHAR(255),
	ID_image INT,
	PRIMARY KEY (ID_user),
	FOREIGN KEY (ID_image) REFERENCES Image (ID_image)
);

DROP TABLE IF EXISTS Host CASCADE;
CREATE TABLE Host (
	ID_host INT,
	Host_url VARCHAR(255),
	Host_since VARCHAR(255),
	Host_about TEXT,
	Host_response_time VARCHAR(255),
	Host_response_rate VARCHAR(255),
	Host_is_superhost CHAR(1),
	Host_listings_count INT,
	Host_identity_verified VARCHAR(255),
	PRIMARY KEY (ID_host),
	FOREIGN KEY (ID_host) REFERENCES "User" (ID_user)
);

DROP TABLE IF EXISTS Verifications CASCADE;
CREATE TABLE Verifications (
	ID_verification SERIAL,
	Verification_name VARCHAR(255),
	PRIMARY KEY (ID_verification)
);

DROP TABLE IF EXISTS hostVerifications CASCADE;
CREATE TABLE hostVerifications (
	ID_host INT,
	ID_verification INT,
	PRIMARY KEY (ID_host,ID_verification),
	FOREIGN KEY (ID_host) REFERENCES Host (ID_host),
	FOREIGN KEY (ID_verification) REFERENCES Verifications (ID_verification)
);

DROP TABLE IF EXISTS Apartment CASCADE;
CREATE TABLE Apartment (
	ID_apartment INT,
	Apartment_name VARCHAR(255),
	Description TEXT,
	Property_type VARCHAR(255),
	Accomodities VARCHAR(255),
	Bathroom FLOAT,
	Bedroom INT,
	Beds INT,
	Square_feet INT,
	ID_location INT,
	ID_image INT,
	ID_host INT,
  Advertisement_url VARCHAR(255),
	Daily_price FLOAT,
  Weekly_price FLOAT,
  Monthly_price FLOAT,
  Minimum_nights INT,
  Maximum_nights INT,
  Security_deposit FLOAT,
  Cleaning_fee FLOAT,
	PRIMARY KEY (ID_apartment),
	FOREIGN KEY (ID_location) REFERENCES Location (ID_location),
	FOREIGN KEY (ID_image) REFERENCES Image (ID_image),
	FOREIGN KEY (ID_host) REFERENCES Host (ID_host)
);

DROP TABLE IF EXISTS Amenities CASCADE;
CREATE TABLE Amenities (
	ID_amenity SERIAL,
	Amenity_name VARCHAR(255),
	PRIMARY KEY (ID_amenity)
);

DROP TABLE IF EXISTS apartmentAmenities CASCADE;
CREATE TABLE apartmentAmenities (
  ID_apartment INT,
	ID_amenity INT,
	PRIMARY KEY (ID_apartment,ID_amenity),
	FOREIGN KEY (ID_apartment) REFERENCES Apartment (ID_apartment),
	FOREIGN KEY (ID_amenity) REFERENCES Amenities (ID_amenity)
);

DROP TABLE IF EXISTS Review CASCADE;
CREATE TABLE Review (
  ID_review SERIAL,
  ID_user INT,
	ID_apartment INT,
	Comments TEXT,
	Data_review DATE,
	PRIMARY KEY (ID_review),
	FOREIGN KEY (ID_user) REFERENCES "User" (ID_user),
	FOREIGN KEY (ID_apartment) REFERENCES Apartment (ID_apartment)
);
