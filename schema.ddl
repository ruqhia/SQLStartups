drop schema if exists startUp cascade;
create schema startUp;
set search_path to startUp;

--Any entities that are related to startups. These include startups, and investors
Create Table Startups(
	--The id of the entity
	entity_id varchar,
	--The name of the entity (startup company name, for example)
	affiliation_name varchar not null,
	--The type of startup or investor
	category_code varchar,
	--The date of which the entity was founded
	founded_at varchar,
	-- The current status of the entity(for example: acquired,closed etc)
	status varchar not null,
	primary key(entity_id));

--The people who work at startups
Create Table People(
	--The id of the person
	person_id integer primary key,
	--The first name of the person
	first_name varchar,
	--The last name of the person
	last_name varchar,
	--The company of which the person works at 
	affiliation_name varchar not null
);

--The degrees that people hold
Create Table Degrees(
	--The person that received this degree
	person_id integer references People(person_id),
	--The type of degree (for example: BA, MBA, PhD)
	degree_type varchar not null,
	--The subject / major the degree is in
	subject varchar not null,
	--The university or institution the degree was received
	institution varchar not null,
	--The date of graduation
	graduated_at varchar,
	primary key(person_id,degree_type,subject,institution)
);

--The offices that startups had
Create Table Offices(
	--The entity that this office is for
	entity_id varchar, 
	--The id of the office
	office_id  integer not null,
	--The region the office is in 
	region varchar not null,
	--The city that the office is location
	city varchar not null ,
	--The zip code of the office
	zip_code varchar,
	--The state the office is located in
	state_code varchar,
	primary key(entity_id,office_id)
);

--The investments for startups that occured
Create Table Investments(
	--The startups that were invested in
	entity_id varchar references Startups(entity_id),
	--The funding round that the investment occured during
	funding_round_id integer,
	--The investor that invested in the startup
	investor_object_id varchar not null,
	primary key(entity_id, funding_round_id, investor_object_id)
);

--The funding rounds where the different startups received funding
Create Table FundingRounds (
	--The startup of that received funding
	entity_id varchar references Startups(entity_id),
	--The funding round id
	funding_round_id integer,
	--The date of which the funding occured
	funded_at varchar,
	--The type of the funding round
	funding_round_type varchar,
	--Amount of money (in USD) that was raised for that startup
	raised_amount_usd float not null,
	primary key (entity_id,funding_round_id)
);

--The IPOs that startups received
Create Table IPOS(
	--The startup that received the IPO
	entity_id varchar references Startups,
	--The id of the IPO
	ipo_id integer,
	--The amount (in USD) that the startup received
	valuation_amount bigint not null,
	primary key(entity_id, ipo_id)
);

