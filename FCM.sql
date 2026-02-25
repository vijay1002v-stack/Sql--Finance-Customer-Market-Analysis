/* 1) As a product owner want to generate a report of individual product sales(aggregated on a monthly basis at the product level) 
for Croma india customers for FY=2021 
so that I can track individual product sales.
 */

-- The report should have the following column.

-- 1.Month.
-- 2.product Name.
-- 3.Variant
-- 4.Sold Quantity.
-- 5.Gross Price per item.
-- 6.Gross price Total.

-- a)Finding out the customer code for Croma india 

Select*from dim_customer  -- 90002002
where customer like'%croma%' and market ='India';

Select*from fact_sales_monthly
where customer_code=90002002;

-- b)Get_Fiscal_year user defined function Created &  Retrieved sales data for Croma India for FY 2021

CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_year`(
         calendar_date date) 
         RETURNS int
DETERMINISTIC
     BEGIN
        Declare fiscal_year Int;
        Set fiscal_year=Year(date_add(calendar_date, Interval 4 month));
        Return fiscal_year;
        END

Select*from fact_sales_monthly
where customer_code=90002002 and 
get_fiscal_year(date)=2021;

-- c)  Retrieving Product Name, Variant, Gross_price and Gross_price_total

Select fs.date,fs.product_code,
       dp.product,dp.variant,fg.gross_price,
       fg.gross_price*fs.sold_quantity as gross_price_total,
       fs.sold_quantity
from fact_sales_monthly as fs
Join dim_product as dp
On fs.product_code=dp.product_code
Join fact_gross_price as fg
On fg.product_code=dp.product_code and 
   get_fiscal_year(fs.date)=fg.fiscal_year
where Customer_code=90002002 and 
   get_fiscal_year(date)=2021
order by date asc;



-- 2) Gross Monthly total sales report
/* As a product owner need an aggregate monthly gross sales report for individual customer
 To check how much sales this customer is generating */
  
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_sales_for_customer`(
in_customer_code Text)
BEGIN
Select 
    fs.date,
    sum(fg.gross_price*fs.sold_quantity) as total_gross_price
from fact_sales_monthly as fs
Join fact_gross_price as fg
    On fs.product_code=fg.product_code 
    and get_fiscal_year(fs.date)=fg.fiscal_year
where
    find_in_set(fs.customer_code,in_customer_code)>0
group by fs.date
Order by fs.date;
END



3) /*Create a Store Procedure that determine the market badge based on the following.
 If total sold quantity >5 million that market is considered gold else it is silver
Input = Market,Fiscal_year
Output =Market Badge*/

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
    In in_market varchar(25),
	In In_fiscal_year year,
    OUT out_badge varchar(10))
BEGIN
   Declare qty int default 0;

# Set default market as india 
    If in_market='' then
       set in_market='India';
    end if;

#retrieving total qty for given market+fyear.
    Select sum(fs.sold_quantity) into qty
	from fact_sales_monthly as fs
    Join dim_customer as dc
    on fs.customer_code=dc.customer_code
    where get_fiscal_year(date)=In_fiscal_year and 
          dc.market=in_market
    group by dc.market;

#determine the market the badge
    If qty>5000000 then 
       set out_badge='Gold';
	else
	   set out_badge='Silver';
     end if;
END

-- Report On Top Market  by Net Sales
-- Report for Top Products  by Net Sales
-- Report for Top Customers  by Net Sales

/* Developing  SQL queries to accurately calculate pre-invoice deductions,
 post-invoice deductions, and net sales, 
and generate reports identifying the top-performing markets, products, and customers 
based on net sales*/

-- Pre Invoice 

Select fs.date,fs.product_code,
       dp.product,dp.variant,
       Round(fs.sold_quantity*fg.gross_price) as gross_price_total,
	   pre.pre_invoice_discount_pct
from fact_sales_monthly as fs
Join dim_product as dp
ON fs.product_code=dp.product_code
Join fact_gross_price as fg
On fs.product_code=fg.product_code and 
      get_fiscal_year(fs.date)=fg.fiscal_year
Join fact_pre_invoice_deductions as pre
On fs.customer_code=pre.customer_code and 
      get_fiscal_year(fs.date)=pre.fiscal_year
where get_fiscal_year(fs.date)=2021;
  
-- Improving  performance by removing get_fiscal_year function and adding  fiscal_year column.
  
select fs.date,
       dp.product_code,
       dp.product,
       dp.variant,
       fg.gross_price,
	Round(sold_quantity*gross_price) as total_gross_price,
       pre.pre_invoice_discount_pct
from fact_sales_monthly as fs
Join dim_product as dp
On fs.product_code= dp.product_code
Join fact_gross_price as fg
On fg.product_code =dp.product_code and 
     fs.fiscal_year=fg.fiscal_year
Join fact_pre_invoice_deductions as pre
On pre.customer_code=fs.customer_code and 
     fs.fiscal_year and fg.fiscal_year;


-- Net Invoice Sales

with cte1 as (select fs.date,
       dp.product_code,
       dp.product,
       dp.variant,
       fg.gross_price,
	Round(sold_quantity*gross_price) as total_gross_price,
       pre.pre_invoice_discount_pct
from fact_sales_monthly as fs
Join dim_product as dp
On fs.product_code= dp.product_code
Join fact_gross_price as fg
On fg.product_code =dp.product_code and 
   fs.fiscal_year=fg.fiscal_year
Join fact_pre_invoice_deductions as pre
On pre.customer_code=fs.customer_code and 
   fs.fiscal_year and fg.fiscal_year)

Select (gross_price-gross_price*pre_invoice_discount_pct) as net_invoice_sales
from cte1;


/* Create a SQL view for pre-invoice deductions to simplify the calculation 
and further use it to compute post-invoice deductions and net sales efficiently*/

-- Designed a Sql view on Post_Invoice_deductions 

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `sales_postinv_discount` AS
    SELECT 
        `sp`.`date` AS `date`,
        `sp`.`fiscal_year` AS `fiscal_year`,
        `sp`.`product_code` AS `product_code`,
        `sp`.`customer_code` AS `customer_code`,
        `sp`.`product` AS `product`,
        `sp`.`variant` AS `variant`,
        `sp`.`gross_price` AS `gross_price`,
        `sp`.`market` AS `market`,
        `sp`.`total_gross_price` AS `total_gross_price`,
        `sp`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`,
        (`sp`.`total_gross_price` - (`sp`.`total_gross_price` * `sp`.`pre_invoice_discount_pct`)) AS `net_invoice_sales`,
        (`pd`.`discounts_pct` + `pd`.`other_deductions_pct`) AS `post_invoice_discounts`
    FROM
        (`sales_preinv_discount` `sp`
        JOIN `fact_post_invoice_deductions` `pd` ON (((`sp`.`customer_code` = `pd`.`customer_code`)
            AND (`sp`.`product_code` = `pd`.`product_code`)
            AND (`sp`.`date` = `pd`.`date`))));

-- Calculating Net_Sales 

Select *,
(1-post_invoice_discounts)*net_invoice_sales as net_sales
from sales_postinv_discount;

/* After calculating pre-invoice deductions, post-invoice deductions, and net sales, 
retrieve and analyze the top-performing markets, products, and customers based on net sales*/

-- Creating a Store Proc for Top Market,Customers.
 
     -- Top Market 
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_n_market`(
               fiscal_year year,
               top_n int)
BEGIN
	Select market,
	Round(sum(net_sales)/1000000,2) as net_Sales_mln
	from net_sales
	where fiscal_year=fiscal_year
	group by market
	Order by net_sales_mln desc
	Limit top_n;
       END
    
-- Top Customers by net_Sales percentage

with cte1 as (Select c.customer,
	Round(Sum(net_sales)/1000000,2) as net_sales_mln
from net_sales as ns 
Join dim_customer c 
on ns.customer_code=c.customer_code
where fiscal_year=2021
Group by c.customer)

select*,
     net_sales_mln*100/sum(net_Sales_mln) over() as pct 
from cte1
order by net_Sales_mln desc;

       
