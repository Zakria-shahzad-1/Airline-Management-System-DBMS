CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    manager_id INT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    hire_date DATE NOT NULL,
    employment_status VARCHAR(20) NOT NULL DEFAULT 'Active',

    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id)
);

CREATE TABLE Role (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    role_description VARCHAR(255)
);

CREATE TABLE EmployeeRole (
    employee_role_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_date DATE NOT NULL,

    UNIQUE (employee_id, role_id),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

CREATE TABLE Airport (
    airport_id INT PRIMARY KEY,
    airport_name VARCHAR(150) NOT NULL,
    iata_code CHAR(3) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE Gate (
    gate_id INT PRIMARY KEY,
    airport_id INT NOT NULL,
    gate_number VARCHAR(10) NOT NULL,
    terminal VARCHAR(50),

    UNIQUE (airport_id, gate_number),

    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id)
);

CREATE TABLE Route (
    route_id INT PRIMARY KEY,
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_km DECIMAL(8,2),
    estimated_duration_min INT,

    FOREIGN KEY (origin_airport_id) REFERENCES Airport(airport_id),
    FOREIGN KEY (destination_airport_id) REFERENCES Airport(airport_id),

    CHECK (origin_airport_id <> destination_airport_id)
);

CREATE TABLE Flight (
    flight_id INT PRIMARY KEY,
    route_id INT NOT NULL,
    flight_number VARCHAR(10) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (route_id) REFERENCES Route(route_id)
);

CREATE TABLE Aircraft (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    registration_number VARCHAR(20) NOT NULL UNIQUE,
    total_seats INT NOT NULL,
    year_manufactured SMALLINT
);

CREATE TABLE Seat (
    seat_id INT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class VARCHAR(20) NOT NULL,

    UNIQUE (aircraft_id, seat_number),

    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id)
);

CREATE TABLE FlightSchedule (
    flight_schedule_id INT PRIMARY KEY,
    flight_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    scheduled_departure DATETIME NOT NULL,
    scheduled_arrival DATETIME NOT NULL,
    actual_departure DATETIME,
    actual_arrival DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'Scheduled',

    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id),
  

    CHECK (scheduled_arrival > scheduled_departure)
);

CREATE TABLE Passenger (
    passenger_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(30) NOT NULL UNIQUE,
    nationality VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE Booking (
    booking_id INT PRIMARY KEY,
    booking_date DATETIME NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(30) NOT NULL DEFAULT 'Confirmed'
);

CREATE TABLE Ticket (
    ticket_id INT PRIMARY KEY,
    booking_id INT NOT NULL,
    passenger_id INT NOT NULL,
    flight_schedule_id INT NOT NULL,
    ticket_number VARCHAR(20) NOT NULL UNIQUE,
    ticket_price DECIMAL(10,2) NOT NULL,
    class_type VARCHAR(20) NOT NULL,
    ticket_status VARCHAR(30) NOT NULL DEFAULT 'Active',

    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id),
    FOREIGN KEY (flight_schedule_id) REFERENCES FlightSchedule(flight_schedule_id)
);

CREATE TABLE CheckIn (
    check_in_id INT PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE ,
    check_in_datetime DATETIME NOT NULL,
    check_in_method VARCHAR(30),
    counter_number VARCHAR(10),

   FOREIGN KEY (ticket_id)
   REFERENCES Ticket(ticket_id)
);

CREATE TABLE Boarding (
    boarding_id INT PRIMARY KEY,
    ticket_id INT NOT NULL,
    boarding_datetime DATETIME NOT NULL,
    boarding_status VARCHAR(30) NOT NULL,

    FOREIGN KEY (ticket_id)
    REFERENCES CheckIn(ticket_id)
);

CREATE TABLE Connections (
    connection_id INT PRIMARY KEY,
    connection_name VARCHAR(100) NOT NULL,
    connection_type VARCHAR(50),
    total_layover_duration_min INT
);

CREATE TABLE ConnectionSegment (
    connection_segment_id INT PRIMARY KEY,
    connection_id INT NOT NULL,
    flight_schedule_id INT NOT NULL,
    segment_order INT NOT NULL,

    UNIQUE (connection_id, flight_schedule_id),

    FOREIGN KEY (connection_id) REFERENCES Connections(connection_id),
    FOREIGN KEY (flight_schedule_id) REFERENCES FlightSchedule(flight_schedule_id),

    CHECK (segment_order > 0)
);

CREATE TABLE MaintenanceType (
    maintenance_type_id INT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    type_description VARCHAR(255)
);

CREATE TABLE MaintenanceEvent (
    maintenance_event_id INT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    event_date DATE NOT NULL,
    completion_date DATE,
    event_description VARCHAR(255),
    status VARCHAR(30) NOT NULL,

    FOREIGN KEY (maintenance_type_id) REFERENCES MaintenanceType(maintenance_type_id),
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id),
    CHECK (completion_date IS NULL OR completion_date >= event_date)
);

CREATE TABLE MaintenanceAssignment (
    maintenance_assignment_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    maintenance_event_id INT NOT NULL,
    assigned_date DATE NOT NULL,

    UNIQUE (employee_id, maintenance_event_id),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (maintenance_event_id) REFERENCES MaintenanceEvent(maintenance_event_id)
);



CREATE TABLE FlightCrewAssignment (
    flight_crew_assignment_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    flight_schedule_id INT NOT NULL,
    crew_role VARCHAR(50),
    assigned_date DATE NOT NULL,

    UNIQUE (employee_id, flight_schedule_id),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (flight_schedule_id) REFERENCES FlightSchedule(flight_schedule_id)
);

CREATE TABLE SeatAssignment (
    seat_assignment_id INT PRIMARY KEY,
    seat_id INT NOT NULL,
    ticket_id INT NOT NULL,
    flight_schedule_id INT NOT NULL,
    assignment_datetime DATETIME,

    UNIQUE (seat_id, flight_schedule_id),

    FOREIGN KEY (seat_id) REFERENCES Seat(seat_id),
    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id),
    FOREIGN KEY (flight_schedule_id) REFERENCES FlightSchedule(flight_schedule_id)
);

CREATE TABLE Baggage (
    baggage_id INT PRIMARY KEY,
    check_in_id INT NOT NULL,
    weight_kg DECIMAL(5,2) NOT NULL,
    baggage_type VARCHAR(30),
    baggage_tag_number VARCHAR(30) UNIQUE,
    baggage_status VARCHAR(20) NOT NULL,


    FOREIGN KEY (check_in_id) REFERENCES CheckIn(check_in_id),


    CHECK (weight_kg > 0)
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_datetime DATETIME NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,

    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),

    CHECK (payment_amount > 0)
);

CREATE TABLE Invoice (
    invoice_id INT PRIMARY KEY,
    payment_id INT NOT NULL UNIQUE,
    invoice_date DATE NOT NULL,
    invoice_amount DECIMAL(10,2) NOT NULL,
    billing_address VARCHAR(255),
    invoice_status VARCHAR(30) NOT NULL,

    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id),

    CHECK (invoice_amount > 0)
);

CREATE TABLE BookingPassenger (
    booking_id INT,
    passenger_id INT,

    PRIMARY KEY (booking_id, passenger_id),

    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
);

  

ALTER TABLE Aircraft
ADD is_active BIT NOT NULL DEFAULT 1;

-- 1. ROLE (Master - 20 Records)
INSERT INTO Role (role_id, role_name, role_description) VALUES 
(1, 'Captain', 'Pilot in command of the aircraft'),
(2, 'First Officer', 'Co-pilot of the aircraft'),
(3, 'Lead Cabin Crew', 'In-charge of flight attendants'),
(4, 'Flight Attendant', 'Cabin crew member'),
(5, 'Dispatcher', 'Flight planning and dispatch operations'),
(6, 'Gate Agent', 'Boarding and passenger assistance at gate'),
(7, 'Ticketing Agent', 'Sales, booking, and ticketing'),
(8, 'Baggage Handler', 'Loading and unloading baggage'),
(9, 'Maintenance Manager', 'Oversees aircraft maintenance'),
(10, 'Aviation Mechanic', 'Aircraft repair and line maintenance'),
(11, 'Avionics Technician', 'Electronics and navigation systems repair'),
(12, 'Air Traffic Controller', 'Coordinates ground and air traffic'),
(13, 'Ramp Agent', 'Ground operations and marshalling'),
(14, 'Customer Service Rep', 'General passenger queries and support'),
(15, 'Flight Operations Manager', 'Manages flight schedules and ops'),
(16, 'Crew Scheduler', 'Manages crew rotations and duty times'),
(17, 'Safety Inspector', 'Ensures compliance with safety regulations'),
(18, 'Catering Coordinator', 'Manages in-flight meals and supplies'),
(19, 'Ground Equipment Mechanic', 'Maintains airport support vehicles'),
(20, 'Station Manager', 'Overall airport station operations');

-- 2. EMPLOYEE (Master - 25 Records)
INSERT INTO Employee (employee_id, manager_id, first_name, last_name, email, phone, date_of_birth, hire_date, employment_status) VALUES 
(1, NULL, 'Tariq', 'Mehmood', 'tariq.m@airline.com', '0300-1111111', '1975-04-12', '2005-01-15', 'Active'),
(2, 1, 'Ali', 'Khan', 'ali.k@airline.com', '0300-2222222', '1980-08-22', '2010-03-01', 'Active'),
(3, 1, 'Ayesha', 'Siddiqa', 'ayesha.s@airline.com', '0300-3333333', '1982-11-05', '2012-06-15', 'Active'),
(4, 2, 'Bilal', 'Ahmed', 'bilal.a@airline.com', '0300-4444444', '1990-02-14', '2015-09-20', 'Active'),
(5, 2, 'Fatima', 'Noor', 'fatima.n@airline.com', '0300-5555555', '1985-07-30', '2014-11-10', 'On Leave'),
(6, 3, 'Usman', 'Tariq', 'usman.t@airline.com', '0300-6666666', '1992-05-18', '2018-01-05', 'Active'),
(7, 3, 'Zainab', 'Ali', 'zainab.a@airline.com', '0300-7777777', '1988-09-25', '2016-04-12', 'Active'),
(8, 1, 'Hassan', 'Raza', 'hassan.r@airline.com', '0300-8888888', '1979-12-01', '2008-08-08', 'Active'),
(9, 8, 'Sana', 'Javed', 'sana.j@airline.com', '0300-9999999', '1983-03-17', '2011-05-22', 'Active'),
(10, 8, 'Omar', 'Farooq', 'omar.f@airline.com', '0301-1111111', '1995-10-10', '2020-02-14', 'Active'),
(11, 2, 'Kamran', 'Akmal', 'kamran.a@airline.com', '0301-2222222', '1987-01-20', '2013-07-07', 'Active'),
(12, 3, 'John', 'Smith', 'jsmith@airline.com', '0301-3333333', '1991-04-04', '2017-09-09', 'Active'),
(13, 1, 'David', 'Miller', 'dmiller@airline.com', '0301-4444444', '1986-12-12', '2019-11-11', 'Active'),
(14, 2, 'Sarah', 'Connor', 'sconnor@airline.com', '0301-5555555', '1993-06-30', '2021-03-15', 'Active'),
(15, 3, 'Saad', 'Hussain', 'saad.h@airline.com', '0301-6666666', '1989-08-14', '2014-08-14', 'Active'),
(16, 8, 'Nida', 'Yasir', 'nida.y@airline.com', '0301-7777777', '1994-02-28', '2022-01-10', 'Active'),
(17, 8, 'Imran', 'Nazir', 'imran.n@airline.com', '0301-8888888', '1981-11-11', '2009-10-10', 'Active'),
(18, 2, 'Michael', 'Johnson', 'mjohnson@airline.com', '0301-9999999', '1978-05-05', '2006-06-06', 'Active'),
(19, 3, 'Maryam', 'Nawaz', 'maryam.n@airline.com', '0302-1111111', '1996-07-07', '2023-05-01', 'Active'),
(20, 8, 'Hamza', 'Ali', 'hamza.a@airline.com', '0302-2222222', '1998-12-25', '2024-01-01', 'Active'),
(21, 2, 'Waqar', 'Younis', 'waqar.y@airline.com', '0302-3333333', '1976-03-03', '2004-04-04', 'Active'),
(22, 3, 'Shoaib', 'Akhtar', 'shoaib.a@airline.com', '0302-4444444', '1980-10-10', '2010-10-10', 'Active'),
(23, 8, 'Emily', 'Clark', 'eclark@airline.com', '0302-5555555', '1990-01-01', '2018-08-08', 'Active'),
(24, 2, 'Fahad', 'Mustafa', 'fahad.m@airline.com', '0302-6666666', '1985-09-09', '2016-06-16', 'Active'),
(25, 3, 'Mahira', 'Khan', 'mahira.k@airline.com', '0302-7777777', '1988-12-21', '2019-02-02', 'Active');

-- 3. EMPLOYEEROLE (Detail - 50 Records)
-- Generating 50 unique employee-role combinations
INSERT INTO EmployeeRole (employee_role_id, employee_id, role_id, assigned_date) VALUES 
(1, 1, 15, '2005-01-20'), (2, 2, 1, '2010-03-10'), (3, 3, 3, '2012-06-20'), (4, 4, 2, '2015-09-25'), (5, 5, 4, '2014-11-15'),
(6, 6, 2, '2018-01-10'), (7, 7, 4, '2016-04-15'), (8, 8, 9, '2008-08-10'), (9, 9, 10, '2011-05-25'), (10, 10, 11, '2020-02-20'),
(11, 11, 1, '2013-07-10'), (12, 12, 12, '2017-09-15'), (13, 13, 5, '2019-11-15'), (14, 14, 6, '2021-03-20'), (15, 15, 7, '2014-08-20'),
(16, 16, 14, '2022-01-15'), (17, 17, 13, '2009-10-15'), (18, 18, 1, '2006-06-10'), (19, 19, 4, '2023-05-05'), (20, 20, 8, '2024-01-05'),
(21, 21, 1, '2004-04-10'), (22, 22, 10, '2010-10-15'), (23, 23, 14, '2018-08-10'), (24, 24, 7, '2016-06-20'), (25, 25, 4, '2019-02-05'),
(26, 2, 17, '2015-01-01'), (27, 3, 16, '2016-01-01'), (28, 4, 1, '2020-01-01'), (29, 6, 1, '2022-01-01'), (30, 8, 20, '2015-01-01'),
(31, 1, 1, '2005-01-15'), (32, 2, 2, '2010-03-01'), (33, 3, 4, '2012-06-15'), (34, 4, 17, '2016-09-20'), (35, 5, 3, '2015-11-10'),
(36, 6, 17, '2019-01-05'), (37, 7, 3, '2017-04-12'), (38, 8, 10, '2009-08-08'), (39, 9, 11, '2012-05-22'), (40, 10, 10, '2021-02-14'),
(41, 11, 2, '2014-07-07'), (42, 12, 5, '2018-09-09'), (43, 13, 12, '2020-11-11'), (44, 14, 7, '2022-03-15'), (45, 15, 6, '2015-08-14'),
(46, 16, 13, '2023-01-10'), (47, 17, 8, '2010-10-10'), (48, 18, 2, '2007-06-06'), (49, 19, 3, '2024-05-01'), (50, 20, 13, '2024-02-01');

-- 4. AIRPORT (Master - 20 Records)
INSERT INTO Airport (airport_id, airport_name, iata_code, city, country) VALUES 
(1, 'Jinnah International Airport', 'KHI', 'Karachi', 'Pakistan'),
(2, 'Allama Iqbal International Airport', 'LHE', 'Lahore', 'Pakistan'),
(3, 'Islamabad International Airport', 'ISB', 'Islamabad', 'Pakistan'),
(4, 'Bacha Khan International Airport', 'PEW', 'Peshawar', 'Pakistan'),
(5, 'Multan International Airport', 'MUX', 'Multan', 'Pakistan'),
(6, 'Quetta International Airport', 'UET', 'Quetta', 'Pakistan'),
(7, 'Faisalabad International Airport', 'LYP', 'Faisalabad', 'Pakistan'),
(8, 'Sialkot International Airport', 'SKT', 'Sialkot', 'Pakistan'),
(9, 'Gwadar International Airport', 'GWD', 'Gwadar', 'Pakistan'),
(10, 'Skardu International Airport', 'KDU', 'Skardu', 'Pakistan'),
(11, 'Dubai International Airport', 'DXB', 'Dubai', 'United Arab Emirates'),
(12, 'King Abdulaziz International Airport', 'JED', 'Jeddah', 'Saudi Arabia'),
(13, 'Heathrow Airport', 'LHR', 'London', 'United Kingdom'),
(14, 'John F. Kennedy International Airport', 'JFK', 'New York', 'USA'),
(15, 'Hamad International Airport', 'DOH', 'Doha', 'Qatar'),
(16, 'Istanbul Airport', 'IST', 'Istanbul', 'Turkey'),
(17, 'Toronto Pearson International Airport', 'YYZ', 'Toronto', 'Canada'),
(18, 'Kuala Lumpur International Airport', 'KUL', 'Kuala Lumpur', 'Malaysia'),
(19, 'Beijing Capital International Airport', 'PEK', 'Beijing', 'China'),
(20, 'Sydney Kingsford Smith Airport', 'SYD', 'Sydney', 'Australia');

-- 5. GATE (Detail - 50 Records)
INSERT INTO Gate (gate_id, airport_id, gate_number, terminal) VALUES 
(1, 1, 'G1', 'Terminal 1'), (2, 1, 'G2', 'Terminal 1'), (3, 1, 'G3', 'Terminal 2'), (4, 1, 'G4', 'Terminal 2'), (5, 1, 'G5', 'Terminal M'),
(6, 2, 'G1', 'Main Terminal'), (7, 2, 'G2', 'Main Terminal'), (8, 2, 'G3', 'Main Terminal'), (9, 2, 'G4', 'Hajj Terminal'), (10, 2, 'G5', 'Hajj Terminal'),
(11, 3, 'G1', 'Terminal 1'), (12, 3, 'G2', 'Terminal 1'), (13, 3, 'G3', 'Terminal 1'), (14, 3, 'G4', 'Terminal 1'), (15, 3, 'G5', 'Terminal 1'),
(16, 4, 'G1', 'Main'), (17, 4, 'G2', 'Main'), (18, 4, 'G3', 'Main'), (19, 4, 'G4', 'Main'), (20, 4, 'G5', 'Main'),
(21, 5, 'G1', 'Terminal 1'), (22, 5, 'G2', 'Terminal 1'), (23, 5, 'G3', 'Terminal 1'), (24, 6, 'G1', 'Main'), (25, 6, 'G2', 'Main'),
(26, 7, 'G1', 'Terminal 1'), (27, 7, 'G2', 'Terminal 1'), (28, 8, 'G1', 'Terminal 1'), (29, 8, 'G2', 'Terminal 1'), (30, 9, 'G1', 'Main'),
(31, 10, 'G1', 'Main'), (32, 11, 'G1', 'Terminal 1'), (33, 11, 'G2', 'Terminal 3'), (34, 11, 'G3', 'Terminal 3'), (35, 12, 'G1', 'South Terminal'),
(36, 12, 'G2', 'North Terminal'), (37, 13, 'G1', 'Terminal 2'), (38, 13, 'G2', 'Terminal 5'), (39, 14, 'G1', 'Terminal 4'), (40, 14, 'G2', 'Terminal 4'),
(41, 15, 'G1', 'Main'), (42, 15, 'G2', 'Main'), (43, 16, 'G1', 'Main'), (44, 16, 'G2', 'Main'), (45, 17, 'G1', 'Terminal 1'),
(46, 17, 'G2', 'Terminal 1'), (47, 18, 'G1', 'Main'), (48, 19, 'G1', 'Terminal 3'), (49, 20, 'G1', 'Terminal 1'), (50, 20, 'G2', 'Terminal 1');

-- 6. ROUTE (Detail - 50 Records)
INSERT INTO Route (route_id, origin_airport_id, destination_airport_id, distance_km, estimated_duration_min) VALUES 
(1, 1, 2, 1020.50, 105), (2, 2, 1, 1020.50, 105), (3, 1, 3, 1130.00, 120), (4, 3, 1, 1130.00, 120), (5, 2, 3, 270.00, 45),
(6, 3, 2, 270.00, 45), (7, 1, 4, 1090.00, 115), (8, 4, 1, 1090.00, 115), (9, 2, 4, 380.00, 60), (10, 4, 2, 380.00, 60),
(11, 1, 5, 730.00, 85), (12, 5, 1, 730.00, 85), (13, 1, 6, 590.00, 75), (14, 6, 1, 590.00, 75), (15, 3, 10, 290.00, 50),
(16, 10, 3, 290.00, 50), (17, 1, 11, 1180.00, 130), (18, 11, 1, 1180.00, 130), (19, 2, 11, 1980.00, 200), (20, 11, 2, 1980.00, 200),
(21, 3, 11, 1930.00, 195), (22, 11, 3, 1930.00, 195), (23, 1, 12, 2850.00, 260), (24, 12, 1, 2850.00, 260), (25, 2, 12, 3500.00, 300),
(26, 12, 2, 3500.00, 300), (27, 3, 13, 6040.00, 480), (28, 13, 3, 6040.00, 480), (29, 2, 13, 6300.00, 500), (30, 13, 2, 6300.00, 500),
(31, 1, 14, 11680.00, 850), (32, 14, 1, 11680.00, 850), (33, 2, 17, 11200.00, 820), (34, 17, 2, 11200.00, 820), (35, 1, 15, 1560.00, 150),
(36, 15, 1, 1560.00, 150), (37, 2, 16, 4170.00, 350), (38, 16, 2, 4170.00, 350), (39, 1, 18, 4420.00, 360), (40, 18, 1, 4420.00, 360),
(41, 3, 19, 3860.00, 320), (42, 19, 3, 3860.00, 320), (43, 2, 14, 11300.00, 830), (44, 14, 2, 11300.00, 830), (45, 1, 16, 3950.00, 330),
(46, 16, 1, 3950.00, 330), (47, 3, 12, 3580.00, 310), (48, 12, 3, 3580.00, 310), (49, 1, 20, 10980.00, 800), (50, 20, 1, 10980.00, 800);

-- 7. FLIGHT (Detail - 50 Records)
INSERT INTO Flight (flight_id, route_id, flight_number, airline_name, base_price) VALUES 
(1, 1, 'PK302', 'Pakistan International Airlines', 15000.00), (2, 2, 'PK303', 'Pakistan International Airlines', 15000.00), 
(3, 3, 'PK300', 'Pakistan International Airlines', 18000.00), (4, 4, 'PK301', 'Pakistan International Airlines', 18000.00), 
(5, 5, 'PA401', 'Airblue', 10000.00), (6, 6, 'PA402', 'Airblue', 10000.00), 
(7, 7, 'ER501', 'SereneAir', 16000.00), (8, 8, 'ER502', 'SereneAir', 16000.00), 
(9, 9, '9P601', 'Fly Jinnah', 9000.00), (10, 10, '9P602', 'Fly Jinnah', 9000.00), 
(11, 11, 'PK330', 'Pakistan International Airlines', 12000.00), (12, 12, 'PK331', 'Pakistan International Airlines', 12000.00), 
(13, 13, 'PA410', 'Airblue', 11000.00), (14, 14, 'PA411', 'Airblue', 11000.00), 
(15, 15, 'PK451', 'Pakistan International Airlines', 14000.00), (16, 16, 'PK452', 'Pakistan International Airlines', 14000.00), 
(17, 17, 'EK600', 'Emirates', 45000.00), (18, 18, 'EK601', 'Emirates', 45000.00), 
(19, 19, 'EK622', 'Emirates', 55000.00), (20, 20, 'EK623', 'Emirates', 55000.00), 
(21, 21, 'PA210', 'Airblue', 40000.00), (22, 22, 'PA211', 'Airblue', 40000.00), 
(23, 23, 'SV700', 'Saudia', 60000.00), (24, 24, 'SV701', 'Saudia', 60000.00), 
(25, 25, 'SV734', 'Saudia', 65000.00), (26, 26, 'SV735', 'Saudia', 65000.00), 
(27, 27, 'BA260', 'British Airways', 120000.00), (28, 28, 'BA261', 'British Airways', 120000.00), 
(29, 29, 'PK757', 'Pakistan International Airlines', 110000.00), (30, 30, 'PK758', 'Pakistan International Airlines', 110000.00), 
(31, 31, 'PK711', 'Pakistan International Airlines', 180000.00), (32, 32, 'PK712', 'Pakistan International Airlines', 180000.00), 
(33, 33, 'PK789', 'Pakistan International Airlines', 190000.00), (34, 34, 'PK790', 'Pakistan International Airlines', 190000.00), 
(35, 35, 'QR604', 'Qatar Airways', 50000.00), (36, 36, 'QR605', 'Qatar Airways', 50000.00), 
(37, 37, 'TK714', 'Turkish Airlines', 85000.00), (38, 38, 'TK715', 'Turkish Airlines', 85000.00), 
(39, 39, 'MH152', 'Malaysia Airlines', 75000.00), (40, 40, 'MH153', 'Malaysia Airlines', 75000.00), 
(41, 41, 'CA945', 'Air China', 95000.00), (42, 42, 'CA946', 'Air China', 95000.00), 
(43, 43, 'EK630', 'Emirates', 170000.00), (44, 44, 'EK631', 'Emirates', 170000.00), 
(45, 45, 'TK708', 'Turkish Airlines', 82000.00), (46, 46, 'TK709', 'Turkish Airlines', 82000.00), 
(47, 47, 'SV720', 'Saudia', 62000.00), (48, 48, 'SV721', 'Saudia', 62000.00), 
(49, 49, 'PK800', 'Pakistan International Airlines', 160000.00), (50, 50, 'PK801', 'Pakistan International Airlines', 160000.00);

-- 8. AIRCRAFT (Master - 20 Records)
INSERT INTO Aircraft (aircraft_id, model, manufacturer, registration_number, total_seats, year_manufactured, is_active) VALUES 
(1, 'A320-200', 'Airbus', 'AP-BLA', 160, 2010, 1), (2, 'A320-200', 'Airbus', 'AP-BLB', 160, 2012, 1),
(3, 'A320-200', 'Airbus', 'AP-BLC', 160, 2014, 1), (4, 'B777-200ER', 'Boeing', 'AP-BGJ', 320, 2005, 1),
(5, 'B777-200ER', 'Boeing', 'AP-BGK', 320, 2006, 1), (6, 'B777-300ER', 'Boeing', 'AP-BID', 380, 2008, 1),
(7, 'A321neo', 'Airbus', 'AP-BOM', 210, 2021, 1), (8, 'A321neo', 'Airbus', 'AP-BON', 210, 2022, 1),
(9, 'B737-800', 'Boeing', 'AP-BPA', 180, 2015, 1), (10, 'B737-800', 'Boeing', 'AP-BPB', 180, 2016, 1),
(11, 'ATR 42-500', 'ATR', 'AP-BHI', 48, 2007, 1), (12, 'ATR 72-500', 'ATR', 'AP-BKP', 70, 2011, 1),
(13, 'A330-200', 'Airbus', 'A6-EAA', 260, 2013, 1), (14, 'A380-800', 'Airbus', 'A6-EEA', 500, 2017, 1),
(15, 'B787-9', 'Boeing', 'HZ-ARA', 290, 2018, 1), (16, 'A350-900', 'Airbus', 'A7-ALA', 280, 2019, 1),
(17, 'B777-300ER', 'Boeing', 'TC-JJA', 350, 2014, 1), (18, 'A320-200', 'Airbus', 'AP-EDA', 160, 2010, 1),
(19, 'A320-200', 'Airbus', 'AP-EDB', 160, 2011, 1), (20, 'B777-200ER', 'Boeing', 'G-YMMB', 270, 2004, 1);

-- 9. SEAT (Detail - 50 Records)
-- Generating 5 seats for the first 10 aircraft to reach 50 records
INSERT INTO Seat (seat_id, aircraft_id, seat_number, seat_class) VALUES 
(1, 1, '1A', 'Business'), (2, 1, '1B', 'Business'), (3, 1, '10A', 'Economy'), (4, 1, '10B', 'Economy'), (5, 1, '10C', 'Economy'),
(6, 2, '1A', 'Business'), (7, 2, '1B', 'Business'), (8, 2, '10A', 'Economy'), (9, 2, '10B', 'Economy'), (10, 2, '10C', 'Economy'),
(11, 3, '1A', 'Business'), (12, 3, '1B', 'Business'), (13, 3, '10A', 'Economy'), (14, 3, '10B', 'Economy'), (15, 3, '10C', 'Economy'),
(16, 4, '1A', 'First'), (17, 4, '1B', 'First'), (18, 4, '12A', 'Economy'), (19, 4, '12B', 'Economy'), (20, 4, '12C', 'Economy'),
(21, 5, '1A', 'First'), (22, 5, '1B', 'First'), (23, 5, '12A', 'Economy'), (24, 5, '12B', 'Economy'), (25, 5, '12C', 'Economy'),
(26, 6, '1A', 'Business'), (27, 6, '1B', 'Business'), (28, 6, '20A', 'Economy'), (29, 6, '20B', 'Economy'), (30, 6, '20C', 'Economy'),
(31, 7, '1A', 'Business'), (32, 7, '1B', 'Business'), (33, 7, '15A', 'Economy'), (34, 7, '15B', 'Economy'), (35, 7, '15C', 'Economy'),
(36, 8, '1A', 'Business'), (37, 8, '1B', 'Business'), (38, 8, '15A', 'Economy'), (39, 8, '15B', 'Economy'), (40, 8, '15C', 'Economy'),
(41, 9, '1A', 'Business'), (42, 9, '1B', 'Business'), (43, 9, '11A', 'Economy'), (44, 9, '11B', 'Economy'), (45, 9, '11C', 'Economy'),
(46, 10, '1A', 'Business'), (47, 10, '1B', 'Business'), (48, 10, '11A', 'Economy'), (49, 10, '11B', 'Economy'), (50, 10, '11C', 'Economy');

-- 10. FLIGHTSCHEDULE (Detail - 50 Records)
INSERT INTO FlightSchedule (flight_schedule_id, flight_id, aircraft_id, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, status) VALUES 
(1, 1, 1, '2024-06-01 08:00:00', '2024-06-01 09:45:00', '2024-06-01 08:05:00', '2024-06-01 09:50:00', 'Completed'),
(2, 2, 2, '2024-06-01 10:30:00', '2024-06-01 12:15:00', '2024-06-01 10:30:00', '2024-06-01 12:10:00', 'Completed'),
(3, 3, 3, '2024-06-01 14:00:00', '2024-06-01 16:00:00', NULL, NULL, 'Scheduled'),
(4, 4, 1, '2024-06-02 09:00:00', '2024-06-02 11:00:00', NULL, NULL, 'Scheduled'),
(5, 5, 7, '2024-06-02 15:00:00', '2024-06-02 15:45:00', NULL, NULL, 'Scheduled'),
(6, 6, 8, '2024-06-03 07:00:00', '2024-06-03 07:45:00', NULL, NULL, 'Scheduled'),
(7, 7, 9, '2024-06-03 18:00:00', '2024-06-03 19:55:00', NULL, NULL, 'Scheduled'),
(8, 8, 10, '2024-06-04 11:00:00', '2024-06-04 12:55:00', NULL, NULL, 'Scheduled'),
(9, 9, 2, '2024-06-04 16:00:00', '2024-06-04 17:00:00', NULL, NULL, 'Scheduled'),
(10, 10, 3, '2024-06-05 08:30:00', '2024-06-05 09:30:00', NULL, NULL, 'Scheduled'),
(11, 11, 4, '2024-06-05 20:00:00', '2024-06-05 21:25:00', NULL, NULL, 'Scheduled'),
(12, 12, 5, '2024-06-06 06:00:00', '2024-06-06 07:25:00', NULL, NULL, 'Scheduled'),
(13, 13, 1, '2024-06-06 13:00:00', '2024-06-06 14:15:00', NULL, NULL, 'Scheduled'),
(14, 14, 2, '2024-06-07 17:30:00', '2024-06-07 18:45:00', NULL, NULL, 'Scheduled'),
(15, 15, 11, '2024-06-07 09:00:00', '2024-06-07 09:50:00', NULL, NULL, 'Scheduled'),
(16, 16, 12, '2024-06-08 12:00:00', '2024-06-08 12:50:00', NULL, NULL, 'Scheduled'),
(17, 17, 13, '2024-06-08 22:00:00', '2024-06-09 00:10:00', NULL, NULL, 'Scheduled'),
(18, 18, 14, '2024-06-09 03:00:00', '2024-06-09 05:10:00', NULL, NULL, 'Scheduled'),
(19, 19, 13, '2024-06-09 10:00:00', '2024-06-09 13:20:00', NULL, NULL, 'Scheduled'),
(20, 20, 14, '2024-06-10 15:00:00', '2024-06-10 18:20:00', NULL, NULL, 'Scheduled'),
(21, 21, 7, '2024-06-10 08:00:00', '2024-06-10 11:15:00', NULL, NULL, 'Scheduled'),
(22, 22, 8, '2024-06-11 13:00:00', '2024-06-11 16:15:00', NULL, NULL, 'Scheduled'),
(23, 23, 15, '2024-06-11 19:00:00', '2024-06-11 23:20:00', NULL, NULL, 'Scheduled'),
(24, 24, 15, '2024-06-12 02:00:00', '2024-06-12 06:20:00', NULL, NULL, 'Scheduled'),
(25, 25, 15, '2024-06-12 11:00:00', '2024-06-12 16:00:00', NULL, NULL, 'Scheduled'),
(26, 26, 15, '2024-06-13 18:00:00', '2024-06-13 23:00:00', NULL, NULL, 'Scheduled'),
(27, 27, 20, '2024-06-13 01:00:00', '2024-06-13 09:00:00', NULL, NULL, 'Scheduled'),
(28, 28, 20, '2024-06-14 12:00:00', '2024-06-14 20:00:00', NULL, NULL, 'Scheduled'),
(29, 29, 6, '2024-06-14 06:00:00', '2024-06-14 14:20:00', NULL, NULL, 'Scheduled'),
(30, 30, 6, '2024-06-15 16:00:00', '2024-06-16 00:20:00', NULL, NULL, 'Scheduled'),
(31, 31, 4, '2024-06-15 03:00:00', '2024-06-15 17:10:00', NULL, NULL, 'Scheduled'),
(32, 32, 5, '2024-06-16 19:00:00', '2024-06-17 09:10:00', NULL, NULL, 'Scheduled'),
(33, 33, 4, '2024-06-16 05:00:00', '2024-06-16 18:40:00', NULL, NULL, 'Scheduled'),
(34, 34, 5, '2024-06-17 21:00:00', '2024-06-18 10:40:00', NULL, NULL, 'Scheduled'),
(35, 35, 16, '2024-06-17 10:00:00', '2024-06-17 12:30:00', NULL, NULL, 'Scheduled'),
(36, 36, 16, '2024-06-18 14:00:00', '2024-06-18 16:30:00', NULL, NULL, 'Scheduled'),
(37, 37, 17, '2024-06-18 20:00:00', '2024-06-19 01:50:00', NULL, NULL, 'Scheduled'),
(38, 38, 17, '2024-06-19 04:00:00', '2024-06-19 09:50:00', NULL, NULL, 'Scheduled'),
(39, 39, 18, '2024-06-19 11:00:00', '2024-06-19 17:00:00', NULL, NULL, 'Scheduled'),
(40, 40, 19, '2024-06-20 19:00:00', '2024-06-21 01:00:00', NULL, NULL, 'Scheduled'),
(41, 41, 1, '2024-06-20 07:00:00', '2024-06-20 12:20:00', NULL, NULL, 'Scheduled'),
(42, 42, 2, '2024-06-21 14:00:00', '2024-06-21 19:20:00', NULL, NULL, 'Scheduled'),
(43, 43, 14, '2024-06-21 22:00:00', '2024-06-22 11:50:00', NULL, NULL, 'Scheduled'),
(44, 44, 13, '2024-06-22 14:00:00', '2024-06-23 03:50:00', NULL, NULL, 'Scheduled'),
(45, 45, 17, '2024-06-22 09:00:00', '2024-06-22 14:30:00', NULL, NULL, 'Scheduled'),
(46, 46, 17, '2024-06-23 16:00:00', '2024-06-23 21:30:00', NULL, NULL, 'Scheduled'),
(47, 47, 15, '2024-06-23 05:00:00', '2024-06-23 10:10:00', NULL, NULL, 'Scheduled'),
(48, 48, 15, '2024-06-24 12:00:00', '2024-06-24 17:10:00', NULL, NULL, 'Scheduled'),
(49, 49, 6, '2024-06-24 18:00:00', '2024-06-25 07:20:00', NULL, NULL, 'Scheduled'),
(50, 50, 6, '2024-06-25 09:00:00', '2024-06-25 22:20:00', NULL, NULL, 'Scheduled');

-- 11. PASSENGER (Master - 30 Records)
INSERT INTO Passenger (passenger_id, first_name, last_name, passport_number, nationality, date_of_birth, email, phone) VALUES 
(1, 'Salman', 'Khan', 'PK1111222', 'Pakistani', '1985-05-15', 'salman.k@mail.com', '0321-1111111'),
(2, 'Mahnoor', 'Baloch', 'PK2222333', 'Pakistani', '1990-08-20', 'mahnoor.b@mail.com', '0321-2222222'),
(3, 'Fawad', 'Khan', 'PK3333444', 'Pakistani', '1982-11-29', 'fawad.k@mail.com', '0321-3333333'),
(4, 'Sajal', 'Ali', 'PK4444555', 'Pakistani', '1994-01-17', 'sajal.a@mail.com', '0321-4444444'),
(5, 'Atif', 'Aslam', 'PK5555666', 'Pakistani', '1983-03-12', 'atif.a@mail.com', '0321-5555555'),
(6, 'Mehwish', 'Hayat', 'PK6666777', 'Pakistani', '1988-01-06', 'mehwish.h@mail.com', '0321-6666666'),
(7, 'Humayun', 'Saeed', 'PK7777888', 'Pakistani', '1971-05-09', 'humayun.s@mail.com', '0321-7777888'),
(8, 'Ayeza', 'Khan', 'PK8888999', 'Pakistani', '1991-01-15', 'ayeza.k@mail.com', '0321-8888999'),
(9, 'Babar', 'Azam', 'PK9999000', 'Pakistani', '1994-10-15', 'babar.a@mail.com', '0321-9999000'),
(10, 'Shaheen', 'Afridi', 'PK1010101', 'Pakistani', '2000-04-06', 'shaheen.a@mail.com', '0321-1010101'),
(11, 'Robert', 'Downey', 'US1234567', 'American', '1965-04-04', 'rdj@mail.com', '+1-555-0101'),
(12, 'Emma', 'Watson', 'UK9876543', 'British', '1990-04-15', 'emma.w@mail.com', '+44-555-0102'),
(13, 'Chris', 'Hemsworth', 'AU1122334', 'Australian', '1983-08-11', 'chris.h@mail.com', '+61-555-0103'),
(14, 'Scarlett', 'Johansson', 'US2233445', 'American', '1984-11-22', 'scarlett.j@mail.com', '+1-555-0104'),
(15, 'Liam', 'Neeson', 'IE3344556', 'Irish', '1952-06-07', 'liam.n@mail.com', '+353-555-0105'),
(16, 'Adnan', 'Siddiqui', 'PK1212121', 'Pakistani', '1969-10-23', 'adnan.s@mail.com', '0333-1111111'),
(17, 'Hira', 'Mani', 'PK1313131', 'Pakistani', '1989-02-27', 'hira.m@mail.com', '0333-2222222'),
(18, 'Ahad', 'Raza', 'PK1414141', 'Pakistani', '1993-09-29', 'ahad.r@mail.com', '0333-3333333'),
(19, 'Iqra', 'Aziz', 'PK1515151', 'Pakistani', '1997-11-24', 'iqra.a@mail.com', '0333-4444444'),
(20, 'Feroze', 'Khan', 'PK1616161', 'Pakistani', '1990-07-11', 'feroze.k@mail.com', '0333-5555555'),
(21, 'Alizeh', 'Shah', 'PK1717171', 'Pakistani', '2000-06-09', 'alizeh.s@mail.com', '0333-6666666'),
(22, 'Imran', 'Abbas', 'PK1818181', 'Pakistani', '1982-10-15', 'imran.ab@mail.com', '0333-7777777'),
(23, 'Hania', 'Aamir', 'PK1919191', 'Pakistani', '1997-02-12', 'hania.a@mail.com', '0333-8888888'),
(24, 'Asim', 'Azhar', 'PK2020202', 'Pakistani', '1996-10-29', 'asim.a@mail.com', '0333-9999999'),
(25, 'Momina', 'Mustehsan', 'PK2121212', 'Pakistani', '1992-09-05', 'momina.m@mail.com', '0334-1111111'),
(26, 'Ali', 'Zafar', 'PK2222222', 'Pakistani', '1980-05-18', 'ali.z@mail.com', '0334-2222222'),
(27, 'Tom', 'Cruise', 'US9988776', 'American', '1962-07-03', 'tom.c@mail.com', '+1-555-0106'),
(28, 'Zendaya', 'Coleman', 'US8877665', 'American', '1996-09-01', 'zendaya@mail.com', '+1-555-0107'),
(29, 'Shahrukh', 'Khan', 'IN1122334', 'Indian', '1965-11-02', 'srk@mail.com', '+91-555-0108'),
(30, 'Deepika', 'Padukone', 'IN2233445', 'Indian', '1986-01-05', 'deepika.p@mail.com', '+91-555-0109');

-- 12. BOOKING (Master - 50 Records)
-- Generating 50 bookings to easily map to 50 tickets
INSERT INTO Booking (booking_id, booking_date, total_amount, booking_status) VALUES 
(1, '2024-05-01 10:00:00', 15000.00, 'Confirmed'), (2, '2024-05-02 11:00:00', 15000.00, 'Confirmed'),
(3, '2024-05-03 12:00:00', 18000.00, 'Confirmed'), (4, '2024-05-04 13:00:00', 18000.00, 'Confirmed'),
(5, '2024-05-05 14:00:00', 10000.00, 'Confirmed'), (6, '2024-05-06 15:00:00', 10000.00, 'Confirmed'),
(7, '2024-05-07 16:00:00', 16000.00, 'Confirmed'), (8, '2024-05-08 17:00:00', 16000.00, 'Confirmed'),
(9, '2024-05-09 18:00:00', 9000.00, 'Confirmed'), (10, '2024-05-10 19:00:00', 9000.00, 'Confirmed'),
(11, '2024-05-11 10:00:00', 12000.00, 'Confirmed'), (12, '2024-05-12 11:00:00', 12000.00, 'Confirmed'),
(13, '2024-05-13 12:00:00', 11000.00, 'Confirmed'), (14, '2024-05-14 13:00:00', 11000.00, 'Confirmed'),
(15, '2024-05-15 14:00:00', 14000.00, 'Confirmed'), (16, '2024-05-16 15:00:00', 14000.00, 'Confirmed'),
(17, '2024-05-17 16:00:00', 45000.00, 'Confirmed'), (18, '2024-05-18 17:00:00', 45000.00, 'Confirmed'),
(19, '2024-05-19 18:00:00', 55000.00, 'Confirmed'), (20, '2024-05-20 19:00:00', 55000.00, 'Confirmed'),
(21, '2024-05-21 10:00:00', 40000.00, 'Confirmed'), (22, '2024-05-22 11:00:00', 40000.00, 'Confirmed'),
(23, '2024-05-23 12:00:00', 60000.00, 'Confirmed'), (24, '2024-05-24 13:00:00', 60000.00, 'Confirmed'),
(25, '2024-05-25 14:00:00', 65000.00, 'Confirmed'), (26, '2024-05-26 15:00:00', 65000.00, 'Confirmed'),
(27, '2024-05-27 16:00:00', 120000.00, 'Confirmed'), (28, '2024-05-28 17:00:00', 120000.00, 'Confirmed'),
(29, '2024-05-29 18:00:00', 110000.00, 'Confirmed'), (30, '2024-05-30 19:00:00', 110000.00, 'Confirmed'),
(31, '2024-05-01 08:00:00', 180000.00, 'Confirmed'), (32, '2024-05-02 09:00:00', 180000.00, 'Confirmed'),
(33, '2024-05-03 10:00:00', 190000.00, 'Confirmed'), (34, '2024-05-04 11:00:00', 190000.00, 'Confirmed'),
(35, '2024-05-05 12:00:00', 50000.00, 'Confirmed'), (36, '2024-05-06 13:00:00', 50000.00, 'Confirmed'),
(37, '2024-05-07 14:00:00', 85000.00, 'Confirmed'), (38, '2024-05-08 15:00:00', 85000.00, 'Confirmed'),
(39, '2024-05-09 16:00:00', 75000.00, 'Confirmed'), (40, '2024-05-10 17:00:00', 75000.00, 'Confirmed'),
(41, '2024-05-11 08:00:00', 95000.00, 'Confirmed'), (42, '2024-05-12 09:00:00', 95000.00, 'Confirmed'),
(43, '2024-05-13 10:00:00', 170000.00, 'Confirmed'), (44, '2024-05-14 11:00:00', 170000.00, 'Confirmed'),
(45, '2024-05-15 12:00:00', 82000.00, 'Confirmed'), (46, '2024-05-16 13:00:00', 82000.00, 'Confirmed'),
(47, '2024-05-17 14:00:00', 62000.00, 'Confirmed'), (48, '2024-05-18 15:00:00', 62000.00, 'Confirmed'),
(49, '2024-05-19 16:00:00', 160000.00, 'Confirmed'), (50, '2024-05-20 17:00:00', 160000.00, 'Confirmed');

-- 13. BOOKINGPASSENGER (Detail - 50 Records)
-- Mapping 50 bookings to 30 passengers (some passengers have multiple bookings)
INSERT INTO BookingPassenger (booking_id, passenger_id) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(11, 11), (12, 12), (13, 13), (14, 14), (15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20),
(21, 21), (22, 22), (23, 23), (24, 24), (25, 25), (26, 26), (27, 27), (28, 28), (29, 29), (30, 30),
(31, 1), (32, 2), (33, 3), (34, 4), (35, 5), (36, 6), (37, 7), (38, 8), (39, 9), (40, 10),
(41, 11), (42, 12), (43, 13), (44, 14), (45, 15), (46, 16), (47, 17), (48, 18), (49, 19), (50, 20);

-- 14. TICKET (Detail - 50 Records)
INSERT INTO Ticket (ticket_id, booking_id, passenger_id, flight_schedule_id, ticket_number, ticket_price, class_type, ticket_status) VALUES 
(1, 1, 1, 1, 'TKT-1000001', 15000.00, 'Economy', 'Active'), (2, 2, 2, 2, 'TKT-1000002', 15000.00, 'Economy', 'Active'),
(3, 3, 3, 3, 'TKT-1000003', 18000.00, 'Economy', 'Active'), (4, 4, 4, 4, 'TKT-1000004', 18000.00, 'Economy', 'Active'),
(5, 5, 5, 5, 'TKT-1000005', 10000.00, 'Economy', 'Active'), (6, 6, 6, 6, 'TKT-1000006', 10000.00, 'Economy', 'Active'),
(7, 7, 7, 7, 'TKT-1000007', 16000.00, 'Economy', 'Active'), (8, 8, 8, 8, 'TKT-1000008', 16000.00, 'Economy', 'Active'),
(9, 9, 9, 9, 'TKT-1000009', 9000.00, 'Economy', 'Active'), (10, 10, 10, 10, 'TKT-1000010', 9000.00, 'Economy', 'Active'),
(11, 11, 11, 11, 'TKT-1000011', 12000.00, 'Economy', 'Active'), (12, 12, 12, 12, 'TKT-1000012', 12000.00, 'Economy', 'Active'),
(13, 13, 13, 13, 'TKT-1000013', 11000.00, 'Economy', 'Active'), (14, 14, 14, 14, 'TKT-1000014', 11000.00, 'Economy', 'Active'),
(15, 15, 15, 15, 'TKT-1000015', 14000.00, 'Economy', 'Active'), (16, 16, 16, 16, 'TKT-1000016', 14000.00, 'Economy', 'Active'),
(17, 17, 17, 17, 'TKT-1000017', 45000.00, 'Business', 'Active'), (18, 18, 18, 18, 'TKT-1000018', 45000.00, 'Business', 'Active'),
(19, 19, 19, 19, 'TKT-1000019', 55000.00, 'Business', 'Active'), (20, 20, 20, 20, 'TKT-1000020', 55000.00, 'Business', 'Active'),
(21, 21, 21, 21, 'TKT-1000021', 40000.00, 'Business', 'Active'), (22, 22, 22, 22, 'TKT-1000022', 40000.00, 'Business', 'Active'),
(23, 23, 23, 23, 'TKT-1000023', 60000.00, 'First Class', 'Active'), (24, 24, 24, 24, 'TKT-1000024', 60000.00, 'First Class', 'Active'),
(25, 25, 25, 25, 'TKT-1000025', 65000.00, 'First Class', 'Active'), (26, 26, 26, 26, 'TKT-1000026', 65000.00, 'First Class', 'Active'),
(27, 27, 27, 27, 'TKT-1000027', 120000.00, 'Business', 'Active'), (28, 28, 28, 28, 'TKT-1000028', 120000.00, 'Business', 'Active'),
(29, 29, 29, 29, 'TKT-1000029', 110000.00, 'Business', 'Active'), (30, 30, 30, 30, 'TKT-1000030', 110000.00, 'Business', 'Active'),
(31, 31, 1, 31, 'TKT-1000031', 180000.00, 'First Class', 'Active'), (32, 32, 2, 32, 'TKT-1000032', 180000.00, 'First Class', 'Active'),
(33, 33, 3, 33, 'TKT-1000033', 190000.00, 'First Class', 'Active'), (34, 34, 4, 34, 'TKT-1000034', 190000.00, 'First Class', 'Active'),
(35, 35, 5, 35, 'TKT-1000035', 50000.00, 'Economy', 'Active'), (36, 36, 6, 36, 'TKT-1000036', 50000.00, 'Economy', 'Active'),
(37, 37, 7, 37, 'TKT-1000037', 85000.00, 'Business', 'Active'), (38, 38, 8, 38, 'TKT-1000038', 85000.00, 'Business', 'Active'),
(39, 39, 9, 39, 'TKT-1000039', 75000.00, 'Economy', 'Active'), (40, 40, 10, 40, 'TKT-1000040', 75000.00, 'Economy', 'Active'),
(41, 41, 11, 41, 'TKT-1000041', 95000.00, 'Business', 'Active'), (42, 42, 12, 42, 'TKT-1000042', 95000.00, 'Business', 'Active'),
(43, 43, 13, 43, 'TKT-1000043', 170000.00, 'First Class', 'Active'), (44, 44, 14, 44, 'TKT-1000044', 170000.00, 'First Class', 'Active'),
(45, 45, 15, 45, 'TKT-1000045', 82000.00, 'Business', 'Active'), (46, 46, 16, 46, 'TKT-1000046', 82000.00, 'Business', 'Active'),
(47, 47, 17, 47, 'TKT-1000047', 62000.00, 'Economy', 'Active'), (48, 48, 18, 48, 'TKT-1000048', 62000.00, 'Economy', 'Active'),
(49, 49, 19, 49, 'TKT-1000049', 160000.00, 'First Class', 'Active'), (50, 50, 20, 50, 'TKT-1000050', 160000.00, 'First Class', 'Active');

-- 15. CHECKIN (Detail - 50 Records)
INSERT INTO CheckIn (check_in_id, ticket_id, check_in_datetime, check_in_method, counter_number) VALUES 
(1, 1, '2024-06-01 05:00:00', 'Online', NULL), (2, 2, '2024-06-01 07:30:00', 'Counter', 'C12'),
(3, 3, '2024-06-01 11:00:00', 'Kiosk', NULL), (4, 4, '2024-06-02 06:00:00', 'Online', NULL),
(5, 5, '2024-06-02 12:00:00', 'Counter', 'C05'), (6, 6, '2024-06-03 04:00:00', 'Online', NULL),
(7, 7, '2024-06-03 15:00:00', 'Kiosk', NULL), (8, 8, '2024-06-04 08:00:00', 'Counter', 'C08'),
(9, 9, '2024-06-04 13:00:00', 'Online', NULL), (10, 10, '2024-06-05 05:30:00', 'Counter', 'C15'),
(11, 11, '2024-06-05 17:00:00', 'Online', NULL), (12, 12, '2024-06-06 03:00:00', 'Kiosk', NULL),
(13, 13, '2024-06-06 10:00:00', 'Counter', 'C11'), (14, 14, '2024-06-07 14:30:00', 'Online', NULL),
(15, 15, '2024-06-07 06:00:00', 'Kiosk', NULL), (16, 16, '2024-06-08 09:00:00', 'Counter', 'C20'),
(17, 17, '2024-06-08 19:00:00', 'Online', NULL), (18, 18, '2024-06-09 00:00:00', 'Counter', 'C01'),
(19, 19, '2024-06-09 07:00:00', 'Kiosk', NULL), (20, 20, '2024-06-10 12:00:00', 'Online', NULL),
(21, 21, '2024-06-10 05:00:00', 'Online', NULL), (22, 22, '2024-06-11 10:00:00', 'Counter', 'C02'),
(23, 23, '2024-06-11 16:00:00', 'Kiosk', NULL), (24, 24, '2024-06-11 23:00:00', 'Online', NULL),
(25, 25, '2024-06-12 08:00:00', 'Counter', 'C09'), (26, 26, '2024-06-13 15:00:00', 'Online', NULL),
(27, 27, '2024-06-12 22:00:00', 'Kiosk', NULL), (28, 28, '2024-06-14 09:00:00', 'Counter', 'C04'),
(29, 29, '2024-06-14 03:00:00', 'Online', NULL), (30, 30, '2024-06-15 13:00:00', 'Counter', 'C07'),
(31, 31, '2024-06-15 00:00:00', 'Online', NULL), (32, 32, '2024-06-16 16:00:00', 'Kiosk', NULL),
(33, 33, '2024-06-16 02:00:00', 'Counter', 'C18'), (34, 34, '2024-06-17 18:00:00', 'Online', NULL),
(35, 35, '2024-06-17 07:00:00', 'Kiosk', NULL), (36, 36, '2024-06-18 11:00:00', 'Counter', 'C14'),
(37, 37, '2024-06-18 17:00:00', 'Online', NULL), (38, 38, '2024-06-19 01:00:00', 'Kiosk', NULL),
(39, 39, '2024-06-19 08:00:00', 'Counter', 'C19'), (40, 40, '2024-06-20 16:00:00', 'Online', NULL),
(41, 41, '2024-06-20 04:00:00', 'Online', NULL), (42, 42, '2024-06-21 11:00:00', 'Counter', 'C03'),
(43, 43, '2024-06-21 19:00:00', 'Kiosk', NULL), (44, 44, '2024-06-22 11:00:00', 'Online', NULL),
(45, 45, '2024-06-22 06:00:00', 'Counter', 'C21'), (46, 46, '2024-06-23 13:00:00', 'Online', NULL),
(47, 47, '2024-06-23 02:00:00', 'Kiosk', NULL), (48, 48, '2024-06-24 09:00:00', 'Counter', 'C22'),
(49, 49, '2024-06-24 15:00:00', 'Online', NULL), (50, 50, '2024-06-25 06:00:00', 'Counter', 'C25');

-- 16. BOARDING (Detail - 50 Records)
INSERT INTO Boarding (boarding_id, ticket_id, boarding_datetime, boarding_status) VALUES 
(1, 1, '2024-06-01 07:20:00', 'Boarded'), (2, 2, '2024-06-01 09:50:00', 'Boarded'),
(3, 3, '2024-06-01 13:20:00', 'Boarded'), (4, 4, '2024-06-02 08:20:00', 'Boarded'),
(5, 5, '2024-06-02 14:20:00', 'Boarded'), (6, 6, '2024-06-03 06:20:00', 'Boarded'),
(7, 7, '2024-06-03 17:20:00', 'Boarded'), (8, 8, '2024-06-04 10:20:00', 'Boarded'),
(9, 9, '2024-06-04 15:20:00', 'Boarded'), (10, 10, '2024-06-05 07:50:00', 'Boarded'),
(11, 11, '2024-06-05 19:20:00', 'Boarded'), (12, 12, '2024-06-06 05:20:00', 'Boarded'),
(13, 13, '2024-06-06 12:20:00', 'Boarded'), (14, 14, '2024-06-07 16:50:00', 'Boarded'),
(15, 15, '2024-06-07 08:20:00', 'Boarded'), (16, 16, '2024-06-08 11:20:00', 'Boarded'),
(17, 17, '2024-06-08 21:20:00', 'Boarded'), (18, 18, '2024-06-09 02:20:00', 'Boarded'),
(19, 19, '2024-06-09 09:20:00', 'Boarded'), (20, 20, '2024-06-10 14:20:00', 'Boarded'),
(21, 21, '2024-06-10 07:20:00', 'Boarded'), (22, 22, '2024-06-11 12:20:00', 'Boarded'),
(23, 23, '2024-06-11 18:20:00', 'Boarded'), (24, 24, '2024-06-12 01:20:00', 'Boarded'),
(25, 25, '2024-06-12 10:20:00', 'Boarded'), (26, 26, '2024-06-13 17:20:00', 'Boarded'),
(27, 27, '2024-06-13 00:20:00', 'Boarded'), (28, 28, '2024-06-14 11:20:00', 'Boarded'),
(29, 29, '2024-06-14 05:20:00', 'Boarded'), (30, 30, '2024-06-15 15:20:00', 'Boarded'),
(31, 31, '2024-06-15 02:20:00', 'Boarded'), (32, 32, '2024-06-16 18:20:00', 'Boarded'),
(33, 33, '2024-06-16 04:20:00', 'Boarded'), (34, 34, '2024-06-17 20:20:00', 'Boarded'),
(35, 35, '2024-06-17 09:20:00', 'Boarded'), (36, 36, '2024-06-18 13:20:00', 'Boarded'),
(37, 37, '2024-06-18 19:20:00', 'Boarded'), (38, 38, '2024-06-19 03:20:00', 'Boarded'),
(39, 39, '2024-06-19 10:20:00', 'Boarded'), (40, 40, '2024-06-20 18:20:00', 'Boarded'),
(41, 41, '2024-06-20 06:20:00', 'Boarded'), (42, 42, '2024-06-21 13:20:00', 'Boarded'),
(43, 43, '2024-06-21 21:20:00', 'Boarded'), (44, 44, '2024-06-22 13:20:00', 'Boarded'),
(45, 45, '2024-06-22 08:20:00', 'Boarded'), (46, 46, '2024-06-23 15:20:00', 'Boarded'),
(47, 47, '2024-06-23 04:20:00', 'Boarded'), (48, 48, '2024-06-24 11:20:00', 'Boarded'),
(49, 49, '2024-06-24 17:20:00', 'Boarded'), (50, 50, '2024-06-25 08:20:00', 'Boarded');

-- 17. CONNECTIONS (Master - 20 Records)
INSERT INTO Connections (connection_id, connection_name, connection_type, total_layover_duration_min) VALUES 
(1, 'KHI-LHE-ISB', 'Domestic', 120), (2, 'ISB-LHE-KHI', 'Domestic', 90),
(3, 'KHI-DXB-LHR', 'International', 240), (4, 'LHR-DXB-KHI', 'International', 180),
(5, 'LHE-DOH-JFK', 'International', 300), (6, 'JFK-DOH-LHE', 'International', 210),
(7, 'ISB-IST-YYZ', 'International', 360), (8, 'YYZ-IST-ISB', 'International', 240),
(9, 'PEW-DXB-JED', 'International', 150), (10, 'JED-DXB-PEW', 'International', 120),
(11, 'MUX-KHI-DXB', 'International', 180), (12, 'DXB-KHI-MUX', 'International', 150),
(13, 'UET-KHI-ISB', 'Domestic', 90), (14, 'ISB-KHI-UET', 'Domestic', 120),
(15, 'SKT-DXB-LHR', 'International', 200), (16, 'LHR-DXB-SKT', 'International', 180),
(17, 'KHI-KUL-SYD', 'International', 420), (18, 'SYD-KUL-KHI', 'International', 360),
(19, 'ISB-PEK-SYD', 'International', 480), (20, 'SYD-PEK-ISB', 'International', 400);

-- 18. CONNECTIONSEGMENT (Detail - 50 Records)
INSERT INTO ConnectionSegment (connection_segment_id, connection_id, flight_schedule_id, segment_order) VALUES 
(1, 1, 1, 1), (2, 1, 5, 2), (3, 2, 4, 1), (4, 2, 2, 2), (5, 3, 17, 1),
(6, 3, 27, 2), (7, 4, 28, 1), (8, 4, 18, 2), (9, 5, 35, 1), (10, 5, 31, 2),
(11, 6, 32, 1), (12, 6, 36, 2), (13, 7, 45, 1), (14, 7, 33, 2), (15, 8, 34, 1),
(16, 8, 46, 2), (17, 9, 7, 1), (18, 9, 23, 2), (19, 10, 24, 1), (20, 10, 8, 2),
(21, 11, 11, 1), (22, 11, 17, 2), (23, 12, 18, 1), (24, 12, 12, 2), (25, 13, 13, 1),
(26, 13, 3, 2), (27, 14, 4, 1), (28, 14, 14, 2), (29, 15, 21, 1), (30, 15, 27, 2),
(31, 16, 28, 1), (32, 16, 22, 2), (33, 17, 39, 1), (34, 17, 49, 2), (35, 18, 50, 1),
(36, 18, 40, 2), (37, 19, 41, 1), (38, 19, 42, 2), (39, 20, 43, 1), (40, 20, 44, 2),
(41, 1, 6, 3), (42, 2, 9, 3), (43, 3, 19, 3), (44, 4, 20, 3), (45, 5, 37, 3),
(46, 6, 38, 3), (47, 7, 47, 3), (48, 8, 48, 3), (49, 9, 25, 3), (50, 10, 26, 3);

-- 19. MAINTENANCETYPE (Master - 20 Records)
INSERT INTO MaintenanceType (maintenance_type_id, type_name, type_description) VALUES 
(1, 'A Check', 'Light maintenance, every 400-600 hours'),
(2, 'B Check', 'Light to medium maintenance, every 6-8 months'),
(3, 'C Check', 'Heavy maintenance, every 20-24 months'),
(4, 'D Check', 'Extensive structural heavy check, every 6-10 years'),
(5, 'Line Maintenance', 'Pre-flight, transit, and daily checks'),
(6, 'Engine Overhaul', 'Complete teardown and rebuild of engine'),
(7, 'Avionics Calibration', 'Calibration of navigation and comms'),
(8, 'Cabin Refurbishment', 'Replacing seats, carpets, and panels'),
(9, 'Landing Gear Overhaul', 'Inspection and parts replacement for gear'),
(10, 'APU Service', 'Auxiliary Power Unit maintenance'),
(11, 'Tire Replacement', 'Replacing worn out aircraft tires'),
(12, 'Brake Inspection', 'Checking and replacing brake pads'),
(13, 'Window Polish', 'Polishing flight deck windows'),
(14, 'Paint Touch-up', 'Minor exterior paint repairs'),
(15, 'Full Repaint', 'Complete stripping and repainting'),
(16, 'Software Update', 'Updating flight management systems'),
(17, 'Hydraulic Flush', 'Flushing and refilling hydraulic fluids'),
(18, 'Oxygen System Check', 'Testing emergency oxygen systems'),
(19, 'Fire Suppression Test', 'Testing cargo and engine fire systems'),
(20, 'Bird Strike Inspection', 'Inspection following reported bird strike');

-- 20. MAINTENANCEEVENT (Detail - 50 Records)
INSERT INTO MaintenanceEvent (maintenance_event_id, aircraft_id, maintenance_type_id, event_date, completion_date, event_description, status) VALUES 
(1, 1, 5, '2024-05-01', '2024-05-01', 'Daily transit check', 'Completed'),
(2, 2, 5, '2024-05-02', '2024-05-02', 'Daily transit check', 'Completed'),
(3, 3, 1, '2024-05-03', '2024-05-04', 'A Check schedule', 'Completed'),
(4, 4, 2, '2024-05-05', '2024-05-07', 'B Check routine', 'Completed'),
(5, 5, 11, '2024-05-06', '2024-05-06', 'Replaced main gear tires', 'Completed'),
(6, 6, 12, '2024-05-08', '2024-05-08', 'Brake pad inspection', 'Completed'),
(7, 7, 5, '2024-05-10', '2024-05-10', 'Daily check', 'Completed'),
(8, 8, 16, '2024-05-11', '2024-05-11', 'FMC software patch', 'Completed'),
(9, 9, 3, '2024-05-15', '2024-05-30', 'C check heavy maintenance', 'Completed'),
(10, 10, 10, '2024-05-16', '2024-05-17', 'APU routine service', 'Completed'),
(11, 11, 5, '2024-05-18', '2024-05-18', 'Line check', 'Completed'),
(12, 12, 20, '2024-05-19', '2024-05-20', 'Radome bird strike inspect', 'Completed'),
(13, 13, 1, '2024-05-20', '2024-05-21', 'A check', 'Completed'),
(14, 14, 5, '2024-05-21', '2024-05-21', 'Transit check', 'Completed'),
(15, 15, 8, '2024-05-22', '2024-05-25', 'Cabin seats repair', 'Completed'),
(16, 16, 5, '2024-05-23', '2024-05-23', 'Line maintenance', 'Completed'),
(17, 17, 4, '2024-05-01', '2024-06-15', 'D Check heavy teardown', 'In Progress'),
(18, 18, 5, '2024-05-25', '2024-05-25', 'Daily transit', 'Completed'),
(19, 19, 7, '2024-05-26', '2024-05-26', 'Avionics altimeter fix', 'Completed'),
(20, 20, 9, '2024-05-28', '2024-06-05', 'Nose gear overhaul', 'Completed'),
(21, 1, 5, '2024-06-01', '2024-06-01', 'Daily transit', 'Completed'),
(22, 2, 5, '2024-06-02', '2024-06-02', 'Daily transit', 'Completed'),
(23, 3, 5, '2024-06-03', '2024-06-03', 'Daily transit', 'Completed'),
(24, 4, 5, '2024-06-04', '2024-06-04', 'Daily transit', 'Completed'),
(25, 5, 5, '2024-06-05', '2024-06-05', 'Daily transit', 'Completed'),
(26, 6, 5, '2024-06-06', '2024-06-06', 'Daily transit', 'Completed'),
(27, 7, 5, '2024-06-07', '2024-06-07', 'Daily transit', 'Completed'),
(28, 8, 5, '2024-06-08', '2024-06-08', 'Daily transit', 'Completed'),
(29, 9, 5, '2024-06-09', '2024-06-09', 'Daily transit', 'Completed'),
(30, 10, 5, '2024-06-10', '2024-06-10', 'Daily transit', 'Completed'),
(31, 11, 5, '2024-06-11', '2024-06-11', 'Daily transit', 'Completed'),
(32, 12, 5, '2024-06-12', '2024-06-12', 'Daily transit', 'Completed'),
(33, 13, 5, '2024-06-13', '2024-06-13', 'Daily transit', 'Completed'),
(34, 14, 5, '2024-06-14', '2024-06-14', 'Daily transit', 'Completed'),
(35, 15, 5, '2024-06-15', '2024-06-15', 'Daily transit', 'Completed'),
(36, 16, 5, '2024-06-16', '2024-06-16', 'Daily transit', 'Completed'),
(37, 18, 5, '2024-06-17', '2024-06-17', 'Daily transit', 'Completed'),
(38, 19, 5, '2024-06-18', '2024-06-18', 'Daily transit', 'Completed'),
(39, 20, 5, '2024-06-19', '2024-06-19', 'Daily transit', 'Completed'),
(40, 1, 11, '2024-06-20', '2024-06-20', 'Tire change', 'Completed'),
(41, 2, 12, '2024-06-21', '2024-06-21', 'Brake check', 'Completed'),
(42, 3, 13, '2024-06-22', '2024-06-22', 'Window clean', 'Completed'),
(43, 4, 14, '2024-06-23', '2024-06-23', 'Paint fix', 'Completed'),
(44, 5, 16, '2024-06-24', '2024-06-24', 'Software fix', 'Completed'),
(45, 6, 17, '2024-06-25', '2024-06-25', 'Hydraulic fluid', 'Completed'),
(46, 7, 18, '2024-06-26', '2024-06-26', 'O2 masks check', 'Completed'),
(47, 8, 19, '2024-06-27', '2024-06-27', 'Fire test', 'Completed'),
(48, 9, 20, '2024-06-28', '2024-06-28', 'Bird check', 'Completed'),
(49, 10, 5, '2024-06-29', NULL, 'Transit ongoing', 'In Progress'),
(50, 11, 5, '2024-06-30', NULL, 'Transit ongoing', 'Scheduled');

-- 21. MAINTENANCEASSIGNMENT (Detail - 50 Records)
INSERT INTO MaintenanceAssignment (maintenance_assignment_id, employee_id, maintenance_event_id, assigned_date) VALUES 
(1, 9, 1, '2024-05-01'), (2, 10, 2, '2024-05-02'), (3, 8, 3, '2024-05-03'), (4, 9, 4, '2024-05-05'), (5, 10, 5, '2024-05-06'),
(6, 8, 6, '2024-05-08'), (7, 9, 7, '2024-05-10'), (8, 10, 8, '2024-05-11'), (9, 8, 9, '2024-05-15'), (10, 9, 10, '2024-05-16'),
(11, 10, 11, '2024-05-18'), (12, 8, 12, '2024-05-19'), (13, 9, 13, '2024-05-20'), (14, 10, 14, '2024-05-21'), (15, 8, 15, '2024-05-22'),
(16, 9, 16, '2024-05-23'), (17, 10, 17, '2024-05-01'), (18, 8, 18, '2024-05-25'), (19, 9, 19, '2024-05-26'), (20, 10, 20, '2024-05-28'),
(21, 9, 21, '2024-06-01'), (22, 10, 22, '2024-06-02'), (23, 8, 23, '2024-06-03'), (24, 9, 24, '2024-06-04'), (25, 10, 25, '2024-06-05'),
(26, 8, 26, '2024-06-06'), (27, 9, 27, '2024-06-07'), (28, 10, 28, '2024-06-08'), (29, 8, 29, '2024-06-09'), (30, 9, 30, '2024-06-10'),
(31, 10, 31, '2024-06-11'), (32, 8, 32, '2024-06-12'), (33, 9, 33, '2024-06-13'), (34, 10, 34, '2024-06-14'), (35, 8, 35, '2024-06-15'),
(36, 9, 36, '2024-06-16'), (37, 10, 37, '2024-06-17'), (38, 8, 38, '2024-06-18'), (39, 9, 39, '2024-06-19'), (40, 10, 40, '2024-06-20'),
(41, 8, 41, '2024-06-21'), (42, 9, 42, '2024-06-22'), (43, 10, 43, '2024-06-23'), (44, 8, 44, '2024-06-24'), (45, 9, 45, '2024-06-25'),
(46, 10, 46, '2024-06-26'), (47, 8, 47, '2024-06-27'), (48, 9, 48, '2024-06-28'), (49, 10, 49, '2024-06-29'), (50, 8, 50, '2024-06-30');

-- 22. FLIGHTCREWASSIGNMENT (Detail - 50 Records)
INSERT INTO FlightCrewAssignment (flight_crew_assignment_id, employee_id, flight_schedule_id, crew_role, assigned_date) VALUES 
(1, 2, 1, 'Captain', '2024-05-25'), (2, 4, 1, 'First Officer', '2024-05-25'), (3, 3, 1, 'Lead Cabin Crew', '2024-05-25'),
(4, 2, 2, 'Captain', '2024-05-25'), (5, 4, 2, 'First Officer', '2024-05-25'), (6, 3, 2, 'Lead Cabin Crew', '2024-05-25'),
(7, 11, 3, 'Captain', '2024-05-26'), (8, 6, 3, 'First Officer', '2024-05-26'), (9, 7, 3, 'Flight Attendant', '2024-05-26'),
(10, 11, 4, 'Captain', '2024-05-26'), (11, 6, 4, 'First Officer', '2024-05-26'), (12, 7, 4, 'Flight Attendant', '2024-05-26'),
(13, 18, 5, 'Captain', '2024-05-27'), (14, 21, 5, 'First Officer', '2024-05-27'), (15, 19, 5, 'Lead Cabin Crew', '2024-05-27'),
(16, 18, 6, 'Captain', '2024-05-27'), (17, 21, 6, 'First Officer', '2024-05-27'), (18, 19, 6, 'Lead Cabin Crew', '2024-05-27'),
(19, 2, 7, 'Captain', '2024-05-28'), (20, 4, 7, 'First Officer', '2024-05-28'), (21, 5, 7, 'Flight Attendant', '2024-05-28'),
(22, 2, 8, 'Captain', '2024-05-28'), (23, 4, 8, 'First Officer', '2024-05-28'), (24, 5, 8, 'Flight Attendant', '2024-05-28'),
(25, 11, 9, 'Captain', '2024-05-29'), (26, 6, 9, 'First Officer', '2024-05-29'), (27, 25, 9, 'Lead Cabin Crew', '2024-05-29'),
(28, 11, 10, 'Captain', '2024-05-29'), (29, 6, 10, 'First Officer', '2024-05-29'), (30, 25, 10, 'Lead Cabin Crew', '2024-05-29'),
(31, 18, 11, 'Captain', '2024-05-30'), (32, 21, 11, 'First Officer', '2024-05-30'), (33, 7, 11, 'Flight Attendant', '2024-05-30'),
(34, 18, 12, 'Captain', '2024-05-30'), (35, 21, 12, 'First Officer', '2024-05-30'), (36, 7, 12, 'Flight Attendant', '2024-05-30'),
(37, 2, 13, 'Captain', '2024-05-31'), (38, 4, 13, 'First Officer', '2024-05-31'), (39, 3, 13, 'Lead Cabin Crew', '2024-05-31'),
(40, 2, 14, 'Captain', '2024-05-31'), (41, 4, 14, 'First Officer', '2024-05-31'), (42, 3, 14, 'Lead Cabin Crew', '2024-05-31'),
(43, 11, 15, 'Captain', '2024-06-01'), (44, 6, 15, 'First Officer', '2024-06-01'), (45, 19, 15, 'Flight Attendant', '2024-06-01'),
(46, 11, 16, 'Captain', '2024-06-01'), (47, 6, 16, 'First Officer', '2024-06-01'), (48, 19, 16, 'Flight Attendant', '2024-06-01'),
(49, 18, 17, 'Captain', '2024-06-02'), (50, 21, 17, 'First Officer', '2024-06-02');

-- 23. SEATASSIGNMENT (Detail - 50 Records)
-- Mapping 1:1 with Ticket and Schedule, assigning unique seats to avoid conflict
INSERT INTO SeatAssignment (seat_assignment_id, seat_id, ticket_id, flight_schedule_id, assignment_datetime) VALUES 
(1, 1, 1, 1, '2024-06-01 05:05:00'), (2, 6, 2, 2, '2024-06-01 07:35:00'),
(3, 11, 3, 3, '2024-06-01 11:05:00'), (4, 2, 4, 4, '2024-06-02 06:05:00'),
(5, 31, 5, 5, '2024-06-02 12:05:00'), (6, 36, 6, 6, '2024-06-03 04:05:00'),
(7, 41, 7, 7, '2024-06-03 15:05:00'), (8, 46, 8, 8, '2024-06-04 08:05:00'),
(9, 7, 9, 9, '2024-06-04 13:05:00'), (10, 12, 10, 10, '2024-06-05 05:35:00'),
(11, 16, 11, 11, '2024-06-05 17:05:00'), (12, 21, 12, 12, '2024-06-06 03:05:00'),
(13, 3, 13, 13, '2024-06-06 10:05:00'), (14, 8, 14, 14, '2024-06-07 14:35:00'),
(15, 17, 15, 15, '2024-06-07 06:05:00'), (16, 22, 16, 16, '2024-06-08 09:05:00'),
(17, 26, 17, 17, '2024-06-08 19:05:00'), (18, 27, 18, 18, '2024-06-09 00:05:00'),
(19, 28, 19, 19, '2024-06-09 07:05:00'), (20, 29, 20, 20, '2024-06-10 12:05:00'),
(21, 32, 21, 21, '2024-06-10 05:05:00'), (22, 37, 22, 22, '2024-06-11 10:05:00'),
(23, 42, 23, 23, '2024-06-11 16:05:00'), (24, 47, 24, 24, '2024-06-11 23:05:00'),
(25, 43, 25, 25, '2024-06-12 08:05:00'), (26, 48, 26, 26, '2024-06-13 15:05:00'),
(27, 18, 27, 27, '2024-06-12 22:05:00'), (28, 19, 28, 28, '2024-06-14 09:05:00'),
(29, 23, 29, 29, '2024-06-14 03:05:00'), (30, 24, 30, 30, '2024-06-15 13:05:00'),
(31, 4, 31, 31, '2024-06-15 00:05:00'), (32, 9, 32, 32, '2024-06-16 16:05:00'),
(33, 14, 33, 33, '2024-06-16 02:05:00'), (34, 5, 34, 34, '2024-06-17 18:05:00'),
(35, 10, 35, 35, '2024-06-17 07:05:00'), (36, 15, 36, 36, '2024-06-18 11:05:00'),
(37, 20, 37, 37, '2024-06-18 17:05:00'), (38, 25, 38, 38, '2024-06-19 01:05:00'),
(39, 30, 39, 39, '2024-06-19 08:05:00'), (40, 33, 40, 40, '2024-06-20 16:05:00'),
(41, 38, 41, 41, '2024-06-20 04:05:00'), (42, 44, 42, 42, '2024-06-21 11:05:00'),
(43, 49, 43, 43, '2024-06-21 19:05:00'), (44, 45, 44, 44, '2024-06-22 11:05:00'),
(45, 50, 45, 45, '2024-06-22 06:05:00'), (46, 34, 46, 46, '2024-06-23 13:05:00'),
(47, 39, 47, 47, '2024-06-23 02:05:00'), (48, 35, 48, 48, '2024-06-24 09:05:00'),
(49, 40, 49, 49, '2024-06-24 15:05:00'), (50, 13, 50, 50, '2024-06-25 06:05:00');

-- 24. BAGGAGE (Detail - 50 Records)
INSERT INTO Baggage (baggage_id, check_in_id, weight_kg, baggage_type, baggage_tag_number, baggage_status) VALUES 
(1, 1, 20.50, 'Checked', 'BAG1001', 'Loaded'), (2, 2, 18.00, 'Checked', 'BAG1002', 'Loaded'),
(3, 3, 22.10, 'Checked', 'BAG1003', 'Loaded'), (4, 4, 15.40, 'Checked', 'BAG1004', 'Loaded'),
(5, 5, 23.00, 'Checked', 'BAG1005', 'Loaded'), (6, 6, 19.50, 'Checked', 'BAG1006', 'Loaded'),
(7, 7, 21.00, 'Checked', 'BAG1007', 'Loaded'), (8, 8, 14.50, 'Checked', 'BAG1008', 'Loaded'),
(9, 9, 25.00, 'Checked', 'BAG1009', 'Loaded'), (10, 10, 20.00, 'Checked', 'BAG1010', 'Loaded'),
(11, 11, 17.50, 'Checked', 'BAG1011', 'Loaded'), (12, 12, 16.00, 'Checked', 'BAG1012', 'Loaded'),
(13, 13, 24.50, 'Checked', 'BAG1013', 'Loaded'), (14, 14, 21.50, 'Checked', 'BAG1014', 'Loaded'),
(15, 15, 22.00, 'Checked', 'BAG1015', 'Loaded'), (16, 16, 18.50, 'Checked', 'BAG1016', 'Loaded'),
(17, 17, 28.00, 'Checked', 'BAG1017', 'Loaded'), (18, 18, 29.50, 'Checked', 'BAG1018', 'Loaded'),
(19, 19, 30.00, 'Checked', 'BAG1019', 'Loaded'), (20, 20, 27.00, 'Checked', 'BAG1020', 'Loaded'),
(21, 21, 26.50, 'Checked', 'BAG1021', 'Loaded'), (22, 22, 25.50, 'Checked', 'BAG1022', 'Loaded'),
(23, 23, 32.00, 'Checked', 'BAG1023', 'Loaded'), (24, 24, 31.00, 'Checked', 'BAG1024', 'Loaded'),
(25, 25, 33.50, 'Checked', 'BAG1025', 'Loaded'), (26, 26, 30.50, 'Checked', 'BAG1026', 'Loaded'),
(27, 27, 20.00, 'Checked', 'BAG1027', 'Loaded'), (28, 28, 22.50, 'Checked', 'BAG1028', 'Loaded'),
(29, 29, 19.00, 'Checked', 'BAG1029', 'Loaded'), (30, 30, 21.00, 'Checked', 'BAG1030', 'Loaded'),
(31, 31, 23.50, 'Checked', 'BAG1031', 'Loaded'), (32, 32, 24.00, 'Checked', 'BAG1032', 'Loaded'),
(33, 33, 18.00, 'Checked', 'BAG1033', 'Loaded'), (34, 34, 17.50, 'Checked', 'BAG1034', 'Loaded'),
(35, 35, 16.50, 'Checked', 'BAG1035', 'Loaded'), (36, 36, 15.00, 'Checked', 'BAG1036', 'Loaded'),
(37, 37, 20.50, 'Checked', 'BAG1037', 'Loaded'), (38, 38, 21.50, 'Checked', 'BAG1038', 'Loaded'),
(39, 39, 22.00, 'Checked', 'BAG1039', 'Loaded'), (40, 40, 25.00, 'Checked', 'BAG1040', 'Loaded'),
(41, 41, 26.00, 'Checked', 'BAG1041', 'Loaded'), (42, 42, 27.50, 'Checked', 'BAG1042', 'Loaded'),
(43, 43, 28.50, 'Checked', 'BAG1043', 'Loaded'), (44, 44, 29.00, 'Checked', 'BAG1044', 'Loaded'),
(45, 45, 30.00, 'Checked', 'BAG1045', 'Loaded'), (46, 46, 31.50, 'Checked', 'BAG1046', 'Loaded'),
(47, 47, 19.00, 'Checked', 'BAG1047', 'Loaded'), (48, 48, 18.50, 'Checked', 'BAG1048', 'Loaded'),
(49, 49, 20.00, 'Checked', 'BAG1049', 'Loaded'), (50, 50, 22.50, 'Checked', 'BAG1050', 'Loaded');

-- 25. PAYMENT (Detail - 50 Records)
INSERT INTO Payment (payment_id, booking_id, payment_datetime, payment_amount, payment_method, payment_status, transaction_reference) VALUES 
(1, 1, '2024-05-01 10:05:00', 15000.00, 'Credit Card', 'Completed', 'TXN-0001'), (2, 2, '2024-05-02 11:05:00', 15000.00, 'Debit Card', 'Completed', 'TXN-0002'),
(3, 3, '2024-05-03 12:05:00', 18000.00, 'Bank Transfer', 'Completed', 'TXN-0003'), (4, 4, '2024-05-04 13:05:00', 18000.00, 'Credit Card', 'Completed', 'TXN-0004'),
(5, 5, '2024-05-05 14:05:00', 10000.00, 'JazzCash', 'Completed', 'TXN-0005'), (6, 6, '2024-05-06 15:05:00', 10000.00, 'EasyPaisa', 'Completed', 'TXN-0006'),
(7, 7, '2024-05-07 16:05:00', 16000.00, 'Credit Card', 'Completed', 'TXN-0007'), (8, 8, '2024-05-08 17:05:00', 16000.00, 'Debit Card', 'Completed', 'TXN-0008'),
(9, 9, '2024-05-09 18:05:00', 9000.00, 'Credit Card', 'Completed', 'TXN-0009'), (10, 10, '2024-05-10 19:05:00', 9000.00, 'JazzCash', 'Completed', 'TXN-0010'),
(11, 11, '2024-05-11 10:05:00', 12000.00, 'Credit Card', 'Completed', 'TXN-0011'), (12, 12, '2024-05-12 11:05:00', 12000.00, 'Debit Card', 'Completed', 'TXN-0012'),
(13, 13, '2024-05-13 12:05:00', 11000.00, 'Credit Card', 'Completed', 'TXN-0013'), (14, 14, '2024-05-14 13:05:00', 11000.00, 'Bank Transfer', 'Completed', 'TXN-0014'),
(15, 15, '2024-05-15 14:05:00', 14000.00, 'Credit Card', 'Completed', 'TXN-0015'), (16, 16, '2024-05-16 15:05:00', 14000.00, 'Debit Card', 'Completed', 'TXN-0016'),
(17, 17, '2024-05-17 16:05:00', 45000.00, 'Credit Card', 'Completed', 'TXN-0017'), (18, 18, '2024-05-18 17:05:00', 45000.00, 'Credit Card', 'Completed', 'TXN-0018'),
(19, 19, '2024-05-19 18:05:00', 55000.00, 'Bank Transfer', 'Completed', 'TXN-0019'), (20, 20, '2024-05-20 19:05:00', 55000.00, 'Credit Card', 'Completed', 'TXN-0020'),
(21, 21, '2024-05-21 10:05:00', 40000.00, 'Credit Card', 'Completed', 'TXN-0021'), (22, 22, '2024-05-22 11:05:00', 40000.00, 'Debit Card', 'Completed', 'TXN-0022'),
(23, 23, '2024-05-23 12:05:00', 60000.00, 'Credit Card', 'Completed', 'TXN-0023'), (24, 24, '2024-05-24 13:05:00', 60000.00, 'Bank Transfer', 'Completed', 'TXN-0024'),
(25, 25, '2024-05-25 14:05:00', 65000.00, 'Credit Card', 'Completed', 'TXN-0025'), (26, 26, '2024-05-26 15:05:00', 65000.00, 'Debit Card', 'Completed', 'TXN-0026'),
(27, 27, '2024-05-27 16:05:00', 120000.00, 'Credit Card', 'Completed', 'TXN-0027'), (28, 28, '2024-05-28 17:05:00', 120000.00, 'Bank Transfer', 'Completed', 'TXN-0028'),
(29, 29, '2024-05-29 18:05:00', 110000.00, 'Credit Card', 'Completed', 'TXN-0029'), (30, 30, '2024-05-30 19:05:00', 110000.00, 'Debit Card', 'Completed', 'TXN-0030'),
(31, 31, '2024-05-01 08:05:00', 180000.00, 'Credit Card', 'Completed', 'TXN-0031'), (32, 32, '2024-05-02 09:05:00', 180000.00, 'Credit Card', 'Completed', 'TXN-0032'),
(33, 33, '2024-05-03 10:05:00', 190000.00, 'Bank Transfer', 'Completed', 'TXN-0033'), (34, 34, '2024-05-04 11:05:00', 190000.00, 'Credit Card', 'Completed', 'TXN-0034'),
(35, 35, '2024-05-05 12:05:00', 50000.00, 'Debit Card', 'Completed', 'TXN-0035'), (36, 36, '2024-05-06 13:05:00', 50000.00, 'Credit Card', 'Completed', 'TXN-0036'),
(37, 37, '2024-05-07 14:05:00', 85000.00, 'Bank Transfer', 'Completed', 'TXN-0037'), (38, 38, '2024-05-08 15:05:00', 85000.00, 'Credit Card', 'Completed', 'TXN-0038'),
(39, 39, '2024-05-09 16:05:00', 75000.00, 'Debit Card', 'Completed', 'TXN-0039'), (40, 40, '2024-05-10 17:05:00', 75000.00, 'Credit Card', 'Completed', 'TXN-0040'),
(41, 41, '2024-05-11 08:05:00', 95000.00, 'Credit Card', 'Completed', 'TXN-0041'), (42, 42, '2024-05-12 09:05:00', 95000.00, 'Bank Transfer', 'Completed', 'TXN-0042'),
(43, 43, '2024-05-13 10:05:00', 170000.00, 'Credit Card', 'Completed', 'TXN-0043'), (44, 44, '2024-05-14 11:05:00', 170000.00, 'Debit Card', 'Completed', 'TXN-0044'),
(45, 45, '2024-05-15 12:05:00', 82000.00, 'Credit Card', 'Completed', 'TXN-0045'), (46, 46, '2024-05-16 13:05:00', 82000.00, 'Bank Transfer', 'Completed', 'TXN-0046'),
(47, 47, '2024-05-17 14:05:00', 62000.00, 'Credit Card', 'Completed', 'TXN-0047'), (48, 48, '2024-05-18 15:05:00', 62000.00, 'Debit Card', 'Completed', 'TXN-0048'),
(49, 49, '2024-05-19 16:05:00', 160000.00, 'Credit Card', 'Completed', 'TXN-0049'), (50, 50, '2024-05-20 17:05:00', 160000.00, 'Credit Card', 'Completed', 'TXN-0050');

-- 26. INVOICE (Detail - 50 Records)
INSERT INTO Invoice (invoice_id, payment_id, invoice_date, invoice_amount, billing_address, invoice_status) VALUES 
(1, 1, '2024-05-01', 15000.00, 'Clifton, Karachi', 'Paid'), (2, 2, '2024-05-02', 15000.00, 'DHA, Lahore', 'Paid'),
(3, 3, '2024-05-03', 18000.00, 'F-8, Islamabad', 'Paid'), (4, 4, '2024-05-04', 18000.00, 'Gulberg, Lahore', 'Paid'),
(5, 5, '2024-05-05', 10000.00, 'PECHS, Karachi', 'Paid'), (6, 6, '2024-05-06', 10000.00, 'Blue Area, Islamabad', 'Paid'),
(7, 7, '2024-05-07', 16000.00, 'Saddar, Karachi', 'Paid'), (8, 8, '2024-05-08', 16000.00, 'Model Town, Lahore', 'Paid'),
(9, 9, '2024-05-09', 9000.00, 'G-11, Islamabad', 'Paid'), (10, 10, '2024-05-10', 9000.00, 'Cantt, Peshawar', 'Paid'),
(11, 11, '2024-05-11', 12000.00, 'Cantt, Multan', 'Paid'), (12, 12, '2024-05-12', 12000.00, 'Jinnah Road, Quetta', 'Paid'),
(13, 13, '2024-05-13', 11000.00, 'Civil Lines, Faisalabad', 'Paid'), (14, 14, '2024-05-14', 11000.00, 'Cantt, Sialkot', 'Paid'),
(15, 15, '2024-05-15', 14000.00, 'DHA, Karachi', 'Paid'), (16, 16, '2024-05-16', 14000.00, 'Bahria Town, Lahore', 'Paid'),
(17, 17, '2024-05-17', 45000.00, 'DHA, Islamabad', 'Paid'), (18, 18, '2024-05-18', 45000.00, 'Clifton, Karachi', 'Paid'),
(19, 19, '2024-05-19', 55000.00, 'Gulberg, Lahore', 'Paid'), (20, 20, '2024-05-20', 55000.00, 'F-7, Islamabad', 'Paid'),
(21, 21, '2024-05-21', 40000.00, 'Tariq Road, Karachi', 'Paid'), (22, 22, '2024-05-22', 40000.00, 'Johar Town, Lahore', 'Paid'),
(23, 23, '2024-05-23', 60000.00, 'E-7, Islamabad', 'Paid'), (24, 24, '2024-05-24', 60000.00, 'Defence, Karachi', 'Paid'),
(25, 25, '2024-05-25', 65000.00, 'Model Town, Lahore', 'Paid'), (26, 26, '2024-05-26', 65000.00, 'G-9, Islamabad', 'Paid'),
(27, 27, '2024-05-27', 120000.00, 'Beverly Hills, CA', 'Paid'), (28, 28, '2024-05-28', 120000.00, 'Chelsea, London', 'Paid'),
(29, 29, '2024-05-29', 110000.00, 'Andheri, Mumbai', 'Paid'), (30, 30, '2024-05-30', 110000.00, 'Bandra, Mumbai', 'Paid'),
(31, 31, '2024-05-01', 180000.00, 'Clifton, Karachi', 'Paid'), (32, 32, '2024-05-02', 180000.00, 'DHA, Lahore', 'Paid'),
(33, 33, '2024-05-03', 190000.00, 'F-8, Islamabad', 'Paid'), (34, 34, '2024-05-04', 190000.00, 'Gulberg, Lahore', 'Paid'),
(35, 35, '2024-05-05', 50000.00, 'PECHS, Karachi', 'Paid'), (36, 36, '2024-05-06', 50000.00, 'Blue Area, Islamabad', 'Paid'),
(37, 37, '2024-05-07', 85000.00, 'Saddar, Karachi', 'Paid'), (38, 38, '2024-05-08', 85000.00, 'Model Town, Lahore', 'Paid'),
(39, 39, '2024-05-09', 75000.00, 'G-11, Islamabad', 'Paid'), (40, 40, '2024-05-10', 75000.00, 'Cantt, Peshawar', 'Paid'),
(41, 41, '2024-05-11', 95000.00, 'Malibu, CA', 'Paid'), (42, 42, '2024-05-12', 95000.00, 'Notting Hill, London', 'Paid'),
(43, 43, '2024-05-13', 170000.00, 'Sydney, Australia', 'Paid'), (44, 44, '2024-05-14', 170000.00, 'Manhattan, NY', 'Paid'),
(45, 45, '2024-05-15', 82000.00, 'Dublin, Ireland', 'Paid'), (46, 46, '2024-05-16', 82000.00, 'DHA, Karachi', 'Paid'),
(47, 47, '2024-05-17', 62000.00, 'Bahria Town, Lahore', 'Paid'), (48, 48, '2024-05-18', 62000.00, 'DHA, Islamabad', 'Paid'),
(49, 49, '2024-05-19', 160000.00, 'Gulberg, Lahore', 'Paid'), (50, 50, '2024-05-20', 160000.00, 'F-7, Islamabad', 'Paid');


-- Query 1: [Shows all active planes in the airline]
SELECT 
    registration_number, 
    manufacturer, 
    model, 
    total_seats 
FROM Aircraft 
WHERE is_active = 1;


-- Query 2: [Finds all Pakistani passengers born after 1990]
SELECT 
    first_name, 
    last_name, 
    passport_number, 
    date_of_birth 
FROM Passenger 
WHERE nationality = 'Pakistani' 
  AND date_of_birth > '1990-12-31';


-- Query 3: [Counts the total number of confirmed bookings]
SELECT 
    COUNT(booking_id) AS total_confirmed_bookings 
FROM Booking 
WHERE booking_status = 'Confirmed';


-- Query 4: [Shows the top 5 most expensive flights]
SELECT TOP 5
    flight_number, 
    airline_name, 
    base_price 
FROM Flight 
ORDER BY base_price DESC;


-- Query 5: [Shows flight routes and changes distance from kilometers to miles]
SELECT 
    route_id, 
    distance_km, 
    (distance_km * 0.621371) AS distance_miles,
    estimated_duration_min
FROM Route;


-- Query 6: [Shows employee names and their job titles]
SELECT 
    e.first_name, 
    e.last_name, 
    r.role_name 
FROM Employee e
JOIN EmployeeRole er ON e.employee_id = er.employee_id
JOIN Role r ON er.role_id = r.role_id;


-- Query 7: [Counts how many flights each airline has]
SELECT 
    airline_name, 
    COUNT(flight_id) AS total_flights 
FROM Flight 
GROUP BY airline_name;


-- Query 8: [Finds airports that have more than 3 gates]
SELECT 
    a.airport_name, 
    COUNT(g.gate_id) AS total_gates 
FROM Airport a
JOIN Gate g ON a.airport_id = g.airport_id
GROUP BY a.airport_name
HAVING COUNT(g.gate_id) > 3;


-- Query 9: [Shows employees and the names of their managers]
SELECT 
    emp.first_name AS employee_name, 
    emp.last_name AS employee_surname,
    mgr.first_name AS manager_name, 
    mgr.last_name AS manager_surname
FROM Employee emp
LEFT JOIN Employee mgr ON emp.manager_id = mgr.employee_id;


-- Query 10: [Shows plane maintenance tasks done in May 2024]
SELECT 
    ac.registration_number, 
    mt.type_name, 
    me.event_date, 
    me.status 
FROM MaintenanceEvent me
JOIN Aircraft ac ON me.aircraft_id = ac.aircraft_id
JOIN MaintenanceType mt ON me.maintenance_type_id = mt.maintenance_type_id
WHERE me.event_date BETWEEN '2024-05-01' AND '2024-05-31';


-- Query 11: [Finds passengers who spent more than 100,000 on a booking]
SELECT 
    first_name, 
    last_name, 
    email 
FROM Passenger 
WHERE passenger_id IN (
    SELECT passenger_id 
    FROM BookingPassenger bp
    JOIN Booking b ON bp.booking_id = b.booking_id
    WHERE b.total_amount > 100000
);


-- Query 12: [Finds flights that cost more than the average flight price]
SELECT 
    flight_number, 
    airline_name, 
    base_price 
FROM Flight f
WHERE base_price > (
    SELECT AVG(base_price) FROM Flight
);


-- Query 13: [Calculates total money made from tickets for each scheduled flight]
SELECT 
    fs.flight_schedule_id, 
    f.flight_number, 
    SUM(t.ticket_price) AS total_revenue,
    COUNT(t.ticket_id) AS tickets_sold
FROM FlightSchedule fs
JOIN Flight f ON fs.flight_id = f.flight_id
JOIN Ticket t ON fs.flight_schedule_id = t.flight_schedule_id
GROUP BY fs.flight_schedule_id, f.flight_number;


-- Query 14: [Makes a list of passengers, their flight numbers, and seat numbers]
SELECT 
    p.first_name, 
    p.last_name, 
    f.flight_number, 
    fs.scheduled_departure, 
    s.seat_number, 
    t.class_type
FROM Ticket t
JOIN Passenger p ON t.passenger_id = p.passenger_id
JOIN FlightSchedule fs ON t.flight_schedule_id = fs.flight_schedule_id
JOIN Flight f ON fs.flight_id = f.flight_id
JOIN SeatAssignment sa ON t.ticket_id = sa.ticket_id
JOIN Seat s ON sa.seat_id = s.seat_id;


-- Query 15: [Finds registered passengers who have never booked a ticket]
SELECT 
    first_name, 
    last_name, 
    email 
FROM Passenger 
WHERE passenger_id NOT IN (
    SELECT passenger_id FROM BookingPassenger
);


-- Query 16: [Checks if a flight left on time or was delayed]
SELECT 
    f.flight_number, 
    fs.scheduled_departure, 
    fs.actual_departure,
    CASE 
        WHEN fs.actual_departure > fs.scheduled_departure THEN 'Delayed'
        WHEN fs.actual_departure IS NULL THEN 'Pending'
        ELSE 'On Time' 
    END AS departure_status
FROM FlightSchedule fs
JOIN Flight f ON fs.flight_id = f.flight_id;


-- Query 17: [Calculates the total weight of all bags on each flight]
SELECT 
    fs.flight_schedule_id, 
    f.flight_number, 
    SUM(b.weight_kg) AS total_baggage_weight
FROM FlightSchedule fs
JOIN Flight f ON fs.flight_id = f.flight_id  -- This was the missing line!
JOIN Ticket t ON fs.flight_schedule_id = t.flight_schedule_id
JOIN CheckIn c ON t.ticket_id = c.ticket_id
JOIN Baggage b ON c.check_in_id = b.check_in_id
GROUP BY fs.flight_schedule_id, f.flight_number
ORDER BY total_baggage_weight DESC;

-- Query 18: [Finds the most used check-in method for flights leaving from Karachi]
SELECT check_in_method, COUNT(*) AS usage_count
FROM CheckIn
WHERE ticket_id IN (
    SELECT t.ticket_id 
    FROM Ticket t
    JOIN FlightSchedule fs ON t.flight_schedule_id = fs.flight_schedule_id
    JOIN Flight f ON fs.flight_id = f.flight_id
    JOIN Route r ON f.route_id = r.route_id
    JOIN Airport a ON r.origin_airport_id = a.airport_id
    WHERE a.iata_code = 'KHI'
)
GROUP BY check_in_method
ORDER BY usage_count DESC;


-- Query 19: [Counts how many passengers have traveled between two specific cities]
SELECT 
    orig.city AS origin, 
    dest.city AS destination, 
    COUNT(t.passenger_id) AS total_passengers
FROM Route r
JOIN Airport orig ON r.origin_airport_id = orig.airport_id
JOIN Airport dest ON r.destination_airport_id = dest.airport_id
JOIN Flight f ON r.route_id = f.route_id
JOIN FlightSchedule fs ON f.flight_id = fs.flight_id
JOIN Ticket t ON fs.flight_schedule_id = t.flight_schedule_id
GROUP BY orig.city, dest.city
ORDER BY total_passengers DESC;


-- Query 20: [Shows total money collected by each payment method, ignoring methods under 50,000]
SELECT 
    payment_method, 
    COUNT(payment_id) AS number_of_transactions,
    SUM(payment_amount) AS total_revenue_collected
FROM Payment
WHERE payment_status = 'Completed'
GROUP BY payment_method
HAVING SUM(payment_amount) >= 50000
ORDER BY total_revenue_collected DESC;

