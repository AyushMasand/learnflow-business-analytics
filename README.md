# LearnFlow Business Analytics

An end-to-end business analytics project analyzing user acquisition, engagement, learning behavior, subscription conversion, retention, and marketing efficiency for a fictional online learning platform.

The project starts with raw operational data and progresses through data ingestion, data quality validation, transformation, SQL-based business analysis, and actionable recommendations.

---

## 📌 Business Problem

LearnFlow is an online learning platform that collects data across users, courses, lessons, learning sessions, product events, subscriptions, and marketing campaigns.

The business wants to understand:

- How effectively are new users being acquired?
- Which acquisition channels bring the most users?
- Which acquisition channels produce higher-converting users?
- Which user segments are most engaged?
- Which courses have unusually weak learner progress?
- Where do learners drop off in the learning journey?
- What percentage of users convert to subscribers?
- Is higher engagement associated with subscription conversion?
- How healthy is the current subscription base?
- Which marketing channels use advertising spend most efficiently?
- What actions should LearnFlow prioritize?

The objective of this project is to turn raw platform data into business insights that can support decisions around user growth, engagement, learning experience, subscriptions, retention, and marketing efficiency.

---

## 🎯 Business Objectives

1. Analyze user acquisition trends and channel contribution.
2. Evaluate acquisition quality using downstream subscription conversion.
3. Compare engagement across important user segments.
4. Identify courses with unusually low learner progress.
5. Compare learner performance across premium/free courses.
6. Evaluate the relationship between course difficulty and learner progress.
7. Analyze learning funnel drop-off.
8. Measure overall subscription conversion.
9. Examine the relationship between engagement and subscription status.
10. Evaluate active versus cancelled subscriptions.
11. Analyze subscription duration for ended subscriptions.
12. Measure marketing channel efficiency.
13. Evaluate marketing performance over time.
14. Translate analytical findings into business recommendations.

---

# 🗂️ Dataset

The project uses seven related datasets representing different parts of the LearnFlow business.

| Dataset | Description |
|---|---|
| `users` | User demographics, acquisition source, device, learning goal and skill level |
| `courses` | Course category, difficulty, estimated hours and premium/free status |
| `lessons` | Course lesson structure and lesson duration |
| `sessions` | User learning sessions and session duration |
| `events` | User interactions and learning activities |
| `subscriptions` | Subscription records, plans, pricing and status |
| `marketing` | Marketing campaign spend, impressions and clicks |

### Dataset Scale

| Dataset | Approx. Records |
|---|---:|
| Users | 50,000 |
| Events | 1.6M |
| Sessions | 309K |
| Courses | 80 |
| Lessons | 1,523 |
| Subscriptions | 3,752 |
| Marketing | 1,696 |

---

# 🔄 End-to-End Workflow

```text
Raw CSV Data
     ↓
Python Data Ingestion
     ↓
SQL Server
     ↓
Data Profiling & Quality Validation
     ↓
dbt Transformations & Testing
     ↓
Analysis-Ready Data
```

---

# 🛠️ Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| Python | Data ingestion, chunked loading and data preparation |
| SQL Server | Data storage, data profiling, validation and business analysis |
| SQL | Business analysis, KPI calculation, segmentation, funnel analysis and aggregation |
| dbt | Data transformation, reusable analytical models and data quality testing |
| Git & GitHub | Version control and project documentation |


# 🧹 Data Quality & Preparation

Before conducting business analysis, the raw datasets were profiled to identify data quality issues and establish the appropriate analytical grain.

### Key Data Quality Checks

- Identified and handled duplicate user records.
- Identified and handled duplicate session records.
- Identified and handled duplicate event records.
- Excluded events with missing timestamps from temporal analysis.
- Removed invalid session records where the session end preceded the session start.
- Validated marketing data using business rules such as `clicks <= impressions`.
- Validated relationships between users, courses, lessons, events and subscriptions.

### Analytical Grain

Each dataset and analytical model was designed around its intended grain to prevent duplicate counting and incorrect aggregation.

| Data | Analytical Grain |
|---|---|
| Users | 1 row per user |
| Courses | 1 row per course |
| Lessons | 1 row per lesson |
| Events | 1 row per event |
| Sessions | 1 row per user/session |
| Subscriptions | 1 row per subscription |
| Marketing | 1 row per campaign/channel/date |
| User Engagement | 1 row per user/active month |
| User-Course Performance | 1 row per user/course |


# 📊 Business Analysis

The analysis was structured around the LearnFlow business lifecycle:

```text
Acquire
   ↓
Engage
   ↓
Learn
   ↓
Convert
   ↓
Retain
   ↓
Optimize Marketing
```

## Business Questions

The analysis focuses on high-value questions across the LearnFlow customer and learning journey.

### 👥 User Acquisition

1. How effectively is LearnFlow acquiring new users?
2. Which acquisition channels contribute the most users?
3. Which acquisition channels produce higher subscription conversion?

### 📈 User Engagement

4. Which user segments are most engaged?
5. Does engagement differ by age group and skill level?

### 📚 Learning Performance

6. Which courses have unusually low learner progress?
7. Do premium courses perform differently from free courses?
8. Does course difficulty relate to learner progress?
9. Where do users drop off in the learning funnel?
10. Does funnel drop-off differ across skill levels?

### 💳 Subscription & Retention

11. What percentage of users convert to subscribers?
12. Is higher user engagement associated with subscription conversion?
13. What proportion of subscriptions are active versus cancelled?
14. How long do ended subscriptions remain active?

### 📣 Marketing Performance

15. Which marketing channels generate clicks most efficiently?
16. How does marketing efficiency change over time?

### 🔎 Cross-Business Analysis

17. Which user characteristics are associated with higher subscription conversion?


# 🔍 Analytical Approach

The analysis combines user, learning, subscription and marketing data to evaluate LearnFlow across the full business lifecycle.

### Key Analytical Areas

| Area | Focus |
|---|---|
| User Acquisition | New user growth and acquisition channel contribution |
| Acquisition Quality | Subscription conversion by acquisition channel |
| User Engagement | Sessions, learning activity and engagement by user segment |
| Learning Performance | Course participation and learner progress |
| Learning Funnel | Sequential drop-off from learning path to lesson completion |
| Subscription Conversion | Overall conversion and engagement differences between subscribers and non-subscribers |
| Subscription Health | Active vs cancelled subscriptions and subscription duration |
| Marketing Efficiency | Spend, impressions, clicks, CTR and CPC by channel and over time |
| Cross-Business Analysis | Relationship between engagement and subscription conversion |

### Analytical Principles

- Metrics were calculated at the appropriate business grain to avoid duplicate counting.
- `COUNT(DISTINCT ...)` was used where repeated user or event records could otherwise inflate metrics.
- User-level metrics were aggregated to one row per user before comparing subscription status.
- Funnel stages were evaluated sequentially using event timestamps.
- Conversion analysis used distinct users rather than subscription rows.
- Marketing performance was evaluated using aggregated spend, impressions and clicks.
- Findings are interpreted as associations, not causal relationships, where the data does not support causal inference.


# 📈 Key Findings

The analysis produced several important findings across LearnFlow's acquisition, engagement, learning, subscription and marketing activities.

### 👥 User Acquisition

- Monthly user acquisition remained relatively stable from January through July 2026, averaging approximately 7,143 new users per month.
- Organic Search was the largest acquisition channel, contributing 25.27% of new users.
- Paid Search contributed 15.93%, making search-based acquisition a major source of LearnFlow's user growth.
- Organic Search generated the highest acquisition volume, but it did not have the highest subscription conversion rate.

### 💳 Acquisition Quality

- Instagram had the highest subscription conversion rate at 7.90%.
- Paid Search followed at 7.73%.
- Referral had the lowest conversion rate at 6.89%.
- Conversion differences across acquisition channels were relatively modest.

### 📈 User Engagement

- Engagement levels were remarkably consistent across skill levels.
- Advanced users averaged approximately 11 sessions and 184 minutes of learning activity per user.
- Users aged 35–44 showed the highest engagement among the defined age groups, with approximately 11.1 sessions and 187 minutes per user.
- Engagement differences by skill level were small, suggesting skill level is not a strong engagement differentiator in this dataset.

### 📚 Learning Performance

- Course learner progress varied substantially across the catalog.
- Several courses showed substantial learner participation but comparatively low progress, making them candidates for further investigation.
- Premium courses had slightly higher average progress than free courses (4.95% vs. 4.78%), but lesson starts and completions were virtually identical.
- Course difficulty showed little meaningful relationship with learner progress. Advanced and beginner courses both averaged 4.89%, compared with 4.56% for intermediate courses.

### 🔄 Learning Funnel

The sequential learning funnel was:


```text
Learning Path Viewed
        ↓
Lesson Started
        ↓
Lesson Completed
```

- 38,067 users viewed a learning path.
- 35,123 users subsequently started a lesson.
- 32,198 users subsequently completed a lesson.
- The largest sequential drop-off occurred between lesson start and lesson completion, at 8.33%.
- Overall, 84.58% of learning-path viewers reached a subsequent lesson completion.

### 💳 Subscription Conversion

- LearnFlow converted 7.50% of users into subscribers.
- Subscriber engagement was substantially higher than non-subscriber engagement.
- Subscribers averaged approximately:
  - 93 events vs. 27 events for non-subscribers
  - 24 sessions vs. 10 sessions
  - 401 minutes vs. 166 minutes
  - 12 completed lessons vs. 4 completed lessons
- These results show a strong association between engagement and subscription status, but do not establish causation.

### 📊 Subscription Health

- 75.75% of subscription records were active.
- 24.25% of subscription records were cancelled.
- Among subscriptions with known end dates, the average subscription duration was approximately 60 days.
- The cancellation share should not be interpreted as a conventional churn rate because the analysis does not use a time-based cohort denominator.

### 📣 Marketing Performance

- Referral had the lowest cost per click at approximately $0.58.
- Organic Search combined the highest CTR (2.68%) with a low CPC of approximately $0.59.
- Paid Search had the highest CPC at approximately $0.68.
- Marketing efficiency remained relatively stable from January through July 2026.
- March had the strongest overall efficiency, with the highest CTR (2.71%) and lowest CPC ($0.59).
- June was the weakest month, with the lowest CTR (2.52%) and highest CPC ($0.67).

### 🔎 Cross-Business Finding

Engagement showed the strongest relationship with subscription conversion.

| Engagement Segment | Users | Subscribers | Conversion Rate |
|---|---:|---:|---:|
| High | 10,528 | 2,781 | 26.42% |
| Medium | 13,867 | 797 | 5.75% |
| Low | 25,605 | 174 | 0.68% |

Users in the high-engagement group had a substantially higher subscription conversion rate than users in the low-engagement group.



# 💡 Business Recommendations

The following recommendations are based on the analytical findings and focus on areas where LearnFlow could improve acquisition, engagement, learning outcomes, subscription conversion and marketing efficiency.

1. Strengthen High-Performing Acquisition Channels

Organic Search is the largest source of new users, while Instagram has the highest subscription conversion rate among acquisition channels.

Recommendation:

- Continue investing in Organic Search to maintain acquisition volume.
- Evaluate opportunities to scale Instagram while monitoring whether its stronger conversion rate is sustained.
- Evaluate acquisition channels using both user volume and downstream subscription conversion.

2. Focus on Engagement as a Subscription Opportunity

Highly engaged users have a substantially higher subscription conversion rate than low-engagement users.

Recommendation:

- Identify highly engaged users who have not yet subscribed.
- Test targeted subscription messaging for users demonstrating strong learning activity.
- Use engagement signals to prioritize potential conversion opportunities.

3. Investigate Low-Progress Courses

Some courses have substantial learner participation but comparatively low learner progress.

Recommendation:

- Review lesson structure, lesson length and learner drop-off for below-benchmark courses.
- Prioritize high-participation, low-progress courses for further investigation.
- Measure learner progress after content or user-experience improvements.

4. Improve Lesson Completion

The largest sequential funnel drop-off occurs between lesson start and lesson completion.

Recommendation:

- Investigate where learners abandon lessons.
- Review lesson length, content structure and learning experience.
- Test improvements such as clearer progress indicators or shorter learning units.

5. Monitor Subscription Health

A meaningful share of subscription records are cancelled, while ended subscriptions have an average duration of approximately 60 days.

Recommendation:

- Analyze cancellation patterns by acquisition channel, user segment and engagement level.
- Identify characteristics associated with earlier cancellations.
- Use these patterns to inform future retention initiatives.

6. Optimize Marketing Efficiency

Referral has the lowest CPC, while Organic Search combines strong CTR with relatively low CPC.

Recommendation:

- Continue monitoring CPC and CTR by marketing channel.
- Investigate the higher CPC observed for Paid Search.
- Evaluate marketing channels using downstream conversion or revenue metrics when reliable user-level attribution becomes available.


---

🏁 Conclusion

This project provides an end-to-end view of LearnFlow's business performance across user acquisition, engagement, learning behavior, subscription conversion, and marketing efficiency.

The strongest business signal is the relationship between user engagement and subscription conversion. Highly engaged users show substantially higher subscription conversion than less engaged users, making engagement an important area for further product and growth analysis.

The learning funnel also highlights an opportunity to improve the transition from lesson start to lesson completion, while courses with below-benchmark progress provide potential targets for learning-experience improvements.

Overall, the analysis demonstrates how data quality, transformation, SQL analysis, and business-focused interpretation can be combined to identify actionable opportunities for LearnFlow's growth and learner experience.
