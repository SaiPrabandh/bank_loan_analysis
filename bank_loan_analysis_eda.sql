USE bankloananalysis;
CREATE TABLE bank_loan_analysis (
    id INT PRIMARY KEY,
    address_state VARCHAR(5),
    application_type VARCHAR(20),
    emp_length VARCHAR(20),
    emp_title VARCHAR(255),
    grade CHAR(1),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date VARCHAR(20), -- kept as VARCHAR because some rows may be NULL or non-date
    member_id INT,
    purpose VARCHAR(100),
    sub_grade VARCHAR(5),
    term VARCHAR(20),
    verification_status VARCHAR(50),
    annual_income DECIMAL(15,2),
    dti DECIMAL(10,4),
    installment DECIMAL(10,2),
    int_rate DECIMAL(6,4),
    loan_amount DECIMAL(10,2),
    total_acc INT,
    total_payment DECIMAL(15,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/financial_loan.csv'
INTO TABLE bank_loan_analysis
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @address_state, @application_type, @emp_length, @emp_title, @grade,
 @home_ownership, @issue_date, @last_credit_pull_date, @last_payment_date,
 @loan_status, @next_payment_date, @member_id, @purpose, @sub_grade, @term,
 @verification_status, @annual_income, @dti, @installment, @int_rate,
 @loan_amount, @total_acc, @total_payment)
SET
id = @id,
address_state = @address_state,
application_type = @application_type,
emp_length = @emp_length,
emp_title = @emp_title,
grade = @grade,
home_ownership = @home_ownership,
issue_date = STR_TO_DATE(@issue_date, '%d-%m-%Y'),
last_credit_pull_date = STR_TO_DATE(@last_credit_pull_date, '%d-%m-%Y'),
last_payment_date = STR_TO_DATE(@last_payment_date, '%d-%m-%Y'),
loan_status = @loan_status,
next_payment_date = NULLIF(@next_payment_date, ''),
member_id = @member_id,
purpose = @purpose,
sub_grade = @sub_grade,
term = @term,
verification_status = @verification_status,
annual_income = @annual_income,
dti = @dti,
installment = @installment,
int_rate = @int_rate,
loan_amount = @loan_amount,
total_acc = @total_acc,
total_payment = @total_payment;
use bankloananalysis;
select * from bank_loan_analysis;

--                             kpis first dashboard

-- total loan applications
select count(id) as total_applications 
from bank_loan_analysis;
-- returned 38576 ie total number of rows

 
-- mtd(month to date) loan applications
select count(id) as mtd_total_applications 
from bank_loan_analysis
where month(issue_date)=12 and Year(issue_date)=2021;
-- returned 4314 as output and we have selected december and 2021 cause in data it is latest month


-- pmtd(previous month to date) loan applications
select count(id) as pmtd_total_applications
from bank_loan_analysis
where month(issue_date)=11 and Year(issue_date)=2021;
-- returned 4035 as output

-- month on month loan applications(mtd-pmtd/pmtd)
select ((mtd.total-pmtd.total)*100/pmtd.total) as mom_growth_percentage
from
(select count(id) as total 
from bank_loan_analysis
where month(issue_date)=12 and Year(issue_date)=2021) mtd,
(select count(id) as total
from bank_loan_analysis
where month(issue_date)=11 and Year(issue_date)=2021)pmtd;
-- the process we have done is we took first 2 outputs and kept it under from,then we have used formula to calculate mom growth and returned it
-- returned 6.9145 as output


 -- total funded amount(column loan_amount)
 select sum(loan_amount) as total_funded_amount
 from bank_loan_analysis;
 -- output returned 435757075.00
 
 
 -- mtd total funded amount
 select sum(loan_amount) as total_funded_amount
 from bank_loan_analysis
 where month(issue_date)=12 and Year(issue_date)=2021;
 -- output returned '53981425.00'


-- pmtd total funded amount
 select sum(loan_amount) as total_funded_amount
 from bank_loan_analysis
 where month(issue_date)=11 and Year(issue_date)=2021;
 -- output returned '47754825.00'


-- month on month funded amount(mtd-pmtd/pmtd)
select ((mtd.total-pmtd.total)*100/pmtd.total) as mom_growth_percentage
from
(select sum(loan_amount) as total 
from bank_loan_analysis
where month(issue_date)=12 and Year(issue_date)=2021) mtd,
(select sum(loan_amount) as total
from bank_loan_analysis
where month(issue_date)=11 and Year(issue_date)=2021)pmtd;
-- returned 6.9145 as output
 
 
 -- total recieved amount(column total_payment)
 select sum(total_payment) as total_amount_recieved
 from bank_loan_analysis;
 -- output returned '473070933.00'
 
 -- mtd recieved amount
  select sum(total_payment) as mtd_amount_recieved
 from bank_loan_analysis
 where month(issue_date)=12 and Year(issue_date)=2021; 
-- output returned '58074380.00'


 -- pmtd recieved amount
  select sum(total_payment) as pmtd_amount_recieved
 from bank_loan_analysis
 where month(issue_date)=11 and Year(issue_date)=2021; 
-- output returned '50132030.00'


-- average interest rate
select round(avg(int_rate)*100,2) as avg_interest_rate
from bank_loan_analysis;
-- output returned '12.05'

--  mtd average interest rate
select round(avg(int_rate)*100,2) as mtd_avg_interest_rate
from bank_loan_analysis
where month(issue_date)=12 and Year(issue_date)=2021;
-- output returned '12.36'

-- pmtd average interest rate
select round(avg(int_rate)*100,2) as pmtd_avg_interest_rate
from bank_loan_analysis
where month(issue_date)=11 and Year(issue_date)=2021;
-- output returned '11.94'


-- average debt to income ratio(column dti)
select round(avg(dti)*100,2) as avg_dti
from bank_loan_analysis;
-- output returned '13.33'


-- mtd average debt to income ratio(column dti)
select round(avg(dti)*100,2) as mtd_avg_dti
from bank_loan_analysis
where month(issue_date)=12 and Year(issue_date)=2021;
-- output returned '13.67'


-- pmtd average debt to income ratio(column dti)
select round(avg(dti)*100,2) as pmtd_avg_dti
from bank_loan_analysis
where month(issue_date)=11 and Year(issue_date)=2021;
-- output returned '13.30'


-- now we need to see which is good loan and bad loan,in loan_status column if it is current or fully paid it is good loan else if it is charged off it is bad loan
-- now we need to cover the kpis of both of them like application percentage,applications,funded amount and total recievd amount of both good loan and bad loan


-- Good loan application percentage
select 
(count(case when loan_status='Fully Paid' or loan_status='Current' then id END))*100/count(id)
as good_loan_application_percentage
from bank_loan_analysis;
-- output returned '86.1753'


-- Good loan total funded amount
select 
(sum(case when loan_status='Fully Paid' or loan_status='Current' then loan_amount END))
as good_loan_total_funded_amount
from bank_loan_analysis;
-- output returned '370224850.00'


-- Good loan total funded amount percentage
select 
round((sum(case when loan_status='Fully Paid' or loan_status='Current' then loan_amount END))*100/sum(loan_amount),2)
as good_loan_total_funded_amount_percentage
from bank_loan_analysis;
-- output returned '84.96'


--  Good loan total RECIEVED amount
select 
(sum(case when loan_status='Fully Paid' or loan_status='Current' then  total_payment END))
as good_loan_total_recieved_amount
from bank_loan_analysis;
-- output returned '435786170.00'


-- Good loan total recieved amount percentage
select 
round((sum(case when loan_status='Fully Paid' or loan_status='Current' then total_payment END))*100/sum(total_payment),2)
as good_loan_total_recieved_amount_percentage
from bank_loan_analysis;
-- output returned '92.12'


-- Bad loan application percentage
select 
(count(case when loan_status='Charged Off' then id END))*100/count(id)
as bad_loan_application_percentage
from bank_loan_analysis;
-- output returned '13.8247'


-- Bad loan total funded amount
select 
(sum(case when loan_status='Charged Off' then loan_amount END))
as bad_loan_total_funded_amount
from bank_loan_analysis;
-- output returned '65532225.00'


-- Bad loan total funded amount percentage
select 
round((sum(case when loan_status='Charged Off' then loan_amount END))*100/sum(loan_amount),2)
as bad_loan_total_funded_amount_percentage
from bank_loan_analysis;
-- output returned '15.04'


--  Bad loan total RECIEVED amount
select 
(sum(case when loan_status='Charged Off' then  total_payment END))
as bad_loan_total_recieved_amount
from bank_loan_analysis;
-- output returned '37284763.00'


-- Bad loan total recieved amount percentage
select 
round((sum(case when loan_status='Charged Off' then total_payment END))*100/sum(total_payment),2)
as bad_loan_total_recieved_amount_percentage
from bank_loan_analysis;
-- output returned '7.88'



-- Loan Status Grid view:For overview of our lending operations and to monitor performance of loans,we need to create grid view report categorized by loan status

select loan_status,
		count(id) as total_applications,
        sum(total_payment) as total_amount_recieved,
        sum(loan_amount) as total_funded_amount, 
        avg(int_rate*100) as interest_rate,
        avg(dti*100) as dti
	from bank_loan_analysis
    group by loan_status;

-- Output:
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+
-- | loan_status | total_applications| total_amount_recieved| total_funded_amount| interest_rate | dti   |
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+
-- | Fully Paid  | 32145             | 411586256           | 351358350          | 11.641071     | 13.167|
-- | Charged Off | 5333              | 37284763            | 65532225           | 13.878575     | 14.005|
-- | Current     | 1098              | 24199914            | 18866500           | 15.099326     | 14.724|
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+


-- Loan status grid view for mtd
select loan_status,
		count(id) as total_applications,
        sum(total_payment) as total_amount_recieved,
        sum(loan_amount) as total_funded_amount, 
        avg(int_rate*100) as interest_rate,
        avg(dti*100) as dti
	from bank_loan_analysis
    where month(issue_date)=12
    group by loan_status;

-- Output:
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+
-- | loan_status | total_applications| total_amount_recieved| total_funded_amount| interest_rate | dti   |
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+
-- | Fully Paid  | 3452              | 47815851            | 41302025           | 11.770333     | 13.375|
-- | Charged Off | 649               | 5324211             | 8732775            | 14.253559     | 14.736|
-- | Current     | 213               | 4934318             | 3946625            | 16.066714     | 15.121|
-- +-------------+-------------------+---------------------+--------------------+---------------+-------+


--                              Dashboard 2 overview 


-- 1.monthly trends by issue date

Select 
	MONTH(issue_date) as month_num,
	MONTHNAME(issue_date) as name_of_month,
    count(id) as total_loan_applications,
    sum(loan_amount) as total_funded_amount,
    sum(total_payment) as total_recieved_amount
from bank_loan_analysis
group by month_num,name_of_month
order by month_num;

-- month_num | name_of_month | total_loan_applications | total_funded_amount | total_recieved_amount
-- 1 | January | 2332 | 25031650 | 27578836
-- 2 | February | 2279 | 24647825 | 27717745
-- 3 | March | 2627 | 28875700 | 32264400
-- 4 | April | 2755 | 29800800 | 32495533
-- 5 | May | 2911 | 31738350 | 33750523
-- 6 | June | 3184 | 34161475 | 36164533
-- 7 | July | 3366 | 35813900 | 38827220
-- 8 | August | 3441 | 38149600 | 42682218
-- 9 | September | 3536 | 40907725 | 43983948
-- 10 | October | 3796 | 44893800 | 49399567
-- 11 | November | 4035 | 47754825 | 50132030
-- 12 | December | 4314 | 53981425 | 58074380


-- 2.Regional Analysis by state 

select address_state as state,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_recieved_amount,
avg(int_rate) as average_interest_rate,
avg(dti) as average_debt_to_income_ratio
from bank_loan_analysis
group by state
order by state;

-- state | total_loan_applications | total_funded_amount | total_recieved_amount | average_interest_rate | average_debt_to_income_ratio
-- AK | 78 | 1031800 | 1108570 | 0.127915 | 0.150435
-- AL | 432 | 4949225 | 5492272 | 0.118594 | 0.141753
-- AR | 236 | 2529700 | 2777875 | 0.117557 | 0.152133
-- AZ | 833 | 9206000 | 10041986 | 0.122431 | 0.131855
-- CA | 6894 | 78484125 | 83901234 | 0.121482 | 0.128443
-- CO | 770 | 8976000 | 9845810 | 0.118150 | 0.136090
-- CT | 730 | 8435575 | 9357612 | 0.119101 | 0.128976
-- DC | 214 | 2652350 | 2921854 | 0.120467 | 0.125146
-- DE | 110 | 1138100 | 1269136 | 0.119956 | 0.141715
-- FL | 2773 | 30046125 | 31601905 | 0.119781 | 0.135271
-- GA | 1355 | 15480325 | 16728040 | 0.119620 | 0.139886
-- HI | 170 | 1850525 | 2080184 | 0.125938 | 0.140616
-- IA | 5 | 56450 | 64482 | 0.089740 | 0.129100
-- ID | 6 | 59750 | 65329 | 0.115117 | 0.145367
-- IL | 1486 | 17124225 | 18875941 | 0.120541 | 0.133111
-- IN | 9 | 86225 | 85521 | 0.108011 | 0.159711
-- KS | 260 | 2872325 | 3247394 | 0.118186 | 0.141783
-- KY | 320 | 3504100 | 3792530 | 0.118976 | 0.140750
-- LA | 426 | 4498900 | 5001160 | 0.117323 | 0.142009
-- MA | 1310 | 15051000 | 16676279 | 0.118715 | 0.126445
-- MD | 1027 | 11911400 | 12985170 | 0.124916 | 0.129233
-- ME | 3 | 9200 | 10808 | 0.104867 | 0.097100
-- MI | 685 | 7829900 | 8543660 | 0.120066 | 0.134616
-- MN | 592 | 6302600 | 6750746 | 0.116876 | 0.135916
-- MO | 660 | 7151175 | 7692732 | 0.117236 | 0.144717
-- MS | 19 | 139125 | 149342 | 0.117900 | 0.149953
-- MT | 79 | 829525 | 892047 | 0.120765 | 0.135662
-- NC | 759 | 8787575 | 9534813 | 0.121221 | 0.137806
-- NE | 5 | 31700 | 24542 | 0.118140 | 0.162820
-- NH | 161 | 1917900 | 2101386 | 0.117891 | 0.141463
-- NJ | 1822 | 21657475 | 23425159 | 0.122351 | 0.128259
-- NM | 183 | 1916775 | 2084485 | 0.116613 | 0.138801
-- NV | 482 | 5307375 | 5451443 | 0.125404 | 0.135447
-- NY | 3701 | 42077050 | 46108181 | 0.121143 | 0.122125
-- OH | 1188 | 12991375 | 14330148 | 0.120245 | 0.145976
-- OK | 293 | 3365725 | 3712649 | 0.118953 | 0.141418
-- OR | 436 | 4720150 | 4966903 | 0.119970 | 0.137516
-- PA | 1482 | 15826525 | 17462908 | 0.116906 | 0.138422
-- RI | 196 | 1883025 | 2001774 | 0.118652 | 0.127242
-- SC | 464 | 5080475 | 5462458 | 0.118348 | 0.137935
-- SD | 63 | 606150 | 656514 | 0.114314 | 0.148140
-- TN | 17 | 162175 | 141522 | 0.105612 | 0.115918
-- TX | 2664 | 31236650 | 34392715 | 0.120470 | 0.139467
-- UT | 252 | 2849225 | 2952412 | 0.119757 | 0.132625
-- VA | 1375 | 15982650 | 17711443 | 0.122175 | 0.134691
-- VT | 54 | 504100 | 534973 | 0.112231 | 0.135194
-- WA | 805 | 8855525 | 9531739 | 0.122631 | 0.130510
-- WI | 446 | 5070450 | 5485161 | 0.120678 | 0.134770
-- WV | 167 | 1830525 | 1991936 | 0.117253 | 0.148839
-- WY | 79 | 890750 | 1046050 | 0.125241 | 0.143459


-- 3.Distribution of loans across various term lengths

select term as Term_length,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_recieved_amount,
avg(int_rate) as average_interest_rate
from bank_loan_analysis
group by term_length
order by term_length;

-- Term_length | total_loan_applications | total_funded_amount | total_recieved_amount | average_interest_rate
-- 36 months | 28237 | 273041225 | 294709458 | 0.110309
-- 60 months | 10339 | 162715850 | 178361475 | 0.148289


-- 4.Employee length analysis of borrowers
select emp_length as employee_length,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_recieved_amount,
round(avg(int_rate)*100,2) as average_interest_rate
from bank_loan_analysis
group by employee_length
order by employee_length;


-- employee_length | total_loan_applications | total_funded_amount | total_recieved_amount | average_interest_rate
-- < 1 year | 4575 | 44210625 | 47545011 | 11.92
-- 1 year | 3229 | 32883125 | 35498348 | 12.05
-- 10+ years | 8870 | 116115950 | 125871616 | 12.09
-- 2 years | 4382 | 44967975 | 49206961 | 12.07
-- 3 years | 4088 | 43937850 | 47551832 | 12.02
-- 4 years | 3428 | 37600375 | 40964850 | 12.17
-- 5 years | 3273 | 36973625 | 40397571 | 12.03
-- 6 years | 2228 | 25612650 | 27908658 | 12.07
-- 7 years | 1772 | 20811725 | 22584136 | 12.18
-- 8 years | 1476 | 17558950 | 19025777 | 11.91
-- 9 years | 1255 | 15084225 | 16516173 | 11.91


-- 5.Loan Purpose Breakdown

select purpose,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_recieved_amount,
round(avg(int_rate)*100,2) as average_interest_rate
from bank_loan_analysis
group by purpose
order by purpose;


-- purpose | total_loan_applications | total_funded_amount | total_recieved_amount | average_interest_rate
-- car | 1497 | 10223575 | 11324914 | 10.59
-- credit card | 4998 | 58885175 | 65214084 | 11.73
-- Debt consolidation | 18214 | 232459675 | 253801871 | 12.50
-- educational | 315 | 2161650 | 2248380 | 11.65
-- home improvement | 2876 | 33350775 | 36380930 | 11.40
-- house | 366 | 4824925 | 5185538 | 12.38
-- major purchase | 2110 | 17251600 | 18676927 | 10.87
-- medical | 667 | 5533225 | 5851372 | 11.57
-- moving | 559 | 3748125 | 3999899 | 11.59
-- other | 3824 | 31155750 | 33289676 | 11.86
-- renewable_energy | 94 | 845750 | 898931 | 11.50
-- small business | 1776 | 24123100 | 23814817 | 13.03
-- vacation | 352 | 1967950 | 2116738 | 10.88
-- wedding | 928 | 9225800 | 10266856 | 11.89


-- Home ownership analysis
select home_ownership,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_recieved_amount,
round(avg(int_rate)*100,2) as average_interest_rate
from bank_loan_analysis
group by home_ownership;

-- home_ownership | total_loan_applications | total_funded_amount | total_recieved_amount | average_interest_rate
-- RENT | 18439 | 185768475 | 201823056 | 12.30
-- OWN | 2838 | 29597675 | 31729129 | 11.89
-- MORTGAGE | 17198 | 219329150 | 238474438 | 11.80
-- NONE | 3 | 16800 | 19053 | 8.70
-- OTHER | 98 | 1044975 | 1025257 | 12.04


-- ## Analysis Results Summary (Explanatory)

-- A total of 38,576 loan applications were processed in the dataset. Looking at recent trends, 
-- December 2021 saw a 6.91% increase in applications compared to November, highlighting a 
-- month-on-month rise in borrower activity. 

-- The overall funded amount reached $435,757,075.00, with a similar growth rate of 6.91% 
-- in December compared to November. Repayments were even stronger, totaling $473,070,933.00, 
-- indicating that borrowers, on average, are keeping up with their obligations.  

-- On the cost side, the average interest rate across all loans was 12.05%, while the 
-- average Debt-to-Income (DTI) ratio stood at 13.33%. These figures suggest that lending 
-- rates are moderate and borrowers are not over-leveraged.  

-- Loan quality distribution shows that 86.18% of applications were good loans, 
-- while 13.82% fell into the bad loan category. In terms of value, good loans made 
-- up $370,224,850.00 (about 85%) of the total funded amount, whereas bad loans accounted 
-- for $65,532,225.00 (15%). On the repayment side, the difference is even more striking: 
-- good loans returned $435,786,170.00 (92.12%), while bad loans returned only $37,284,763.00 (7.88%).  

-- Breaking this down further by loan status: 
-- Fully Paid loans dominate, with 32,145 applications, $351,358,350 funded, and $411,586,256 repaid. 
-- Charged Off loans accounted for 5,333 applications, with $65,532,225 funded but only $37,284,763 received. 
-- Current loans (still in repayment) totaled 1,098, with $18,866,500 funded and $24,199,914 received so far.  

-- Looking at borrower employment length, long-tenured employees (10+ years) made up the largest group 
-- with 8,870 applications and over $116M funded, showing lenders’ preference for stable employment histories. 
-- Shorter tenures such as less than 1 year (4,575 applications, $44M funded) and 1–3 years 
-- (about 11,700 combined applications) also formed a sizable portion, though with slightly lower loan amounts. 
-- Average interest rates across employment categories remained consistent, ranging between 11.9% and 12.2%, 
-- indicating that tenure had limited effect on pricing, but did influence approval and funding volumes.  

-- By loan purpose, Debt Consolidation was the clear leader, with 18,214 applications and $232M funded, 
-- accounting for more than half of the total loan demand. Other common purposes included credit cards 
-- (4,998 applications, $58.9M funded) and home improvement (2,876 applications, $33.3M funded). 
-- Small business loans, while fewer in count (1,776), carried a relatively higher risk profile 
-- with the highest average interest rate of 13.03%. Categories such as education, renewable energy, 
-- vacation, and weddings were much smaller contributors, reflecting niche borrowing needs.  

-- Home ownership patterns further highlight borrower profiles: those with mortgages dominated the pool 
-- with 17,198 applications and $219M funded, showing strong representation of middle-class homeowners. 
-- Renters were also a large group with 18,439 applications and $185M funded, while outright homeowners 
-- (OWN) were a smaller but financially stable segment at $29.6M funded. A negligible share came from 
-- borrowers with no or other ownership categories. Average interest rates were similar across groups, 
-- ranging from 11.8% to 12.3%, with renters facing slightly higher costs.  

-- Finally, loan term distribution shows a strong preference for shorter-term loans. 
-- Out of the total, 28,237 applications were for 36 months, while 10,339 were for 60 months, 
-- showing a borrower inclination toward faster repayment horizons.  



--  This is the end of exploratory data analysis using sql,the data cleaning and visualisation parts for similar ones are done in power bi.
   

