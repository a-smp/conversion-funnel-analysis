# Conversion Funnel Optimization | ShopNexus

# Objective
Analyze user drop-offs in the conversion funnel and test page optimizations through A/B experiments to improve engagement, reduce friction, and increase completed purchases.
<br><br>

# Business Problem

![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3](https://github.com/user-attachments/assets/5fd941ba-fbb8-437a-851e-adec77a4c8ab)

The ShopNexus e-commerce site experiences high drop-off rates across the funnel, with **87%+ of users leaving before reaching the cart page**. Even among those who initiate checkout, **76.4% abandon their cart**, indicating friction in the billing process.

💡 **How can we turn more visitors into paying customers?**\
This project aimed to increase conversions by testing two key optimizations:

1️⃣ A new landing page to improve engagement.\
2️⃣ A new billing page to streamline checkout.
<br><br>

# Schema & Analytical Framework

![c9f42076-26c3-47d2-a49a-b6e66d57745c](https://github.com/user-attachments/assets/ee7f85be-097a-471d-874f-326a0048df25)

This analysis defines the funnel stages as:\
**Home → Products → Cart → Shipping → Billing → Thank You**

### Metrics
- Sessions
- Orders
- Conversion Rate
- Bounce Rate
- Cart Abandonment Rate (CAR)
- Clickthrough Rate (or drop-off rate)
- Session Duration
- Pages per Session

### Dimensions
- Traffic Sources
- Device Type
- New/Returning Users
<br><br>

# Key Findings

## Checkout Optimization Drove the Largest Conversion Gains

The new billing page significantly improved conversions, increasing the billing-to-order conversion rate by 14%. This confirms that reducing friction in the checkout process directly leads to more completed purchases. However, cart abandonment remains high at 75.7%, indicating further checkout optimizations are needed, especially for mobile users.

![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3 (1)](https://github.com/user-attachments/assets/40a0904d-704a-460d-874b-77e06923232e)

## Landing Page Changes Negatively Impacted Paid Search Conversions

The new landing page reduced bounce rates by 5% and slightly increased engagement, but it did not lead to a meaningful increase in conversions. In fact, the lowest-performing test group (New Landing Page + Old Billing Page) had the worst conversion rate at just 2%, confirming that the update may have created friction for Paid Search visitors.

![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3 (2)](https://github.com/user-attachments/assets/8bfe70b5-a894-4e0d-b6b0-b697a153275e)

## Paid Search Traffic is High Volume but Low Quality

94% of traffic comes from Paid Search, yet it has the highest bounce rate (60%) and the lowest session engagement (under 2 pages per visit, ~2:30 min session duration). The high drop-off rate suggests that many users arrive from ads but do not find what they expect, leading to wasted ad spend and low conversions.

![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3 (3)](https://github.com/user-attachments/assets/40ee52da-41f1-4547-88e1-4d86cc19bdb9)

## Conversion Rates Vary by Traffic Source and Device

- Direct traffic converts best (5.7%), suggesting that users who actively seek out the site are more likely to complete a purchase.
- Organic search performed exceptionally well with the new billing page, improving from 1.86% → 3.93% (+111%), highlighting the impact of friction reduction.
- Desktop users convert at 4% vs. just 1% on mobile, with mobile users experiencing a 15%+ higher bounce rate and shorter session durations, indicating usability issues.

![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3 (4)](https://github.com/user-attachments/assets/144139b7-5b09-4adf-9f0c-d5dcd2563956)
<br><br>
![5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3 (5)](https://github.com/user-attachments/assets/1b1bc9f4-66fe-4d8c-b903-646331332a2c)

## Projected Impact of Scaling the Best-Performing Variation

If the Old Landing Page + New Billing Page were applied sitewide, the estimated impact would be:\
✅ +416 additional conversions\
✅ ~$20,800 in additional revenue (assuming an AOV of $49.99)
<br><br>

The impact breakdown revealed that traffic sources, device types, and A/B test results uniquely influence conversions. To ensure data-driven decisions, a dashboard was created to monitor traffic quality, track conversion performance by source and device, and measure marketing effectiveness—enabling optimizations in ad spend, mobile UX, and user engagement.

![Untitled design (28)](https://github.com/user-attachments/assets/b9754acb-edf1-40d2-9a73-1bbedaed35f8)
[View Tableau Dashboard](https://public.tableau.com/views/ShopNexusTrafficDashboard/TrafficDashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
<br><br>

# Final Recommendations & Next Steps

## 1. Improve Traffic Quality by Refining Paid Search Strategy

### Why?
Paid Search drives 94% of total traffic, yet it has the highest bounce rate (60%) and the lowest session engagement (less than 2 pages per visit, ~2:30 min session duration). The low conversion rate suggests that many visitors arriving through Paid Search are not highly motivated buyers, indicating a misalignment between ad messaging and user expectations. By refining the targeting strategy and optimizing ad-to-site alignment, we can attract higher-intent visitors, reduce wasted ad spend, and improve conversion rates.

### Actionable Next Steps:
- Refine ad targeting and audience segmentation to attract users who are more likely to convert.
- Improve ad messaging alignment with landing pages to ensure consistency between user expectations and on-site experience.
- A/B test high-intent keywords to identify which search queries drive the highest engagement.
- Shift ad budget toward higher-performing traffic sources such as Direct traffic, which converts at 5.7%.

### Impact:
By increasing the relevance and quality of Paid Search traffic, we can expect:\
✅ Lower bounce rates, as visitors find content more aligned with their intent.\
✅ Higher pages per session and session duration, leading to stronger engagement.\
✅ Increased conversion rates, driving more revenue without additional ad spend.
<br><br>

## 2. Strengthen Conversion Funnel Alignment Between Marketing & Product Teams

### Why?
The new landing page experiment decreased Paid Search conversions by 17%, confirming a misalignment between marketing campaigns and on-site experience. Additionally, Paid Search has the highest bounce rate (60%), meaning many users leave without engaging further. When ad messaging does not match what users find on the website, engagement drops, conversions suffer, and marketing spend is wasted. Strengthening collaboration between the marketing and product teams will ensure a seamless experience from acquisition to checkout, improving funnel efficiency.

### Actionable Next Steps:
- Enhance collaboration between the marketing and website teams to ensure ad messaging aligns with landing page content.
- Implement dynamic landing pages that adjust content based on search intent (e.g., promotional vs. informational users).
- A/B test value propositions and CTA placements to identify messaging that resonates best with different user segments.

### Impact:
By aligning marketing campaigns with the user journey, we can expect:\
✅ Lower Paid Search bounce rates, as visitors find more relevant content.\
✅ Smoother conversion flows, reducing drop-offs between funnel stages.\
✅ More efficient marketing spend, maximizing ROI from Paid Search campaigns.
<br><br>

## 3. Personalize the Mobile Experience to Drive Higher Engagement

### Why?
Mobile users convert at just 1% compared to 4% on desktop, making them four times less likely to complete a purchase. Additionally, mobile has a 15%+ higher bounce rate, and session durations are shorter, meaning visitors are leaving quickly without engaging. These issues suggest that the mobile experience does not effectively guide users toward completing their purchase. Personalizing the mobile journey can improve engagement and retention, ultimately increasing conversions.

### Actionable Next Steps:
- Implement personalized product recommendations based on browsing history to encourage deeper engagement.
- Optimize mobile CTAs with urgency-driven messaging (e.g., “Only 3 left in stock – Order Now”) to increase purchase intent.
- A/B test mobile-specific pop-ups offering discounts or free shipping for first-time mobile buyers to incentivize conversions.
- Improve mobile cart reminders (e.g., persistent cart that syncs across devices) to reduce friction for returning users.

### Impact:
By tailoring the mobile experience to how users actually behave, we can expect:\
✅ Lower bounce rates, as more users engage with relevant content.\
✅ Higher session duration, meaning users explore more instead of leaving quickly.\
✅ Increased mobile conversion rates, capturing revenue currently lost to low engagement and friction.
<br><br>

[Full Analysis Write-Up](https://app.kortex.co/public/document/5d04bbc6-c7f7-4d0c-8369-85dc2b41f5b3)
