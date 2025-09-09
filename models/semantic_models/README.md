# Semantic Models Documentation

## Overview
This directory contains the semantic model definitions for the Brazilian E-commerce Analytics Platform. The semantic layer provides a business-friendly interface to our data, ensuring consistent metric definitions across all teams and tools.

## File Structure

```
semantic_models/
├── README.md                           # This documentation
├── base_semantic_model.yml             # Core semantic model definition
├── metric_groups.yml                   # Metric organization and governance
└── metrics/
    ├── user_activity_metrics.yml       # User engagement metrics
    ├── financial_metrics.yml           # Revenue and financial metrics
    └── operational_metrics.yml         # Operations and efficiency metrics
```

## RACI Matrix Implementation

Each metric includes comprehensive RACI (Responsible, Accountable, Consulted, Informed) information to ensure clear ownership and governance:

### **Responsible**: Who does the work
- Data teams who calculate and maintain the metric
- Analytics teams who ensure data quality

### **Accountable**: Who is ultimately answerable
- Business leaders who own the metric outcomes
- VPs and C-level executives for strategic metrics

### **Consulted**: Who provides input
- Cross-functional teams that contribute to metric definition
- Subject matter experts and stakeholders

### **Informed**: Who needs to know the results
- Teams and individuals who use the metrics for decision-making
- Reporting audiences and external stakeholders

## Metric Categories

### 1. User Activity Metrics
**File**: `metrics/user_activity_metrics.yml`
- **Purpose**: Track user engagement and platform adoption
- **Key Metrics**: Daily/Weekly/Monthly Active Users, Retention Rate
- **Primary Owner**: Product Analytics Team
- **Business Impact**: Customer Experience & Growth

### 2. Financial Metrics  
**File**: `metrics/financial_metrics.yml`
- **Purpose**: Revenue tracking and financial performance
- **Key Metrics**: Total Payments, Net Revenue, AOV, Voucher Usage
- **Primary Owner**: Finance Analytics Team
- **Business Impact**: Revenue & Profitability

### 3. Operational Metrics
**File**: `metrics/operational_metrics.yml`
- **Purpose**: Operational efficiency and system performance
- **Key Metrics**: Order Processing, Completion Rates, Payment Success
- **Primary Owner**: Operations Analytics Team
- **Business Impact**: Customer Satisfaction & Efficiency

## Business Attributes

Each metric includes rich business context:

### Core Business Information
- **Business Purpose**: Why this metric exists
- **Business Impact**: Strategic importance level
- **Use Cases**: Specific business applications
- **Target Ranges**: Healthy performance thresholds

### Operational Context
- **Frequency**: How often it's calculated and reviewed
- **SLA Refresh**: When data must be available
- **Data Freshness**: How current the data is
- **Primary Consumers**: Who uses this metric

### Quality & Governance
- **Validation Rules**: Data quality checks
- **Data Quality Owner**: Who ensures accuracy
- **Escalation Procedures**: Issue resolution process
- **Compliance Requirements**: Regulatory considerations

## Metric Groups

Metrics are organized into logical groups for different business functions:

1. **Executive Dashboard**: C-level strategic metrics
2. **User Engagement**: Product and marketing metrics
3. **Financial Performance**: Revenue and financial health
4. **Operational Efficiency**: Process and system performance
5. **Marketing Effectiveness**: Campaign and acquisition metrics
6. **Regional Performance**: Geographic business analysis
7. **Customer Experience**: Satisfaction and quality metrics
8. **Board Reporting**: Governance and oversight metrics

## Data Governance Standards

### Data Quality Requirements
- **Accuracy**: > 99.5%
- **Completeness**: > 99%
- **Timeliness**: Per metric SLA
- **Consistency**: Cross-system reconciliation

### Access Control
- **Authentication**: SSO required
- **Authorization**: Role-based access
- **Audit Logging**: All access tracked
- **Data Classification**: Confidential/Internal/Public

### Change Management
- **Approval Process**: Business + Data team sign-off
- **Impact Assessment**: Required for all changes
- **Communication**: 30-day notice for breaking changes
- **Rollback Plan**: Required for deployments

## Usage Guidelines

### For Business Users
1. **Finding Metrics**: Check metric groups for your functional area
2. **Understanding Context**: Review business purpose and use cases
3. **Interpreting Results**: Use target ranges and validation rules
4. **Requesting Changes**: Follow change management process

### For Data Teams
1. **Adding New Metrics**: Include full RACI and business context
2. **Modifying Existing**: Follow change approval process
3. **Quality Assurance**: Implement validation rules and monitoring
4. **Documentation**: Keep business attributes current

### For Analysts
1. **Metric Selection**: Choose appropriate granularity (daily/weekly/monthly)
2. **Dimensional Analysis**: Use geographic and time dimensions
3. **Cross-Metric Analysis**: Leverage related metrics for insights
4. **Performance Monitoring**: Monitor against target ranges

## Common Patterns

### Geographic Analysis
All metrics support state and city-level analysis:
```sql
-- State-level monthly active users
SELECT customer_state, active_users_monthly
FROM {{ metrics.calculate(metric('active_users_monthly')) }}
WHERE activity_month = '2025-08-01'

-- City-level daily revenue
SELECT customer_city, total_payments_daily  
FROM {{ metrics.calculate(metric('total_payments_daily')) }}
WHERE activity_date >= CURRENT_DATE - 7
```

### Time Series Analysis
Metrics support multiple time granularities:
```sql
-- Daily trend analysis
SELECT activity_date, active_users_daily
FROM {{ metrics.calculate(metric('active_users_daily')) }}
ORDER BY activity_date

-- Weekly aggregation
SELECT activity_week, active_users_weekly
FROM {{ metrics.calculate(metric('active_users_weekly')) }}
ORDER BY activity_week
```

### Performance Monitoring
Use target ranges for alerting:
```sql
-- Identify underperforming regions
SELECT customer_state, orders_completion_rate_daily
FROM {{ metrics.calculate(metric('orders_completion_rate_daily')) }}
WHERE orders_completion_rate_daily < 0.90  -- Below 90% threshold
```

## Support and Escalation

### Data Quality Issues
- **Level 1**: Data Engineering Team (< 2 hours)
- **Level 2**: Data Platform Lead (< 4 hours) 
- **Level 3**: VP of Data (< 8 hours)
- **Level 4**: CTO (< 24 hours)

### Business Questions
- **Metric Definitions**: Contact responsible team (per RACI)
- **Usage Questions**: Contact primary consumers
- **Strategic Context**: Contact accountable executive

### Technical Support
- **dbt Issues**: Data Engineering Team
- **Semantic Layer**: Data Platform Team
- **Dashboard Problems**: Analytics Engineering Team

## Best Practices

### For Metric Design
1. **Clear Business Purpose**: Every metric should solve a business problem
2. **RACI Completeness**: Full ownership and stakeholder mapping
3. **Quality Standards**: Comprehensive validation and monitoring
4. **Business Context**: Rich metadata for self-service analytics

### For Implementation
1. **Consistent Naming**: Follow established conventions
2. **Proper Granularity**: Choose appropriate time/geographic levels
3. **Performance Optimization**: Consider query patterns and volumes
4. **Documentation**: Keep business context current and accurate

### For Governance
1. **Regular Reviews**: Quarterly metric relevance assessment
2. **Stakeholder Engagement**: Monthly business user feedback
3. **Quality Monitoring**: Continuous data quality tracking
4. **Change Control**: Structured approval and communication process