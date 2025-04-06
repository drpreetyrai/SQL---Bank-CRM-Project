SELECT *  FROM ActiveCustomer; 


SELECT * FROM Bank_Churn; 

SELECT * FROM cccustomerinfo;

SELECT * FROM customerinfo9; 

SELECT * FROM `geography.xlsx - sheet1`; 

SELECT * FROM `gender.xlsx - sheet1`; 

SELECT * FROM `exitcustomer.xlsx - sheet1` ; 



-- 1.) What is the distribution of account balances across different regions?
SELECT c.GeographyID, 
        CASE 
           WHEN GeographyID = 1 THEN 'France'
           WHEN GeographyID = 2 THEN 'Spain' 
           WHEN GeographyID = 3 THEN 'Germany'
        END AS Region, 
        COUNT(a.CustomerId) AS TotalCustomers, 
        AVG(a.Balance) AS AvgBalance, 
       SUM(a.Balance) AS TotalBalance
FROM Bank_Churn a
JOIN cccustomerinfo c ON a.CustomerId = c.CustomerId
GROUP BY c.GeographyID
ORDER BY c.GeographyID;





-- 2.) Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT CustomerId, Surname, Age, GenderID, EstimatedSalary, `Bank DOJ`, GeographyID
FROM cccustomerinfo
WHERE MONTH(STR_TO_DATE(`Bank DOJ`, '%d/%m/%Y')) IN (10, 11, 12)
ORDER BY EstimatedSalary DESC
LIMIT 5;





-- 3.) Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT 
   AVG(NumOfProducts)
FROM 
Bank_Churn
WHERE HasCrCard=1
GROUP BY HasCrCard;



SELECT * FROM ccustomerinfo11; 


-- 4.) Determine the churn rate by gender for the most recent year in the dataset.
WITH BankChurn AS(
   SELECT 
     GenderID,
     COUNT(b.CustomerId) AS Total_Customer, 
     SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers, 
     YEAR(c.bank_year) AS year
     
   FROM cccustomerinfo c 
   JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
   GROUP BY GenderID, year 
   
)

SELECT 
    CASE 
      WHEN GenderID=1 THEN 'Male' 
      WHEN GenderID=2 THEN 'Female' 
	END AS gender, 
	GenderID, 
   (ChurnedCustomers * 100.0 / Total_Customer) AS ChurnRate, 
   year
FROM BankChurn 
GROUP BY GenderID, year
ORDER BY year DESC;







-- 5 Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT 
  AVG(CreditScore), 
  CASE 
   WHEN Exited=1 THEN 'Exited'
   WHEN Exited=0 THEN 'Stayed'
  END AS exited_or_stayed, 
  Exited
FROM Bank_Churn
GROUP BY Exited;






-- 6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
-- FOR active member 
SELECT 
   AVG(c.EstimatedSalary) AS avg_salary, 
   CASE 
      WHEN GenderID=1 THEN "Male_ACTIVE_CUSTM" 
      WHEN GenderID=2 THEN "Female_ACTIVE_CUSTM" 
   END as gender, 
   COUNT(IsActiveMember)
FROM Bank_Churn b 
JOIN cccustomerinfo c ON b.CustomerId = c.CustomerId
WHERE IsActiveMember=1
GROUP BY gender 
ORDER BY avg_salary DESC; 

-- for inactive customer 
SELECT 
   AVG(c.EstimatedSalary) AS avg_salary, 
   CASE 
      WHEN GenderID=1 THEN "Male_INACTIVE_CUSTM" 
      WHEN GenderID=2 THEN "Female_INACTIVE_CUSTM" 
   END as gender, 
   COUNT(IsActiveMember)
FROM Bank_Churn b
JOIN cccustomerinfo c ON b.CustomerId = c.CustomerId
WHERE IsActiveMember = 0
GROUP BY gender 
ORDER BY avg_salary DESC; 










-- 7 Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL) 
WITH CreditScoreSegment AS (
     SELECT 
       CustomerId, 
       CASE 
         WHEN CreditScore BETWEEN 300 AND 600 THEN 'Low'
         WHEN CreditScore BETWEEN 601 AND 750 THEN 'Medium'
		 WHEN CreditScore BETWEEN 751 AND 900 THEN 'High'
		 ELSE 'Unknown'
       END AS CreditCardSegment, 
       CreditScore, 
       Tenure, 
       Balance, 
       NumOfProducts, 
       HasCrCard, 
       IsActiveMember, 
       Exited
    FROM Bank_Churn 
)

SELECT
        CreditCardSegment,
        (SUM(Exited) * 1.0 / COUNT(CustomerId)) * 100 AS ExitRate
FROM 
	CreditScoreSegment
GROUP BY 
	CreditCardSegment
ORDER BY 
	ExitRate DESC
LIMIT 1;
   


















-- 8.) Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT 
   CASE 
      WHEN c.GeographyID=1 THEN 'France' 
      WHEN c.GeographyID=2 THEN 'Spain' 
      WHEN c.GeographyID=3 THEN 'Germany' 
   END AS Geographic_Region, 
   SUM(b.IsActiveMember) AS active_customer
   
FROM Bank_Churn b
JOIN cccustomerinfo c ON b.CustomerId=c.CustomerId
WHERE 
   b.IsActiveMember=1 AND b.Tenure > 5 
GROUP BY 
    Geographic_Region
ORDER BY active_customer DESC
LIMIT 1;

 














-- 9. What is the impact of having a credit card on customer churn, based on the available data?
SELECT 
    CASE 
       WHEN HasCrCard=0 THEN 'non_credit_card_holder'
       WHEN HasCrCard=1 THEN 'credit_card_holder'
    END DOES_USER_HAVE_CrCard, 
    HasCrCard,
    COUNT(CustomerId) AS TotalCustomers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND((SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(CustomerId)) * 100, 2) AS ChurnRate
FROM 
    Bank_Churn
GROUP BY 
    HasCrCard;








-- 6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
WITH GenderSalary AS (
    SELECT 
        GenderID, 
        AVG(EstimatedSalary) AS AvgEstimatedSalary, 
        COUNT(CASE WHEN IsActiveMember = 1 THEN 1 END) AS ActiveAccounts
    FROM 
        cccustomerinfo c
    JOIN 
        Bank_Churn a 
    ON 
        c.CustomerId = a.CustomerId
    GROUP BY 
        GenderID
)

SELECT 
    CASE  
       WHEN GenderID=1 THEN 'Male'
       WHEN GenderID=2 THEN 'Female'
	END AS gender_male_female,
    GenderID, 
    AvgEstimatedSalary, 
    ActiveAccounts
FROM 
    GenderSalary
ORDER BY 
AvgEstimatedSalary DESC;








-- 10. For customers who have exited, what is the most common number of products they have used?
SELECT 
   NumOfProducts, 
   COUNT(CustomerId) AS cust_count
FROM Bank_Churn b 
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY cust_count DESC
LIMIT 1; 




SELECT * FROM cccustomerinfo;

-- 11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.


-- Trend of customer joining yearly 
SELECT COUNT(CustomerId) AS cust_id, YEAR(bank_year) AS join_year
FROM cccustomerinfo
GROUP BY join_year 
ORDER BY cust_id DESC; 



-- Trend of customers joining monthly over the years 
SELECT COUNT(CustomerId) AS cust_id, 
       YEAR(bank_year) AS join_year, 
	   MONTH(bank_year) AS join_month 
FROM cccustomerinfo
GROUP BY join_year, join_month  
ORDER BY cust_id DESC; 






-- 13 Identify any potential outliers in terms of balance among customers who have remained with the bank.
SELECT 
    CustomerId, 
    Balance
FROM  Bank_Churn 
WHERE Exited=0 
ORDER BY Balance DESC
LIMIT 10; 






















-- 15 Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)

SELECT 
    CASE
      WHEN GenderID=1 THEN 'Male' 
      WHEN GenderID=2 THEN 'Female' 
    END AS gender,
    GenderID,
    AVG(EstimatedSalary) AS avg_income
FROM cccustomerinfo
GROUP BY GenderID
ORDER BY avg_income DESC; 





















-- 12. Analyze the relationship between the number of products and the account balance for customers who have exited.

-- Calculate aggregate statistics 
SELECT 
       NumOfProducts,
       AVG(Balance) AS avg_balance,
       MIN(Balance) AS min_balance,
       MAX(Balance) AS max_balance,
       COUNT(CustomerId) AS count
FROM Bank_Churn 
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY NumOfProducts;
   



















-- 16 Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT 
   CASE 
     WHEN c.Age BETWEEN 18 AND 30 THEN '18-30' 
     WHEN c.Age BETWEEN 30 AND 50 THEN '30-50' 
     ELSE '50+' 
   END AS Age_Range, 
   AVG(b.Tenure) 
FROM Bank_Churn b 
JOIN cccustomerinfo c ON b.CustomerId = c.CustomerId
WHERE b.Exited=1 
GROUP BY Age_Range;  







-- 17 Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?
-- For customers who have exited 
SELECT c.CustomerId, 
       c.Balance, 
       s.EstimatedSalary, 
       c.Exited

FROM Bank_Churn c
JOIN cccustomerinfo s 
    ON c.CustomerId = s.CustomerId
WHERE c.Exited=1;

-- For customers who have stayed
SELECT c.CustomerId, 
       c.Balance, 
       s.EstimatedSalary, 
       c.Exited

FROM Bank_Churn c
JOIN cccustomerinfo s 
    ON c.CustomerId = s.CustomerId
WHERE c.Exited=0;





-- 18 Is there any correlation between the salary and the Credit score of customers?

SELECT 
   AVG(b.CreditScore), 
   AVG(c.EstimatedSalary), 
   YEAR(bank_year) year
FROM Bank_Churn b
JOIN cccustomerinfo c 
    ON b.CustomerId = c.CustomerId
GROUP BY year
ORDER BY year DESC; 





-- 19 Rank each bucket of credit score as per the number of customers who have churned the bank.
WITH CreditScoreBuckets AS (
    SELECT 
        CASE 
            WHEN CreditScore BETWEEN 300 AND 499 THEN '300-499'
            WHEN CreditScore BETWEEN 500 AND 699 THEN '500-699'
            WHEN CreditScore BETWEEN 700 AND 850 THEN '700-850'
            ELSE 'Other' 
        END AS CreditScoreBucket,
        COUNT(*) AS ChurnedCustomers
    FROM Bank_Churn
    WHERE Exited = 1
    GROUP BY CreditScoreBucket
)
SELECT 
    CreditScoreBucket,
    ChurnedCustomers,
    RANK() OVER (ORDER BY ChurnedCustomers DESC) AS BucketRank
FROM CreditScoreBuckets;






-- 20 According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.
WITH AgeBuckets AS (
    SELECT 
        CASE 
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+' 
        END AS AgeBucket,
        COUNT(CASE WHEN b.HasCrCard = 1 THEN 1 END) AS NumWithCreditCard
    FROM cccustomerinfo AS c
    JOIN Bank_Churn AS b ON c.CustomerId = b.CustomerId
    GROUP BY AgeBucket
)

SELECT 
   AgeBucket, NumWithCreditCard
FROM AgeBuckets 
WHERE NumWithCreditCard < (SELECT AVG(NumWithCreditCard) AS AvgNumWithCreditCard FROM AgeBuckets);







-- 21  Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
SELECT 
    c.GeographyID, 
    COUNT(CASE WHEN b.Exited = 1 THEN 1 END) AS ChurnedCustomers,
    AVG(b.Balance) AS AvgBalance
FROM 
    cccustomerinfo AS c
JOIN 
    Bank_Churn AS b ON c.CustomerId = b.CustomerId
GROUP BY 
    c.GeographyID
ORDER BY 
    ChurnedCustomers DESC, 
    AvgBalance DESC;
 
 
 
 
 
 


-- 22 As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- now if we have to join it with a table where the primary key is also a combination 
-- of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
SELECT 
    C.CustomerID, 
    C.Surname, 
    CONCAT(C.CustomerID, '_', C.Surname) AS CustomerID_Surname
FROM cccustomerinfo C; 

 
 
 
 






-- 23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? 
-- If yes do this using SQL.
SELECT 
    CustomerId,
    CreditScore,
    Tenure,
    Balance,
    NumOfProducts,
    HasCrCard,
    IsActiveMember,
    Exited,
    (SELECT ExitCategory 
     FROM `exitcustomer.xlsx - sheet1` AS e  
     WHERE e.ExitID = Bank_Churn.Exited) AS ExitCategory
FROM 
    Bank_Churn;









-- 24 Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them? 






-- 25 Write the query to get the customer IDs, their last name, and whether 
-- they are active or not for the customers whose surname ends with “on”.
SELECT c.CustomerId, c.Surname, b.IsActiveMember
FROM cccustomerinfo c
JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
WHERE c.Surname LIKE '%on';






-- 26 Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember 
-- and Exited columns. One more point to consider is that the data in the Exited Column is absolutely correct and accurate.
SELECT CustomerId, IsActiveMember, Exited
FROM Bank_Churn 
WHERE (Exited = 1 AND IsActiveMember = 1) OR (Exited = 0 AND IsActiveMember = 0);








-- Subject 1:- Customer Behavior Analysis: What patterns can be observed in the spending habits of long-term customers compared to new customers, and what might these patterns suggest about customer loyalty?

SELECT 
   CASE 
      WHEN Tenure >= 4 THEN 'Long Term Customer' 
      WHEN Tenure <= 4 THEN 'Short Term Customer'
   END AS Tenure_customers,
   c.EstimatedSalary AS salary, 
   Balance 
FROM 
Bank_Churn b JOIN cccustomerinfo c ON c.CustomerId = b.CustomerId
ORDER BY Balance DESC; 







-- Subject 2:- Product Affinity Study: Which bank products or services are most commonly used together, and how might this influence cross-selling strategies?
-- total customers 
SELECT COUNT(CustomerId) FROM Bank_Churn ;

SELECT 
  COUNT(CustomerId) 
  
FROM Bank_Churn 
WHERE HasCrCard=1;  







-- SUBJECTIVE 3 : Geographic Market Trends: How do economic indicators in different geographic regions correlate with 
-- the number of active accounts and customer churn rates?

-- for customers who have exited
SELECT 
    COUNT(b.CustomerId) AS customer, 
    AVG(c.EstimatedSalary) AS e_sal, 
    c.GeographyID AS g_id, 
    CASE 
     WHEN c.GeographyID=1 THEN 'France'
     WHEN c.GeographyID=2 THEN 'Spain'
     WHEN c.GeographyID=3 THEN 'Germany'
   END AS geography_area, 
   COUNT(b.IsActiveMember) AS active_member, 
   COUNT(b.Exited) AS churned_members
FROM Bank_Churn b JOIN cccustomerinfo c 
WHERE b.Exited=1 AND b.IsActiveMember=1
GROUP BY g_id;

-- for customers what stays with the bank
SELECT 
    COUNT(b.CustomerId) AS customer, 
    AVG(c.EstimatedSalary) AS e_sal, 
    c.GeographyID AS g_id, 
    CASE 
     WHEN c.GeographyID=1 THEN 'France'
     WHEN c.GeographyID=2 THEN 'Spain'
     WHEN c.GeographyID=3 THEN 'Germany'
   END AS geography_area, 
   COUNT(b.IsActiveMember) AS active_member, 
   COUNT(b.Exited) AS churned_members
FROM Bank_Churn b JOIN cccustomerinfo c 
WHERE b.Exited=0 AND b.IsActiveMember=1
GROUP BY g_id;


--  SUBJECIVE 4 :- Risk Management Assessment: Based on customer profiles, which demographic segments 
-- appear to pose the highest financial risk to the bank, and why?
SELECT 
   COUNT(b.CustomerId) AS no_of_customers , 
   CASE 
     WHEN GeographyID=1 THEN 'France'
     WHEN GeographyID=2 THEN 'Spain'
     WHEN GeographyID=3 THEN 'Germany'
   END AS geography_area, 
   GeographyID 
FROM Bank_Churn b JOIN cccustomerinfo c on c.CustomerId=b.CustomerId
WHERE CreditScore <= 750 AND HasCrCard=1 
GROUP BY GeographyID, geography_area
ORDER BY no_of_customers DESC; 





-- Subjective 5: Customer Tenure Value Forecast: How would you use the available data to model and 
-- predict the lifetime (tenure) value in the bank of different customer segments?
SELECT 
   AVG(Tenure) AS Tenure, 
   CASE 
     WHEN GeographyID=1 THEN 'France'
     WHEN GeographyID=2 THEN 'Spain'
     WHEN GeographyID=3 THEN 'Germany'
   END AS geography_area, 
   GeographyID 
FROM Bank_Churn b JOIN cccustomerinfo c on c.CustomerId=b.CustomerId
GROUP BY geography_area, GeographyID 
ORDER BY Tenure DESC;













-- Subjective 6:- Marketing Campaign Effectiveness: How could you assess the impact of marketing campaigns on 
-- customer retention and acquisition within the dataset? What extra information would you need to solve this?









-- Subjective 7:- Customer Exit Reasons Exploration: Can you identify common characteristics or trends 
-- among customers who have exited that could explain their reasons for leaving?

SELECT 
  COUNT(CustomerId), 
  HasCrCard
  
FROM Bank_Churn 
WHERE Exited=1
GROUP BY HasCrCard;


SELECT 
  COUNT(CustomerId), 
  HasCrCard
  
FROM Bank_Churn 
WHERE Exited=0
GROUP BY HasCrCard;



SELECT 
  COUNT(IsActiveMember), 
  AVG(Balance), 
  MIN(Balance), 
  MAX(Balance), 
  Tenure
FROM Bank_Churn 
WHERE IsActiveMember=1 AND Exited=1 
GROUP BY Tenure; 


SELECT 
  COUNT(IsActiveMember), 
  AVG(Balance), 
  MIN(Balance), 
  MAX(Balance), 
  Tenure
FROM Bank_Churn 
WHERE IsActiveMember=1 AND Exited=0
GROUP BY Tenure; 










-- Subjective 8:- Are 'Tenure', 'NumOfProducts', 'IsActiveMember', and 'EstimatedSalary' important for 
-- predicting if a customer will leave the bank?

SELECT 
   b.Tenure, 
   COUNT(b.NumOfProducts), 
   COUNT(b.IsActiveMember), 
   AVG(c.EstimatedSalary)
FROM Bank_Churn b JOIN cccustomerinfo c on c.CustomerId=b.CustomerId 
WHERE b.Exited=1 AND b.IsActiveMember=1
GROUP BY b.Tenure;











-- Subjective 9:- Utilize SQL queries to segment customers based on demographics and account details.
SELECT 
  COUNT(b.CustomerId) AS no_of_customers, 
  CASE 
    WHEN c.GenderID=1 THEN 'Male' 
    WHEN c.GenderID=2 THEN 'Female' 
  END AS gender, 
  CASE 
    WHEN c.GeographyID=1 THEN 'France' 
    WHEN c.GeographyID=2 THEN 'Spain' 
    WHEN c.GeographyID=3 THEN 'Germany' 
  END AS region, 
  AVG(c.EstimatedSalary), 
  AVG(b.Balance)
FROM cccustomerinfo c JOIN Bank_Churn b on b.CustomerId = c.CustomerId
GROUP BY gender, region
ORDER BY no_of_customers DESC; 
  







-- Subjective 10:- How can we create a conditional formatting setup to visually highlight customers at risk 
-- of churn and to evaluate the impact of credit card rewards on customer retention?












-- Subjective 11:- What is the current churn rate per year and overall as well in the bank? 
-- Can you suggest some insights to the bank about which kind of customers are more likely to churn 
-- and what different strategies can be used to decrease the churn rate?

-- overall churn rate
SELECT 
    (SUM(Exited) / COUNT(CustomerId)) * 100 AS overall_churn_rate
FROM 
    Bank_Churn;



-- yearly churn rate 
SELECT 
    YEAR(c.bank_year) AS ChurnYear, 
    (SUM(b.Exited) / COUNT(c.CustomerId)) * 100 AS churn_rate_per_year
FROM 
    cccustomerinfo c JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
GROUP BY 
    ChurnYear
ORDER BY 
    ChurnYear;






-- Subjective 12:- Create a dashboard incorporating all the KPIs and visualization-related metrics.
-- Use a slicer in order to assist in selection in the dashboard.











-- Subjective 13:- How would you approach this problem, if the objective and subjective questions weren't given?








-- Subjective 14:- In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

ALTER TABLE Bank_Churn 
CHANGE COLUMN Has_creditcard HasCrCard TINYINT;








 
    