# StaffPulse 💚 — Anonymous Employee Wellbeing & Burnout Prevention

> **Built for the BHARATCODE HACKATHON 
> *Empowering managers to detect burnout risks early while protecting 100% of employee privacy through cryptographic anonymization and Pro analytics.*

---

## 🕊️ Elevator Pitch
In high-stress remote and hybrid teams, employees hide burnout until they quit, while managers only find out during exit interviews. **StaffPulse** fixes this broken feedback loop through a **10-second anonymous daily pulse check-in**. Employee responses are cryptographically unlinked from identity, and managers unlock real-time aggregated burnout predictions, team wellness heatmaps, and executive PDF reports through a seamless **Bharat Code Hackathon** subscription engine.

---

## 💡 Inspiration
Workplace burnout is an silent epidemic:
- **76% of employees** report experiencing burnout at least sometimes (Gallup).
- The #1 reason employees don't speak up early is **fear of negative performance evaluation or managerial retaliation**.
- Traditional HR surveys are lengthy, conducted quarterly, and suffered from low response rates (often under 25%) and dishonest answers.

We asked ourselves: *What if checking in on your mental wellbeing took only 10 seconds a day, was guaranteed to be 100% anonymous, and provided managers with predictive burnout alerts two weeks before someone burns out?*

That became the founding thesis behind **StaffPulse**.

---

## ✨ What It Does

StaffPulse delivers two tailor-made experiences:

### 1. For Employees (The Safe Haven)
- **10-Second Daily Check-in:** A fluid, 4-step micro-interaction capturing:
  1. *Mood* (5 tiers with expressive haptics & emoji dynamics)
  2. *Energy* (High, Medium, Low battery gauge)
  3. *Workload Pressure* (Light, Balanced, Heavy, Overwhelming)
  4. *Anonymous Note* (Optional unlinked qualitative context)
- **Zero Identity Linkage:** Individual answers are cryptographically tokenized with rotating HMAC-SHA256 salts. No employee name, email, or device ID is attached.
- **Personal Wellbeing History:** Employees track their personal private trajectory over time without anyone else seeing it.

### 2. For Managers & HR (The Proactive Command Center)
- **Team Wellness Score (0-100):** Real-time aggregate metric computed using our weighted wellbeing algorithm (50% mood + 30% energy + 20% inverted workload).
- **Early Burnout Detection Gauge:** Color-coded risk indicators that alert managers when stress thresholds exceed 40%.
- **7-Day & 30-Day Trend Charts:** Visualized using `fl_chart` to identify whether fatigue is acute or systemic.
- **Aggregation Threshold Guard:** To strictly protect anonymity, team insights are only revealed once at least 3 check-ins are recorded.
- **Executive PDF Report Export (Pro Feature):** One-tap branded PDF report generation with recommended manager action items to present to HR and leadership.

---

## 💰 Monetization Architecture & Revenue Implementation

StaffPulse adopts a high-conversion B2B2C Freemium model orchestrated via the **BharatCode Hackathon `purchases_flutter` SDK**.

### Pricing Tiers
| Tier | Pricing | Features Included |
| :--- | :--- | :--- |
| **Free Tier** | $0 / Free Forever | Up to 3 team members, 7-day history, basic team wellness score |
| **Pro Monthly** | **$4.99 / month** | Unlimited team members, 30-day analytics, burnout prediction alerts, executive PDF reports |
| **Pro Annual** | **$39.99 / year** *(Save 33%)* | All Pro features + priority roadmap access & multi-team management |

##-interactions that make a 10-second check-in delightful.
4. **📱 Samsung Galaxy Store Track:**  
   Strategically configured for the Samsung Galaxy Store to bypass Google Play's 14-day 20-tester closed testing delays.

---

## 🚀 Accomplishments & Challenges

- **Zero-Compromise Privacy:** Designing a system that gives managers actionable predictive data without *ever* storing a single link between an employee's identity and their answers.
- **Seamless Pro Gating:** Integrating RevenueCat offerings alongside real-time Cloud Firestore streams, ensuring instant entitlement unlocks across devices.
- **Cross-Platform PDF Generation:** Generating pixel-perfect executive PDF wellness briefs directly on-device using native Dart canvas layout without requiring backend rendering.

---

## 🔮 What's Next for StaffPulse
- **Slack & Microsoft Teams Bot Integration:** Trigger 10-second check-ins directly inside team chat channels.
- **RevenueCat Ads Integration ("Catvertising"):** Free individual users can watch 1 rewarded video ad to unlock a 48-hour deep burnout diagnostic.
- **Predictive AI Wellness Coaching:** On-device sentiment and trend analysis suggesting custom manager interventions based on anonymized workload spikes.
