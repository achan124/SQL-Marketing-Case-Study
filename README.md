# SQL-Marketing-Case-Study

## Overview
### Context:
This project is an exploratory analysis on marketing and e-commerce data from a synthetic dataset. The data simulates an e-commerce company’s full analytics environment, including customers, products, marketing campaigns, user interaction events, and purchase transactions.
### Goal of the Analysis:
The objective of this project is to evaluate how different campaigns contribute to conversions and customer retention. Results will help the company optimize campaign budgets and improve ROI.

## Dataset
Full dataset can be found on [Kaggle] (https://www.kaggle.com/datasets/geethasagarbonthu/marketing-and-e-commerce-analytics-dataset?select=customers.csv).
### Data Cleaning
During the initial exploration of the transactions table, I identified rows with null values in the product_id and gross_revenue columns. After checking the count of null values in each, it appears that all null gross_revenue values occur when product_id is also null, confirming that missing revenue is tied to missing products.

**Possible Explanation**
1. **Deleted or missing product reference**
  - The product may not be sold anymore and has been deleted in the products table, but the transaction was not updated.
3. **Revenue is dependent on product_id**
  - Revenue can only be calculated if there is an associated product_id as the base_price is only included in the product table
**Conclusion**
I chose to include these rows to account for all transactions and ensure completeness of the dataset. I handled the missing data by filling them in with default values. Null values in product_id and gross_revenue are now shown as 0.

## Entity Relation Diagram
### Entities
- Campaigns
  - Contains information about each marketing campaign
  - Primary key campaign_id links to events and transactions
- Customers
  - Contains 1 row per customer with demographic and loyalty information
  - Primary key customer_id links to events and transactions
- Events
  - Contains information about user interactions (clicks, views, add-to-cart, purchases)
  - Primary key event_id, with foreign keys to customers, campaigns, and products
- Products
  - Contains information about each product in the catalog
  - Primary key product_id links to events and transactions
- Transactions
  - Contains information about purchase transactions
  - Primary key transaction_id, with foreign keys to customers, products, and campaigns

<img width="2100" height="1322" alt="ERD" src="https://github.com/user-attachments/assets/1437da6d-bc92-440d-b35e-44271d8091ca" />

## Exploratory Analysis
### Product Insights
1. Top selling products by revenue
2. Revenue by category or brand
3. Product performance trend (revenue per product over time)

### Marketing Insights
1. Total revenue generated per campaign
2. Average order value per campaign
3. Number of customers per aquisition channel
4. Revenue per accquition channel
5. Repeat purchases per aquisition channel
6. Count of users at each stage of funnel
7. Drop-off rate between user journey stages

