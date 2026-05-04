Tembo Hotel & Suites
SQL Group Project  |  Week 3 Capstone  |  PostgreSQL + Power BI

 Project Scenario

You have just been hired as a Junior Data Analyst at Tembo Hotel & Suites ,  a mid-range business hotel in Nairobi. The hotel has been running since 2023 and keeping records in a spreadsheet. That spreadsheet is a mess.

Your manager , the Hotel Director ,  has handed you a raw CSV export of all booking data and said:

💬  Message from the Hotel Director
"We need to understand how the hotel is performing. The data team before you kept everything in Excel and it is full of errors.
I need you to clean this data, load it into our new database, analyse it, and present your findings to the management team on Friday.
I want to know: which rooms make us the most money, which months are busiest, how our staff are performing, and whether our guests are happy.
Make it look professional  use Power BI for the visuals."

This is your team's job for the week. By Friday, you will present your findings as a data analyst team . 
Project Timeline -  4 Days

Day	Focus	What You Deliver at End of Day
Monday	Setup + Data Cleaning	Clean table loaded in PostgreSQL. All dirty problems fixed. Screenshot of SELECT * showing clean data.
Tuesday	Analysis -  Queries	All analysis queries written and tested. Results saved as notes/screenshots. CTEs and window functions done.
Wednesday	Views + Indexing + Power BI	All views created. Indexes added. Power BI connected to PostgreSQL. At least 3 visuals built.
Friday	Presentations	10-minute group presentation. Power BI dashboard shown live. Each member speaks.


The Data – tembo_hotel_dirty.csv
You will receive a CSV file with ~285 rows of hotel booking records. This is real-world style data - it has many problems that you must find and fix before any analysis can begin.

Columns in the CSV
Column	Description	Expected Clean Format
booking_id	Unique booking reference	BK0001, BK0002 ...
guest_name	Full name of guest	Title Case - e.g. Alice Mwangi
guest_phone	Guest phone number	07XXXXXXXX (10 digits, no dashes or +254)
guest_city	Guest home city	Title Case - e.g. Nairobi
guest_nationality	Guest nationality	Title Case - e.g. Kenyan
room_no	Room number	101, 201, 301 etc.
room_type	Type of room	Standard / Deluxe / Suite / Penthouse
room_rate_per_night	Nightly rate in KES	Numeric - e.g. 5500
check_in_date	Date guest checked in	YYYY-MM-DD
check_out_date	Date guest checked out	YYYY-MM-DD
nights_stayed	Number of nights	Positive integer
staff_name	Staff who handled booking	Title Case
staff_department	Staff department	Front Desk / Housekeeping / Restaurant / Security / Management
staff_salary	Staff monthly salary in KES	Numeric - e.g. 42000
payment_method	How guest paid	M-Pesa / Cash / Card / Bank Transfer
booking_status	Outcome of booking	Checked Out / Cancelled / No Show
total_amount	Total billed in KES	Numeric - e.g. 11000
service_used	Extra service used (if any)	Room Service / Laundry / Airport Pickup etc. or blank
service_price	Price of service in KES	Numeric or blank
guest_rating	Guest satisfaction rating	1 to 5 (integer)

Known Dirt Data Problems to Fix
Your job is to identify every instance of each problem and fix it using SQL. Use SELECT before every UPDATE.

What Your Group Must Deliver
Deliverable 1 - Clean Database (Monday EOD)
•	DDL: CREATE SCHEMA + all tables with correct data types, primary keys, and constraints
•	Import: CSV loaded into a staging table using pgAdmin's import tool
•	Cleaning script: All 22 dirty problems identified and fixed with SQL — commented and organised
•	Clean view: A final view called v_clean_bookings that shows only clean, valid data

Deliverable 2 - Analysis Queries (Tuesday EOD)
At minimum, your group must write queries answering these business questions:
1.	Revenue analysis: Total revenue by month, by room type, by payment method
2.	Occupancy: Which room types are booked most? Average nights stayed per room type
3.	Guest insights: Top 10 cities guests come from. Average rating per room type
4.	Staff performance: Which staff handled the most bookings? Which department generates most revenue?
5.	Trends: Revenue growth month over month (window function). Busiest vs quietest months
6.	Cancellations: Cancellation rate per room type. Revenue lost from cancellations and no-shows

Deliverable 3 - Views, Indexes & Power BI (Wednesday EOD)
•	At least 4 views created - one per major business area (revenue, occupancy, guests, staff)
•	Indexes on all foreign key-equivalent columns (room_no, staff_name, guest_city, check_in_date)
•	Power BI connected to your PostgreSQL database
•	At least 5 visuals in Power BI - see Power BI section for suggestions
•	
Deliverable 4 - Friday Presentation (10 minutes)
•	Slide 1: Group intro  - who you are, your roles, the business problem
•	Slide 2: The data - what was in the CSV, how dirty it was, what you found
•	Slide 3: Data cleaning - walk through 3 of the most interesting problems you fixed (show the SQL)
•	Slide 4-6: Key findings - answer the Director's questions with your queries and Power BI visuals
•	Slide 7: Recommendations - based on your data, what should the hotel do next?
•	Every group member must speak for at least 2 minutes

Golden Rules

7.	SELECT before every UPDATE or DELETE — confirm your WHERE clause before changing any data
8.	Always use CREATE OR REPLACE VIEW — never bare CREATE VIEW
9.	Comment your SQL — write -- what this query does above every major block
10.	Use INITCAP for names, UPPER/LOWER only when needed — PostgreSQL only, not MySQL
11.	REGEXP_REPLACE for phone and salary cleaning — pattern [^0-9] removes all non-numeric characters
12.	Test subqueries alone first — run the inner query before embedding it
13.	Connect Power BI to views, not raw tables — cleaner, safer, easier to update
14.	Every group member must understand every query — the instructor will check


