# Data Analysis SQL Nanodegree Udacity Program - SQL Aggregations

Learn how to execute core SQL commands to define, select, manipulate, control access, aggregate, and join data and data tables. Understand when and how to use subqueries, several window functions, and partitions to complete complex tasks. Clean data, optimize SQL queries and write select advanced JOINs to enhance analysis performance.

This branch focuses on summarizing and grouping data using SQL aggregation functions. All practice queries and solutions for this section can be found in the `sql_aggregations_queries.sql` file.

## SQL Aggregations Recap

### Aggregate Functions
| Statement | How to Use It | Other Details |
| :--- | :--- | :--- |
| `SUM` | `SUM(column)` | Adds all values in a column. Commonly used for totals (quantity, revenue). |
| `COUNT` | `COUNT(*)` / `COUNT(column)` / `COUNT(DISTINCT column)` | `COUNT(*)` counts all rows; `COUNT(column)` counts non-NULL values; `COUNT(DISTINCT column)` counts unique non-NULL values. |
| `MIN` | `MIN(column)` | Returns the smallest value in a column. |
| `MAX` | `MAX(column)` | Returns the largest value in a column. |
| `AVG` | `AVG(column)` | Returns the mean of a column. Ignores NULLs. |
| `MEDIAN` | *(no built-in standard SQL)* | Not available as a standard aggregate. Approximate with `PERCENTILE_CONT(0.5)` in PostgreSQL/Oracle, or hard-code with `LIMIT`/`ORDER BY` in Parch & Posey. |

### Grouping and Filtering
| Statement | How to Use It | Other Details |
| :--- | :--- | :--- |
| `GROUP BY` | `GROUP BY column` | Groups rows that share a value so aggregates can be applied per group. |
| `HAVING` | `HAVING SUM(column) > value` | Filters **groups** after aggregation. Works like `WHERE` but for aggregated results. |
| `WHERE` | `WHERE column = value` | Filters **rows** before aggregation. Cannot contain aggregate functions. |
| `DISTINCT` | `SELECT DISTINCT column` | Returns unique values. Often used to verify one-to-one relationships. |

### Date Aggregations
| Statement | How to Use It | Other Details |
| :--- | :--- | :--- |
| `DATE_PART` | `DATE_PART('year', occurred_at)` | Extracts a date part (year, month, day, etc.) as a number. Useful for grouping by time period. |
| `DATE_TRUNC` | `DATE_TRUNC('month', occurred_at)` | Truncates a date to the specified precision. Useful for month/year buckets in `GROUP BY`. |

### Conditional Logic with Aggregations
| Statement | How to Use It | Other Details |
| :--- | :--- | :--- |
| `CASE` | `CASE WHEN condition THEN result ELSE result END` | Creates new categories/columns. Can be combined with aggregates for conditional metrics. |
| Conditional Aggregation | `SUM(CASE WHEN ... THEN value ELSE 0 END)` | Aggregates only rows matching a condition, producing multiple metrics in one query. |

*Note: NULL handling — most aggregates (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(column)`) ignore NULLs; `COUNT(*)` includes them. Use `COALESCE(column, 0)` to substitute NULLs before aggregating.*

### Query Structure Best Practices
When writing aggregation queries, include only non-aggregated columns in the `GROUP BY` clause, and use `WHERE` for row-level filtering and `HAVING` for group-level filtering. The standard structure is:

```sql
SELECT column, AGG(column)
FROM table
JOIN other_table ON table.id = other_table.id
WHERE row_condition
GROUP BY column
HAVING AGG(column) condition
ORDER BY AGG(column) DESC;