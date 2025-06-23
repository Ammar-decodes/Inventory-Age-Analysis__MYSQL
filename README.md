### The Problem
We need to track how long items stay in a warehouse before being sold/shipped.

### Rules
First-In-First-Out (FIFO): Oldest inventory gets sold first.

Inventory changes over time:

Inbound: New stock arrives.

Outbound: Stock leaves (oldest goes first).

### Goal
Classify current inventory into 4 age groups:

0-90 days old         91-180 days old           181-270 days old               271-365 days old

#### Expected Output : - <a href="https://github.com/Ammar-decodes/Inventory-Age-Analysis__MYSQL/blob/main/Expected%20Output%20Screenshot.png">ClickHereforPicture</a>

#### Query Output : - <a href="https://github.com/Ammar-decodes/Inventory-Age-Analysis__MYSQL/blob/main/Sql%20Query%20Output.png">ClickHereforPicture</a>

## SQL Warehouse Inventory Age Analysis: Key Components

#### 1. CTEs (Common Table Expressions)
Purpose: Break down complex logic into manageable steps. 
Used for: Sorting warehouse events chronologically.
Defining time windows for age buckets (0-90 days, 91-180 days, etc.).
Calculating inbound stock quantities per age group.

#### 2. DATE_SUB()
Purpose: Calculate cutoff dates for aging buckets.
Used for: Setting boundaries like "90 days ago," "180 days ago," etc.

#### 3. SUM() with Filtering
Purpose: Aggregate inbound stock quantities.
Used for: Totaling stock received within each time window.

#### 4. CASE WHEN
Purpose: Apply conditional logic to prevent overcounting.
Used for: Capping inventory quantities when inbound stock exceeds current on-hand amounts.

#### 5. COALESCE()
Purpose: Replace NULL values with 0.
Used for: Ensuring empty age buckets return 0 instead of NULL.

#### 6. CROSS JOIN
Purpose: Combine CTEs for comparison.
Used for: Linking inventory layers with total stock quantities.

#### 7. ORDER BY event_datetime DESC
Purpose: Sort events from newest to oldest.
Used for: Enforcing FIFO (First-In-First-Out) inventory logic.
