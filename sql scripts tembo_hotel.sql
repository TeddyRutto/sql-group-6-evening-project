create schema tembo_hotel;
set search_path to tembo_hotel;

create table staging_bookings (booking_id text, guest_name text, guest_phone text,
guest_city TEXT,
guest_nationality TEXT,
room_no TEXT,
room_type TEXT,
room_rate_per_night TEXT,
check_in_date TEXT,
check_out_date TEXT,
nights_stayed TEXT,
staff_name TEXT,
staff_department TEXT,
staff_salary TEXT,
payment_method TEXT,
booking_status TEXT,
total_amount TEXT,
service_used TEXT,
service_price TEXT,
guest_rating TEXT
);

select *from staging_bookings;

--duplicating the staging table
 
create table cleaned_bookings as
select * from staging_bookings;


select *from cleaned_bookings;

-- ENSURE EVERYTHING IS IN A CORRECT DATA TYPE
-- Room_rate_per_night to number
 
alter table cleaned_bookings
alter column room_rate_per_night type numeric using room_rate_per_night::numeric;

-- night_stayed to numeric
update cleaned_bookings
set nights_stayed=abs(nights_stayed)
where nights_stayed = -3;

alter table cleaned_bookings
alter column nights_stayed type numeric using nights_stayed::numeric;

-- Staff_salary to numeric

UPDATE cleaned_bookings
SET staff_salary = REPLACE(staff_salary, 'KES', ' ')
WHERE staff_salary like 'KES%';

UPDATE cleaned_bookings
SET staff_salary = NULL
WHERE staff_salary = '' OR staff_salary = ' ';

alter table cleaned_bookings
alter column staff_salary type numeric using staff_salary::numeric;

SELECT staff_salary 
FROM cleaned_bookings 
WHERE staff_salary LIKE '%,%';

UPDATE cleaned_bookings
SET staff_salary = NULL
WHERE staff_salary LIKE '%,%';

-- -- total amount to numeric

update cleaned_bookings
SET total_amount= CASE 
    -- 1. Remove 'KES' and any commas, then trim whitespace
    WHEN TRIM(REPLACE(REPLACE(total_amount, 'KES', ''), ',', '')) = '' THEN NULL
    ---2. Remove coma
    WHEN TRIM(total_amount) = ',' THEN NULl
    ELSE TRIM(REPLACE(REPLACE(total_amount, 'KES', ''), ',', ''))
END
WHERE total_amount IS NOT NULL;

alter table cleaned_bookings
alter column total_amount type numeric using total_amount::numeric;

-- service_price to numeric

UPDATE cleaned_bookings
SET service_price = null 
where  trim(service_price)= '';

alter table cleaned_bookings
alter column service_price type numeric using service_price::numeric;

--Converting guest_rating from text to numeric

UPDATE cleaned_bookings
SET guest_rating = NULL
WHERE guest_rating = '';
 
alter table cleaned_bookings
alter column guest_rating type numeric using guest_rating::numeric;

-- Dates

UPDATE cleaned_bookings
SET check_in_date = REPLACE(check_in_date, '/', '-'),
    check_out_date = REPLACE(check_out_date, '/', '-')
WHERE check_in_date LIKE '%/%'
   OR check_out_date LIKE '%/%';

UPDATE cleaned_bookings
SET check_in_date = CASE
        WHEN length(check_in_date) = 8 THEN substr(check_in_date, 1, 6) || '20' || substr(check_in_date, 7, 2)
        ELSE check_in_date
    END,
    check_out_date = CASE
        WHEN length(check_out_date) = 8 THEN substr(check_out_date, 1, 6) || '20' || substr(check_out_date, 7, 2)
        ELSE check_out_date
    END
WHERE check_in_date LIKE '%-%' OR check_out_date LIKE '%-%';
 
ALTER TABLE cleaned_bookings
ALTER COLUMN check_in_date TYPE DATE
USING TO_DATE(check_in_date, 'DD-MM-YYYY'),
ALTER COLUMN check_out_date TYPE DATE
USING TO_DATE(check_out_date, 'DD-MM-YYYY');
ALTER TABLE staging_bookings
ALTER COLUMN check_in_date TYPE DATE
USING (
    CASE
        WHEN check_in_date LIKE '-%' THEN check_in_date::DATE UPDATE cleaned_bookings
SET check_in_date = CASE
        WHEN length(check_in_date) = 8 THEN substr(check_in_date, 1, 6) || '20' || substr(check_in_date, 7, 2)
        ELSE check_in_date
    END,
    check_out_date = CASE
        WHEN length(check_out_date) = 8 THEN substr(check_out_date, 1, 6) || '20' || substr(check_out_date, 7, 2)
        ELSE check_out_date
    END
WHERE check_in_date LIKE '%-%' OR check_out_date LIKE '%-%';
        ELSE TO_DATE(check_in_date, 'DD-MM-YYYY')              
    END
),
ALTER COLUMN check_out_date TYPE DATE
USING (
    CASE
        WHEN check_out_date LIKE '-%' THEN check_out_date::DATE
        ELSE TO_DATE(check_out_date, 'DD-MM-YYYY')
    END
);
ALTER TABLE cleaned_bookings 
ALTER COLUMN check_in_date TYPE DATE 
USING (
    CASE 
        WHEN check_in_date LIKE '____-%' THEN check_in_date::DATE
        WHEN (split_part(check_in_date, '-', 1)::INTEGER) > 12 THEN to_date(check_in_date, 'DD-MM-YYYY')
        WHEN (split_part(check_in_date, '-', 2)::INTEGER) > 12 THEN to_date(check_in_date, 'MM-DD-YYYY')
        ELSE to_date(check_in_date, 'DD-MM-YYYY')
    END
);

alter table cleaned_bookings
alter column check_out_date type date using check_out_date::date;

update cleaned_bookings
set guest_city=initcap(replace(guest_city, 'Thikax', 'Thika')), 
guest_nationality=initcap(guest_nationality),
guest_name= initcap(trim(guest_name));

UPDATE cleaned_bookings
SET room_type = CASE 
    WHEN room_type = 'Dlx' THEN 'Deluxe'
    WHEN room_type = 'Std' THEN 'Standard'
    when room_type = 'dlx' then 'Deluxe'
    ELSE room_type 
END
WHERE room_type IN ('Dlx', 'Std', 'dlx');
 
update cleaned_bookings
set room_type=initcap(room_type),
booking_status=initcap(booking_status);
select room_type 
from cleaned_bookings;

select *from cleaned_bookings;

-- having a uniform format for the guest_phone
UPDATE cleaned_bookings
SET guest_phone = TRIM(guest_phone);

UPDATE cleaned_bookings
SET guest_phone = '0' || SUBSTRING(guest_phone FROM 5)
WHERE guest_phone LIKE '+254%';

UPDATE cleaned_bookings
SET guest_phone = REPLACE(guest_phone, '-', '');

UPDATE cleaned_bookings
SET guest_phone = NULL
WHERE guest_phone = '' OR guest_phone = ' ';

select payment_method 
from cleaned_bookings;

update cleaned_bookings
set payment_method= case
	when payment_method= 'Mpesa' then 'M-Pesa'
	when payment_method= 'mpesa' then 'M-Pesa'
	else payment_method
end
where payment_method in ('Mpesa', 'mpesa');


---1.	Revenue Analysis - Which months, room types and payment methods bring in the most money?

SELECT 
    date_trunc('month', check_in_date) AS revenue_month,
    -- Revenue by Room Type
    SUM(CASE WHEN room_type = 'Standard' THEN total_amount ELSE 0 END) AS revenue_standard,
    SUM(CASE WHEN room_type = 'Deluxe' THEN total_amount ELSE 0 END) AS revenue_deluxe,
    SUM(CASE WHEN room_type = 'Suite' THEN total_amount ELSE 0 END) AS revenue_suite,
    SUM(case when room_type = 'Penthouse' then total_amount else 0 end) as revenue_penthouse,
    -- Revenue by Payment Method
    SUM(CASE WHEN payment_method = 'Card' THEN total_amount ELSE 0 END) AS rev_card,
    SUM(CASE WHEN payment_method = 'Cash' THEN total_amount ELSE 0 END) AS rev_cash,
    SUM(case when payment_method = 'M-Pesa' then total_amount else 0 end) as rev_mpesa,
    SUM(case when payment_method = 'Bank Transfer' then total_amount else 0 end) as rev_bank,
    -- Total Monthly Revenue
    SUM(total_amount) AS total_monthly_revenue
FROM cleaned_bookings
GROUP BY 1
ORDER BY revenue_month asc;


---2.   Occupancy - Which rooms are booked most? How long do guests stay on average?
    
select room_type, count(*) booking_status, round(avg(nights_stayed))
from cleaned_bookings
group by 1
order by booking_status desc;


---3   Guest Insights - Where do guests come from? Are they happy? Who rates us best?

select guest_name, guest_city, round(avg(guest_rating))
from cleaned_bookings
group by 1,2
having avg(guest_rating)> 3
order by 3 desc;

---4   Staff Performance - Who handles the most bookings? Which department generates the most revenue?

select staff_name, count(booking_id) as total_bookings, 
rank() over(order by 3 desc)
from cleaned_bookings
group by 1
limit 1;

select staff_department, sum(total_amount) as total_bookings, 
rank() over(order by 3 desc)
from cleaned_bookings
group by 1
limit 1;

---5	Trends - Revenue growth month over month (window function). Busiest vs quietest months

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', check_in_date) AS booking_month,
        SUM(total_amount) AS revenue
    FROM cleaned_bookings
    GROUP BY 1
)
SELECT 
    booking_month,
    revenue,
    LAG(revenue) OVER (ORDER BY booking_month) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY booking_month)) / 
        LAG(revenue) OVER (ORDER BY booking_month) * 100, 2
    ) AS revenue_growth_pct
FROM monthly_revenue;

SELECT 
    DATE_TRUNC('month', check_in_date) AS booking_month,
    COUNT(booking_id) AS total_bookings,
    SUM(total_amount) AS revenue,
    RANK() OVER (ORDER BY COUNT(booking_id) DESC) AS busy_rank,
    RANK() OVER (ORDER BY SUM(total_amount) ASC) AS quiet_rank
FROM cleaned_bookings
GROUP BY 1;

---6   Cancellations - What is our cancellation rate? How much revenue did we lose?**

select 
    count(*) as total_bookings,
    COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) AS cancelled_bookings_count,
    round(COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*) )AS cancel_rate_pct,
    SUM(CASE WHEN booking_status = 'Checked Out' THEN total_amount ELSE 0 END) AS actual_revenue,
    SUM(CASE WHEN booking_status = 'Cancelled' THEN total_amount ELSE 0 END) AS lost_revenue
FROM cleaned_bookings;


    
    
