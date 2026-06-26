CREATE DATABASE IF NOT EXISTS HotelManagementDB;
USE HotelManagementDB;

CREATE TABLE IF NOT EXISTS hotel (
    hotelid INT AUTO_INCREMENT PRIMARY KEY,
    hotelname VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    starrating INT CHECK(starrating BETWEEN 1 AND 5)
);


CREATE TABLE IF NOT EXISTS roomtype (
    roomtypeid INT AUTO_INCREMENT PRIMARY KEY,
    roomtypename VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    capacity INT NOT NULL,
    baseprice DECIMAL(10,2) NOT NULL
);



CREATE TABLE IF NOT EXISTS room (
    roomid INT AUTO_INCREMENT PRIMARY KEY,

    hotelid INT NOT NULL,
    roomtypeid INT NOT NULL,

    roomnumber VARCHAR(10) NOT NULL UNIQUE,
    floor INT NOT NULL,

    roomstatus ENUM(
        'Available',
        'Occupied',
        'Reserved',
        'Cleaning',
        'Maintenance',
        'Out of Service'
    ) NOT NULL DEFAULT 'Available',

    CONSTRAINT fk_room_hotel
    FOREIGN KEY(hotelid)
    REFERENCES hotel(hotelid)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_room_type
    FOREIGN KEY(roomtypeid)
    REFERENCES roomtype(roomtypeid)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS guest (

    guestid INT AUTO_INCREMENT PRIMARY KEY,

    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,

    email VARCHAR(100) UNIQUE,

    phone VARCHAR(20),

    nationality VARCHAR(100),

    registrationdate DATE DEFAULT(CURRENT_DATE)
);


CREATE TABLE IF NOT EXISTS cancellationreason (

    reasonid INT AUTO_INCREMENT PRIMARY KEY,

    reasonname VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS reservation (

    reservationid INT AUTO_INCREMENT PRIMARY KEY,

    guestid INT NOT NULL,

    roomid INT NOT NULL,

    cancellationreasonid INT,

    checkindate DATE NOT NULL,

    checkoutdate DATE NOT NULL,

    adults INT NOT NULL,

    children INT DEFAULT 0,

    reservationstatus ENUM(
        'Booked',
        'Checked In',
        'Checked Out',
        'Cancelled',
        'No Show'
    ) NOT NULL,

    specialrequests VARCHAR(255),

    CONSTRAINT fk_reservation_guest
    FOREIGN KEY(guestid)
    REFERENCES guest(guestid)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_reservation_room
    FOREIGN KEY(roomid)
    REFERENCES room(roomid)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

    CONSTRAINT fk_reservation_cancel
    FOREIGN KEY(cancellationreasonid)
    REFERENCES cancellationreason(reasonid)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);



CREATE TABLE IF NOT EXISTS payment (

    paymentid INT AUTO_INCREMENT PRIMARY KEY,

    reservationid INT NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    paymentmethod ENUM(
        'Cash',
        'Credit Card',
        'Debit Card',
        'PayPal',
        'Bank Transfer'
    ) NOT NULL,

    paymentstatus ENUM(
        'Pending',
        'Paid',
        'Refunded',
        'Failed'
    ) NOT NULL,

    paymentdate DATETIME,

    CONSTRAINT fk_payment_reservation
    FOREIGN KEY(reservationid)
    REFERENCES reservation(reservationid)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS invoice (

    invoiceid INT AUTO_INCREMENT PRIMARY KEY,

    reservationid INT NOT NULL,

    subtotal DECIMAL(10,2),

    tax DECIMAL(10,2),

    discount DECIMAL(10,2),

    totalamount DECIMAL(10,2),

    issuedate DATE,

    CONSTRAINT fk_invoice_reservation
    FOREIGN KEY(reservationid)
    REFERENCES reservation(reservationid)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS department (

    departmentid INT AUTO_INCREMENT PRIMARY KEY,

    departmentname VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS staff (

    staffid INT AUTO_INCREMENT PRIMARY KEY,

    departmentid INT NOT NULL,

    firstname VARCHAR(50),

    lastname VARCHAR(50),

    position VARCHAR(100),

    salary DECIMAL(10,2),

    hiredate DATE,

    phone VARCHAR(20),

    CONSTRAINT fk_staff_department
    FOREIGN KEY(departmentid)
    REFERENCES department(departmentid)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS service (

    serviceid INT AUTO_INCREMENT PRIMARY KEY,

    servicename VARCHAR(100) UNIQUE NOT NULL,

    price DECIMAL(10,2) NOT NULL
);


CREATE TABLE IF NOT EXISTS reservationservice (

    reservationserviceid INT AUTO_INCREMENT PRIMARY KEY,

    reservationid INT NOT NULL,

    serviceid INT NOT NULL,

    quantity INT DEFAULT 1,

    totalprice DECIMAL(10,2),

    CONSTRAINT fk_rs_reservation
    FOREIGN KEY(reservationid)
    REFERENCES reservation(reservationid)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_rs_service
    FOREIGN KEY(serviceid)
    REFERENCES service(serviceid)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS housekeeping (

    housekeepingid INT AUTO_INCREMENT PRIMARY KEY,

    roomid INT NOT NULL,

    staffid INT NOT NULL,

    cleaningdate DATE,

    status ENUM(
        'Scheduled',
        'In Progress',
        'Completed',
        'Maintenance Required'
    ) NOT NULL,

    remarks VARCHAR(255),

    CONSTRAINT fk_housekeeping_room
    FOREIGN KEY(roomid)
    REFERENCES room(roomid)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_housekeeping_staff
    FOREIGN KEY(staffid)
    REFERENCES staff(staffid)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


USE HotelManagementDB;


INSERT INTO hotel
(hotelname, phone, email, starrating)
VALUES
('Grand Horizon Hotel', '+49 30 4567890', 'info@grandhorizon.com', 5);

INSERT INTO roomtype
(roomtypename, description, capacity, baseprice)
VALUES
('Standard','Standard Queen Room',2,120.00),
('Deluxe','Deluxe Balcony Room',2,180.00),
('Suite','Luxury Suite',4,350.00);



INSERT INTO room
(hotelid, roomtypeid, roomnumber, floor, roomstatus)
VALUES
(1,1,'101',1,'Available'),
(1,1,'102',1,'Occupied'),
(1,2,'201',2,'Reserved'),
(1,2,'202',2,'Available'),
(1,3,'301',3,'Occupied'),
(1,3,'302',3,'Maintenance');



INSERT INTO guest
(firstname, lastname, email, phone, nationality)
VALUES
('Rahul','Sharma','rahul.sharma@email.com','9876543210','Indian'),
('Priya','Patel','priya.patel@email.com','9876543211','Indian'),
('Arjun','Singh','arjun.singh@email.com','9876543212','Indian'),
('Ananya','Verma','ananya.verma@email.com','9876543213','Indian'),
('Lukas','Müller','lukas.mueller@email.com','030123456','German'),
('Emma','Schmidt','emma.schmidt@email.com','030223344','German'),
('Leon','Weber','leon.weber@email.com','030998877','German'),
('Sophie','Fischer','sophie.fischer@email.com','030776655','German');


INSERT INTO cancellationreason
(reasonname)
VALUES
('Guest Cancelled'),
('Payment Failed'),
('No Show'),
('Overbooking');



INSERT INTO reservation
(guestid, roomid, cancellationreasonid,
checkindate, checkoutdate,
adults, children,
reservationstatus,
specialrequests)
VALUES
(1,2,NULL,'2026-07-01','2026-07-04',2,0,'Checked In','Late Check-In'),

(2,3,NULL,'2026-07-05','2026-07-08',2,1,'Booked','Extra Pillow'),

(3,5,NULL,'2026-07-03','2026-07-06',1,0,'Checked Out',NULL),

(4,6,1,'2026-07-10','2026-07-12',2,0,'Cancelled',NULL),

(5,1,NULL,'2026-07-11','2026-07-13',2,0,'Booked',NULL),

(6,4,NULL,'2026-07-15','2026-07-18',2,0,'Checked In','High Floor'),

(7,5,3,'2026-07-20','2026-07-22',2,0,'No Show',NULL),

(8,2,NULL,'2026-07-23','2026-07-26',1,0,'Booked',NULL);



INSERT INTO payment
(reservationid, amount,
paymentmethod,
paymentstatus,
paymentdate)
VALUES
(1,360,'Credit Card','Paid','2026-07-01 10:00:00'),
(2,540,'Debit Card','Pending',NULL),
(3,1050,'Cash','Paid','2026-07-03 15:00:00'),
(4,0,'Credit Card','Refunded','2026-07-10 09:00:00'),
(5,240,'PayPal','Paid','2026-07-11 11:00:00'),
(6,540,'Bank Transfer','Pending',NULL),
(7,0,'Credit Card','Failed',NULL),
(8,360,'Debit Card','Paid','2026-07-23 14:00:00');



INSERT INTO invoice
(reservationid, subtotal, tax, discount,
totalamount, issuedate)
VALUES
(1,320,40,0,360,'2026-07-04'),
(2,480,60,0,540,'2026-07-08'),
(3,930,120,0,1050,'2026-07-06'),
(5,210,30,0,240,'2026-07-13'),
(8,320,40,0,360,'2026-07-26');



INSERT INTO department
(departmentname)
VALUES
('Reception'),
('Housekeeping'),
('Restaurant'),
('Maintenance');



INSERT INTO staff
(departmentid, firstname, lastname,
position, salary, hiredate, phone)
VALUES
(1,'Amit','Mehra','Receptionist',3200,'2023-01-10','111111111'),

(2,'Neha','Kapoor','Housekeeper',2800,'2024-02-15','222222222'),

(3,'Thomas','Becker','Chef',4200,'2022-06-12','333333333'),

(4,'Julia','Wagner','Maintenance Engineer',3800,'2023-08-01','444444444'),

(1,'Karan','Malhotra','Front Desk Manager',4500,'2021-03-18','555555555'),

(2,'Anna','Schneider','Housekeeper',2900,'2024-01-20','666666666');



INSERT INTO service
(servicename, price)
VALUES
('Breakfast',25),
('Laundry',15),
('Airport Pickup',60),
('Spa',90),
('Room Service',35);


INSERT INTO reservationservice
(reservationid, serviceid, quantity, totalprice)
VALUES
(1,1,2,50),
(1,5,1,35),
(2,4,1,90),
(3,2,2,30),
(6,3,1,60);



INSERT INTO housekeeping
(roomid, staffid, cleaningdate,
status, remarks)
VALUES
(1,2,'2026-07-01','Completed','Routine Cleaning'),
(2,6,'2026-07-02','Completed','Guest Checked In'),
(4,2,'2026-07-03','Scheduled','Morning Shift'),
(6,6,'2026-07-04','Maintenance Required','Air Conditioner Fault');
