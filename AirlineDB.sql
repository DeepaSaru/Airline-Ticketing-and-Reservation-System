-- =================================================
-- Name      : Deepa Ramu
-- StudentID   : @00801743
-- Assignment: ADB -- Assignment2 -- Task 1
-- ================================================

-- Creating Database 
CREATE DATABASE SkyTrackDB;

-- Use Database
Use SkyTrackDB;
 
 --====================================================================

-- 1. Creating the Employees table with necessary columns and constraints
CREATE TABLE Employees (
	employee_id INT IDENTITY(1,1) PRIMARY KEY,	-- Auto-incrementing primary key
	first_name NVARCHAR(50) NOT NULL,
	middle_name NVARCHAR(50) NULL,
	last_name NVARCHAR(50) NOT NULL,
	email NVARCHAR(100) NOT NULL,	 -- Must be unique
	username NVARCHAR(50) NOT NULL,  -- Must be unique
	password_hash VARBINARY(256) NOT NULL,   -- Securely stores hashed passwords
	role VARCHAR(20) NOT NULL CHECK (role IN ('ticketing staff', 'ticketing supervisor')), -- Role constraint
	CONSTRAINT UQ_employees_email UNIQUE (email),
    CONSTRAINT UQ_employees_username UNIQUE (username)
);

-- Verify if the Employees table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Employees';

--==================================================================================

-- 2. Creating the Flights table with necessary columns and constraints
CREATE TABLE Flights (
	flight_id INT IDENTITY(1,1) PRIMARY KEY,	-- Auto-incrementing primary key
	flight_no VARCHAR(20) NOT NULL,		-- Unique flight number
	origin VARCHAR(50) NOT NULL,	 -- Departure location
	destination VARCHAR(50) NOT NULL,	-- Arrival location
	departure_time DATETIME2 NOT NULL, 
	arrival_time DATETIME2 NOT NULL, 
	CONSTRAINT UQ_flight_no UNIQUE (flight_no),
	CONSTRAINT CHK_flights_arrival_time CHECK (arrival_time > departure_time), -- Arrival must be after departure
	CONSTRAINT CHK_departure_time_not_past CHECK (departure_time >= GETDATE()) -- Prevent past departures
);

-- Verify if the Flights table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Flights';

--================================================================================

--  3. Creating the Passengers table with necessary columns and constraints
CREATE TABLE Passengers (
	passenger_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
	pnr VARCHAR(20) NOT NULL, -- Unique booking reference
	first_name NVARCHAR(50) NOT NULL,
	middle_name NVARCHAR(50) NULL,
	last_name NVARCHAR(50) NOT NULL,
	dob DATE NOT NULL, -- Date of birth
	email NVARCHAR(100) NOT NULL, -- Must be unique
	meal_preference VARCHAR(20) NOT NULL CHECK (meal_preference IN ('vegetarian', 'non-vegetarian')), -- Valid meal options
	emergency_contact VARCHAR(20) NULL, -- Optional emergency contact
	CONSTRAINT UQ_passengers_pnr UNIQUE (pnr),
	CONSTRAINT UQ_passengers_email UNIQUE (email)
);

-- Verify if the Passengers table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Passengers';

--=====================================================================================

-- 4. Creating the Reservation table with necessary columns and constraints
CREATE TABLE Reservations (
	reservation_id INT IDENTITY(1,1) PRIMARY KEY,
	reservation_date DATETIME2 NOT NULL,
	status VARCHAR(20) NOT NULL CHECK (status IN ('confirmed', 'pending', 'cancelled')),
	flight_id INT NOT NULL,
	pnr VARCHAR(20) NOT NULL,
	FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (pnr) REFERENCES Passengers(pnr),
);

-- Verify if the Reservations table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Reservations';

--==================================================================================

-- 5. Creating the Tickets table with necessary columns and constraints
CREATE TABLE Tickets (
	ticket_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    reservation_id INT NOT NULL, -- References the reservation
	issue_date DATE NOT NULL, -- Date the ticket was issued
	issue_time TIME NOT NULL, -- Time the ticket was issued
	fare DECIMAL(10,2) NOT NULL, -- Ticket fare amount
	seat_number VARCHAR(10) NULL, -- Optional seat assignment
	seat_status VARCHAR(10) NULL, -- Optional seat status (e.g., reserved/blocked)
	class VARCHAR(20) NOT NULL CHECK (class IN ('business', 'firstclass', 'economy')), -- Travel class
	eboarding_number VARCHAR(10) UNIQUE NOT NULL, -- Unique e-boarding number
	employee_id INT NOT NULL, -- Issued by which employee
	FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Verify if the Tickets table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tickets';

--==========================================================================================

--6. Creating the Additional Services table with necessary columns and constraints
CREATE TABLE Additional_Services (
   service_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
	ticket_id INT NOT NULL, -- References the related ticket

    extra_baggage_kg DECIMAL(10, 2) DEFAULT 0, -- Extra baggage in kg
	upgraded_meal_count INT DEFAULT 0, -- Number of upgraded meals
	preferred_seat_count INT DEFAULT 0, -- Number of preferred seat selections
    taxes_and_fees DECIMAL(10, 2) DEFAULT 0, -- Any applicable additional charges

	-- computed columns
	extra_baggage_cost AS (extra_baggage_kg * 100), 
	upgraded_meal_cost AS (upgraded_meal_count * 20), 
	preferred_seat_cost AS (preferred_seat_count * 30),

  -- Calculate total_additional_fare directly from the non-computed columns
    total_additional_fare AS (extra_baggage_kg * 100 + upgraded_meal_count * 20 + preferred_seat_count * 30 + taxes_and_fees),

	FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

-- Verify if the Additional_Services table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Additional_Services';

--===============================================================================================

-- 7. Creating the Baggage table with necessary columns and constraints
CREATE TABLE Baggage (
	baggage_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
	ticket_id INT NOT NULL, -- References the related ticket
	baggage_weight DECIMAL(10,2) NOT NULL, -- Weight of the baggage in kg
	status VARCHAR(10) NOT NULL CHECK (status IN ('checked-in', 'loaded')), -- Baggage status
	FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

 -- Verify if the Baggage table was created successfully
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Baggage';

--==========================================================================================

-- Insert data into the Employees table
INSERT INTO Employees (first_name, middle_name, last_name, email, username, password_hash, role)
VALUES
    ('John', NULL, 'Doe', 'john.doe@email.com', 'johndoe', HASHBYTES('SHA2_256', 'Password123!'), 'ticketing staff'),
    ('Alice', 'Marie', 'Smith', 'alice.smith@email.com', 'alicesmith', HASHBYTES('SHA2_256', 'SecurePass456'), 'ticketing supervisor'),
    ('Michael', NULL, 'Brown', 'michael.brown@email.com', 'mikebrown', HASHBYTES('SHA2_256', 'Mike12345'), 'ticketing staff'),
    ('Sarah', 'Ann', 'Williams', 'sarah.williams@email.com', 'sarahw', HASHBYTES('SHA2_256', 'SarahSecure789'), 'ticketing staff'),
    ('David', NULL, 'Johnson', 'david.johnson@email.com', 'djohnson', HASHBYTES('SHA2_256', 'David@2025'), 'ticketing supervisor'),
    ('Emily', 'Grace', 'Taylor', 'emily.taylor@email.com', 'emilyt', HASHBYTES('SHA2_256', 'TaylorPass321'), 'ticketing staff'),
    ('Robert', 'Lee', 'Miller', 'robert.miller@email.com', 'robmiller', HASHBYTES('SHA2_256', 'MillerSecure999'), 'ticketing supervisor');

-- Check the data inserted into the Employees table
SELECT * FROM Employees;

--============================================================================================

-- Insert data into the Flights table
INSERT INTO Flights (flight_no, origin, destination, departure_time, arrival_time)
VALUES
     ('FL1001', 'London', 'Paris', '2025-04-11 09:00:00', '2025-04-11 11:00:00'),
	  ('FL1002', 'Manchester', 'Dubai', '2025-04-11 14:30:00', '2025-04-11 23:00:00'),
      ('FL1003', 'New York', 'Los Angeles', '2025-04-12 08:00:00', '2025-04-12 11:30:00'),
      ('FL1004', 'Delhi', 'Singapore', '2025-04-13 22:00:00', '2025-04-14 06:00:00'),
      ('FL1005', 'Tokyo', 'Sydney', '2025-04-14 10:00:00', '2025-04-14 21:00:00'),
      ('FL1006', 'Dubai', 'London', '2025-04-15 03:00:00', '2025-04-15 18:00:00'),
      ('FL1007', 'Toronto', 'Frankfurt', '2025-04-16 16:00:00', '2025-04-17 05:00:00');

-- Check the data inserted into the Flights table
SELECT * FROM Flights;

--============================================================================================

-- Insert data into the Passengers table
INSERT INTO Passengers (pnr, first_name, middle_name, last_name, dob, email, meal_preference, emergency_contact)
VALUES
    ('PNR1001', 'John', NULL, 'David', '1965-03-15', 'john.doe@email.com', 'vegetarian', '1234567890'),
    ('PNR1002', 'Alice', 'Marie', 'Smith', '1990-07-22', 'alice.smith@email.com', 'non-vegetarian', '9876543210'),
    ('PNR1003', 'Michael', NULL, 'Brown', '1978-11-05', 'michael.brown@email.com', 'vegetarian', '4561237890'),
    ('PNR1004', 'Sarah', 'Ann', 'Davis', '1959-04-18', 'sarah.williams@email.com', 'non-vegetarian', NULL),
    ('PNR1005', 'David', NULL, 'Johnson', '1995-09-30', 'david.johnson@email.com', 'vegetarian', '3216549870'),
    ('PNR1006', 'Emily', 'Grace', 'Taylor', '1982-01-25', 'emily.taylor@email.com', 'non-vegetarian', '7893216540'),
    ('PNR1007', 'Robert', 'Lee', 'Davis', '1959-06-12', 'robert.miller@email.com', 'vegetarian', NULL);

-- Check the data inserted into the Passengers table
SELECT * FROM Passengers;

--===========================================================================================

-- Insert data into the Reservations table
INSERT INTO Reservations (reservation_date, status, flight_id, pnr)
VALUES
    ('2025-04-11 08:00:00', 'pending', 37, 'PNR1001'),
    ('2025-04-12 14:00:00', 'pending', 38, 'PNR1002'),
    ('2025-04-13 07:30:00', 'cancelled', 39, 'PNR1003'),
    ('2025-04-14 21:00:00', 'pending', 40, 'PNR1004'),
    ('2025-04-15 09:00:00', 'pending', 41, 'PNR1005'),
    ('2025-04-16 02:30:00', 'confirmed', 42, 'PNR1006'),
    ('2025-04-17 15:00:00', 'cancelled', 43, 'PNR1007'),
	('2025-04-11 14:00:00', 'confirmed', 41, 'PNR1001');

-- Check the data inserted into the Reservations table
SELECT * FROM Reservations;

--===========================================================================================

-- Insert data into the Tickets table
INSERT INTO Tickets (reservation_id, issue_date, issue_time, fare, seat_number, class, eboarding_number, employee_id)
VALUES
    (3, '2025-03-25', '09:00:00', 150.00, '12A', 'economy', 'EB1001', 1),
    (4, '2025-03-26', '14:30:00', 450.50, '3B', 'business', 'EB1002', 2),
    (5, '2025-03-27', '08:15:00', 300.00, '7C', 'firstclass', 'EB1003', 3),
    (6, '2025-03-28', '21:00:00', 180.75, NULL, 'economy', 'EB1004', 4),
    (7, '2025-03-29', '10:45:00', 500.00, NULL, 'business', 'EB1005', 5),
    (8, '2025-03-30', '03:00:00', 250.00, '10D', 'economy', 'EB1006', 6),
    (9, '2025-03-31', '16:00:00', 375.00, '4E', 'firstclass', 'EB1007', 7),
	(13, '2025-03-25', '09:00:00', 250.00, '12B', 'business', 'EB1008', 4);

-- Check the data inserted into the Tickets table
SELECT * FROM Tickets;

--===========================================================================================

-- Insert data into the Additional_Services table
INSERT INTO Additional_Services (ticket_id, extra_baggage_kg, upgraded_meal_count, preferred_seat_count, taxes_and_fees)
VALUES
    (2, 2.5, 1, 0, 10.00),  -- 250 + 20 + 0 + 10 = 280
    (3, 0.0, 2, 1, 5.00),   -- 0 + 40 + 30 + 5 = 75
    (4, 1.0, 0, 2, 15.00),  -- 100 + 0 + 60 + 15 = 175
    (5, 3.0, 1, 1, 20.00),  -- 300 + 20 + 30 + 20 = 370
    (6, 0.0, 3, 0, 0.00),   -- 0 + 60 + 0 + 0 = 60
    (7, 1.5, 0, 1, 12.50),  -- 150 + 0 + 30 + 12.5 = 192.5
    (8, 0.0, 2, 2, 8.00);   -- 0 + 40 + 60 + 8 = 108

-- Check the data inserted into the Additional_Services table
SELECT * FROM Additional_Services;

--=============================================================================================

-- Insert data into the Baggage table
INSERT INTO Baggage (ticket_id, baggage_weight, status)
VALUES
    (2, 20.50, 'checked-in'),  
    (3, 25.00, 'loaded'),     
    (4, 18.00, 'checked-in'),  
    (5, 30.00, 'loaded'),      
    (6, 22.00, 'checked-in'), 
    (7, 28.50, 'loaded'),      
    (7, 15.00, 'checked-in'),  
    (2, 30.50, 'checked-in'),  
    (6, 25.00, 'loaded'),
	(5, 20.00, 'loaded');

-- Check the data inserted into the Baggage table
SELECT * FROM Baggage;

-- ===========================================================

--Q2 : Add the constraint to check that the reservation date is not in the past.
/*Note :The constraint was already defined during the creation of the Reservation table.
 Here, we are simply verifying that the table does not accept reservation data with a past date.  */

BEGIN TRY
    INSERT INTO Reservations (reservation_date, status, flight_id, pnr)
    VALUES 
        ('2024-12-30 07:30:00', 'confirmed', 3, 'PNR1003');
    PRINT 'Record inserted successfully.';
END TRY

-- Handle errors if insertion fails
BEGIN CATCH
    PRINT 'Reservation date should not be in the past. ' + ERROR_MESSAGE();
END CATCH

--===============================================================================

--	Q3 : Identify Passengers with Pending Reservations and Passengers with age more than 40 years 
SELECT 
	p.passenger_id,
	p.pnr,
    p.first_name + ' ' + ISNULL(p.middle_name + ' ', '') + p.last_name AS full_name, -- Construct full name
    p.dob,
    r.status,
    DATEDIFF(YEAR, p.dob, GETDATE()) AS age -- Calculate age in years
FROM dbo.Reservations r
INNER JOIN Passengers p ON r.pnr = p.pnr -- Join reservations with passengers by PNR
WHERE r.status = 'Pending' AND DATEDIFF(YEAR, p.dob, GETDATE()) > 40; -- Filter: pending status and age > 40

--================================================================================

-- Q4 : The ticketing system also requires stored procedures or user-defined functions to do the following things:
-- 4a. Matching character strings by last name of passenger & results should be sorted with most recent issued ticket first.

-- Stored procedure to retrieve passenger details by partial or full last name
CREATE PROCEDURE GetPassengersByLast
    @lastname NVARCHAR(50) -- Input parameter for last name search
AS
BEGIN
	SELECT 
		p.passenger_id,
		t.issue_date, -- Date the ticket was issued
		p.pnr,
        p.first_name + ' ' + ISNULL(p.middle_name + ' ', '') + p.last_name AS full_name, -- Construct full name
        p.dob,
        p.email,
		p.meal_preference,
		p.emergency_contact
	FROM Passengers p
	INNER JOIN Reservations r ON p.pnr = r.pnr -- Join on PNR 
	INNER JOIN Tickets t ON r.reservation_id = t.reservation_id -- Join on reservation
	WHERE p.last_name LIKE '%' + @lastname + '%' -- Filter by partial last name match
	ORDER BY t.issue_date DESC; -- Most recent ticket first
END;

--Execute  Procedure GetPassengersByLast
EXEC GetPassengersByLast  @lastname = '%Dav%'

--=======================================================================================

-- 4b. Return a full list of passengers and his/her specific meal requirement in business class who has a reservation today.

-- Stored procedure to retrieve business class passengers with meal preferences 
CREATE PROCEDURE GetBusinessClassMealsToday
    @reservation_date DATE -- Input parameter for reservation date
AS
BEGIN
	SELECT
		p.passenger_id,
		p.pnr,
		p.first_name + ' ' + ISNULL(p.middle_name + ' ', '') + p.last_name AS full_name, -- Construct full name
		p.email,
		p.meal_preference,
		r.reservation_date
	FROM Passengers p
	INNER JOIN Reservations r ON p.pnr = r.pnr -- Join on PNR for reservation
	INNER JOIN Tickets t ON r.reservation_id = t.reservation_id -- Join on reservation ID to get ticket details
	WHERE t.class = 'business' -- Filter for business class passengers
	AND CAST(r.reservation_date AS DATE) = @reservation_date -- Filter by the specified reservation date
END;

--Execute Procedure GetBusinessClassMealsToday
DECLARE @reservation_date DATE = CAST(GETDATE() AS DATE);
EXEC GetBusinessClassMealsToday @reservation_date = @reservation_date;

--====================================================================================

-- 4c. Insert a new employee into the database.
CREATE PROCEDURE InsertEmployee
@first_name varchar(50),
@middle_name varchar(50),
@last_name varchar(50),
@email varchar(50),
@username varchar(50),
@password_hash varbinary(256),
@role varchar(20)
AS
BEGIN
    INSERT INTO Employees (first_name, middle_name, last_name, email, username, password_hash, role)
    VALUES (@first_name, @middle_name, @last_name, @email, @username, @password_hash, @role);
END

DECLARE @hashedPassword VARBINARY(256);
SET @hashedPassword = HASHBYTES('SHA2_256', 'Password363');

--Execute Procedure InsertEmployee
EXEC  InsertEmployee
	@first_name = 'John',
	@middle_name = 'Taylor' ,
	@last_name = 'Davis', 
	@email = 'john.taylor@email.com', 
	@username = 'johntaylor', 
	@password_hash = @hashedPassword,
	@role = 'ticketing Staff'

--===========================================================================

-- 4d. Update the details for a passenger that has booked a flight before. 
-- Stored procedure to update passenger details based on provided PNR
CREATE PROCEDURE UpdatePassengerDetails
    @pnr VARCHAR(20), -- Input parameter for PNR
    @first_name VARCHAR(50), -- Input parameter for first name
	@middle_name VARCHAR(50), -- Input parameter for middle name
	@last_name VARCHAR(50), -- Input parameter for last name
	@dob DATE, -- Input parameter for date of birth
    @email VARCHAR(100), -- Input parameter for email
    @meal_preference VARCHAR(20), -- Input parameter for meal preference
	@emergency_contact VARCHAR(20) -- Input parameter for emergency contact
AS
BEGIN
    -- Check if the provided PNR exists in the Reservations table
    IF EXISTS (SELECT 1 FROM Reservations WHERE pnr = @pnr)
    BEGIN
        -- Update passenger details in the Passengers table
        UPDATE Passengers
        SET 
            first_name = @first_name,
            middle_name = @middle_name,
            last_name = @last_name,
            dob = @dob,
            email = @email,
            meal_preference = @meal_preference,
            emergency_contact = @emergency_contact     
        WHERE 
            pnr = @pnr;  -- Update for the passenger with the matching PNR
        
        PRINT 'Passenger details updated successfully.'; -- Confirmation message
    END
    ELSE
    BEGIN
        PRINT 'No reservation found for the provided PNR.'; -- Error message if PNR is not found
    END
END;

--Execute Procedure UpdatePassengerDetails
EXEC UpdatePassengerDetails 
    @pnr = 'PNR1003',
    @first_name = 'John',
    @middle_name = 'A',
    @last_name = 'Doe',
    @dob = '1966-05-15',
    @email = 'john.doe@example.com',
    @meal_preference = 'non-vegetarian',
    @emergency_contact = '123-456-7890';

--==================================================================================

/*Q5. View all e-boarding numbers Issued by a Specific Employee showing the overall revenue generated by 
that employee on a particular flight. Include details of the fare, additional baggage fees, upgraded meal or preferred seat. */

-- Create view to calculate the total revenue generated by each employee from flight bookings
CREATE VIEW EmployeeFlightRevenue AS
SELECT 
	e.employee_id,
	e.first_name + ' ' + ISNULL(e.middle_name + ' ', '') + e.last_name AS full_name, -- Construct full name
	r.flight_id, -- Flight ID from the reservation
	t.eboarding_number, -- Boarding number associated with the ticket
	t.fare, -- Base fare of the ticket
	a.upgraded_meal_cost, -- Additional cost for upgraded meal
	a.preferred_seat_cost, -- Additional cost for preferred seat
	a.extra_baggage_cost, -- Additional cost for extra baggage
	a.total_additional_fare, -- Total_additional services = (upgraded_meal_cost + preferred_seat_cost + extra_baggage_cost)
    (t.fare + COALESCE(a.total_additional_fare, 0)) AS overall_revenue -- Calculate overall revenue (base fare + total_additional_fare )
FROM Employees e
INNER JOIN Tickets t ON e.employee_id = t.employee_id 
INNER JOIN Reservations r ON r.reservation_id = t.reservation_id
LEFT JOIN Additional_Services a ON t.ticket_id = a.ticket_id; -- Left join to include any additional services if available

--Executing the VIEW - EmployeeFlightRevenue
SELECT * FROM EmployeeFlightRevenue

--============================================================================================
--Q6. Create a trigger so that the current seat allotment of a passenger automatically updates to reserved when the ticket is issued 

CREATE TRIGGER UpdateSeatStatusOnTicketIssued
ON Tickets
AFTER INSERT
AS
BEGIN
    -- Declare a variable to hold the seat number
    DECLARE @seat_number VARCHAR(10);

    -- Get the seat number assigned to the newly issued ticket
    SELECT @seat_number = seat_number FROM INSERTED;

    -- Update the status of the seat to 'reserved' in the Seats table
    UPDATE Tickets
    SET seat_status = 'reserved'
    WHERE seat_number = @seat_number;
    
    PRINT 'Seat status updated to reserved for ticket issued.';
END;

--Creating a Insert Trigger on Tickets
INSERT INTO Tickets (reservation_id, issue_date, issue_time, fare, seat_number, class, eboarding_number, employee_id)
VALUES (8, '2025-06-30', '12:00:00', 500.00, 'A12', 'business', 'E12345', 2);

--Just to verify the insertion
SELECT * FROM Tickets;

--=================================================================================================
/*Q7. You should provide a function or view which allows the ticketing system to identify the total number of baggage’s (which are checkedin) 
made on a specified date for a specific flight */

-- Create view to count the number of checked-in baggage per reservation and flight
CREATE VIEW BaggageView AS
SELECT 
	count(b.ticket_id) AS total_count,  -- Count the number of baggage per reservation/flight
	r.reservation_date, -- Reservation date for the flight
	r.flight_id -- Flight ID associated with the reservation
FROM Baggage b
INNER JOIN Tickets t ON b.ticket_id = t.ticket_id 
INNER JOIN Reservations r ON r.reservation_id = t.reservation_id
WHERE b.status = 'checked-in' -- Only count baggage with 'checked-in' status
GROUP BY r.reservation_date, r.flight_id -- Group by reservation date and flight ID to get counts per flight

--Executing the Baggage VIEW
SELECT * FROM BaggageView

--==========================================================================================
--Q8. User Defined Functions (UDFs)
--a) GetFlightDuration Purpose: Calculates the duration of a flight based on departure and arrival times. 

-- Create a function to calculate the flight duration in hours and minutes
CREATE FUNCTION dbo.GetFlightDuration
(
    @departure_time DATETIME2, -- Input parameter for the departure time of the flight
    @arrival_time DATETIME2 -- Input parameter for the arrival time of the flight
)
RETURNS VARCHAR(20) -- The return type is a VARCHAR to represent the duration in hours and minutes
AS
BEGIN
    -- Calculate the difference in minutes between the departure and arrival times,
    -- and then convert it to hours and minutes format.
    RETURN CAST(DATEDIFF(MINUTE, @departure_time, @arrival_time) / 60 AS VARCHAR) + ' hrs ' +  -- Hours part
           CAST(DATEDIFF(MINUTE, @departure_time, @arrival_time) % 60 AS VARCHAR) + ' mins'; -- Minutes part
END;

--Invoking the func - dbo.GetFlightDuration
SELECT flight_no, 
       departure_time, 
       arrival_time,
       dbo.GetFlightDuration(departure_time, arrival_time) AS FlightDuration
FROM flights;

--8b . Create a view to count the number of passengers for each flight

CREATE VIEW FlightPassengerCount AS
SELECT 
    f.flight_number, -- Select the flight ID
    COUNT(p.passenger_id) AS passenger_count -- Count the number of passengers for each flight
FROM Flights f
LEFT JOIN Reservations r ON f.flight_id = r.flight_id
LEFT JOIN Passengers p ON r.pnr = p.pnr
LEFT JOIN Tickets t ON t.reservation_id = r.reservation_id
-- Group by flight ID to count the passengers for each flight
GROUP BY  f.flight_id; 

--Select all data from the created view to see the result
SELECT * FROM FlightPassengerCount

--=====================================================================================

-- creating authentication for employee
-- Role for Ticketing Staff (This employee role will only manage reservations and tickets
CREATE ROLE TicketStaffRole;
GRANT SELECT, INSERT, UPDATE ON Reservations TO TicketStaffRole;
GRANT SELECT, INSERT, UPDATE ON Tickets TO TicketStaffRole;
GRANT EXECUTE ON SCHEMA::dbo TO TicketStaffRole;

-- Role for Ticketing Supervisor role;
CREATE ROLE TicketSupervisorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Employees TO TicketSupervisorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservations TO TicketSupervisorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Tickets TO TicketSupervisorRole;
GRANT EXECUTE ON SCHEMA::dbo TO TicketSupervisorRole;

--=============================================================================================

-- Creating stored procedure to give access to employee to each role
CREATE PROCEDURE AddEmployee
	@First_name NVARCHAR(50),
	@Middle_Name NVARCHAR(50) = NULL,
	@Last_Name NVARCHAR(50),
	@Email NVARCHAR(100),
	@Username NVARCHAR(50),
	@Password NVARCHAR(100),  -- Plain text password input
	@Role VARCHAR(20)         -- 'ticketing staff' or 'ticketing supervisor'
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Validate role
		IF LOWER(@Role) NOT IN ('ticketing staff', 'ticketing supervisor')
		BEGIN
			RAISERROR('Invalid role. Allowed roles: ticketing staff, ticketing supervisor.', 16, 1);
			RETURN;
		END

		-- Hash the password using SHA2_256
		DECLARE @HashedPassword VARBINARY(256) = HASHBYTES('SHA2_256', @Password);

		-- Insert new employee into the Employees table
		INSERT INTO Employees (first_name, middle_name, last_name, email, username, password_hash, role)
		VALUES (@First_name, @Middle_Name, @Last_Name, @Email, @Username, @HashedPassword, LOWER(@Role));

		-- Declare the @SQL variable once
		DECLARE @SQL NVARCHAR(MAX);

		-- Create a SQL Server login if it doesn't already exist
		IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Username)
		BEGIN
			DECLARE @EscapedPassword NVARCHAR(200) = REPLACE(@Password, '''', '''''');
			-- Set dynamic SQL for login creation
			SET @SQL = 'CREATE LOGIN [' + @Username + '] WITH PASSWORD = ''' + @EscapedPassword + ''';';
			EXEC sp_executesql @SQL;
		END

		-- Create a database user if it doesn't already exist
		IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Username)
		BEGIN
			-- Set dynamic SQL for user creation
			SET @SQL = 'CREATE USER [' + @Username + '] FOR LOGIN [' + @Username + '];';
			EXEC sp_executesql @SQL;
		END

		-- Assign user to the appropriate database role
		IF LOWER(@Role) = 'ticketing staff'
		BEGIN
			-- Ensure role exists
			IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TicketStaffRole')
				CREATE ROLE TicketStaffRole;

			-- Set dynamic SQL to add user to role
			SET @SQL = 'ALTER ROLE TicketStaffRole ADD MEMBER [' + @Username + '];';
			EXEC sp_executesql @SQL;
		END
		ELSE IF LOWER(@Role) = 'ticketing supervisor'
		BEGIN
			-- Ensure role exists
			IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TicketSupervisorRole')
				CREATE ROLE TicketSupervisorRole;

			-- Set dynamic SQL to add user to role
			SET @SQL = 'ALTER ROLE TicketSupervisorRole ADD MEMBER [' + @Username + '];';
			EXEC sp_executesql @SQL;
		END

		-- Success message
		PRINT 'Employee added and assigned to role successfully.';
	END TRY
	BEGIN CATCH
		-- Catch and display any error
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
END;


		-- Assign user to the appropriate database role
		IF LOWER(@Role) = 'ticketing staff'
		BEGIN
			-- Ensure role exists
			IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TicketStaffRole')
				CREATE ROLE TicketStaffRole;

			-- Add user to role
			DECLARE @SQL NVARCHAR(MAX) = 'ALTER ROLE TicketStaffRole ADD MEMBER [' + @Username + '];';
			EXEC sp_executesql @SQL;
		END
		ELSE IF LOWER(@Role) = 'ticketing supervisor'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TicketSupervisorRole')
				CREATE ROLE TicketSupervisorRole;

			DECLARE @SQL NVARCHAR(MAX) = 'ALTER ROLE TicketSupervisorRole ADD MEMBER [' + @Username + '];';
			EXEC sp_executesql @SQL;
		END

		-- Success message
		PRINT 'Employee added and assigned to role successfully.';
	END TRY
	BEGIN CATCH
		-- Catch and display any error
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
END;

-- let's add a new employee to our table with ticketing staff role
EXEC AddEmployee
    @First_Name = 'Chandan',
    @Middle_Name = 'Neel',
    @Last_Name = 'Navya',
    @Email = 'chandan.navya@yahoomail.com',
    @Username = 'chandannavya',
    @Password = 0x5F4DCC3B5AA765D61D8327DEB882CF17, 
    @Role = 'Ticketing Staff';

-- let's add a ticketing supervisor
EXEC AddEmployee
    @First_Name = 'Daniel',
    @Middle_Name = 'A',
    @Last_Name = 'Summers',
    @Email = 'daniel.summers@yahoomail.com',
    @Username = 'danielsummers',
    @Password = 0x5F4DCC3B5AA765D61D8327DEB882CF14, 
    @Role = 'Ticketing Supervisor';

--=========================================================================================

-- Verify that the login has been created for the user
SELECT name, type_desc
FROM sys.server_principals
WHERE name IN ('chandannavya', 'danielsummers');  

-- Verify that the database user has been created for the user
SELECT name, type_desc
FROM sys.database_principals
WHERE name IN ('chandannavya', 'danielsummers');  

--==================================================================

-- let's verify Employee permision on user 'chandannavya'
EXECUTE AS USER = 'chandannavya';
SELECT * FROM Employees;
REVERT
 
-- let's verify Employee permision on user 'danielsummer'
EXECUTE AS USER = 'danielsummers';
SELECT * FROM Employees;
REVERT

-- Let's grant access to Employee
REVERT -- reverting back to system admin with role permission
 
GRANT SELECT, INSERT, UPDATE ON  Employees TO chandannavya;
 
EXECUTE AS USER = 'chandannavya';
SELECT * FROM Employees;
REVERT

--================================THE END=====================================

