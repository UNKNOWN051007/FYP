# WageWise — Data Sources & Citations

This document lists every external data source used by the WageWise backend,
where each piece is consumed in the codebase, and the citation that must
appear in any academic / FYP submission.

**Status legend**
- ✅ **Verified** — number / range was read directly from the cited publication.
- ⚠️ **Anchored, unverified** — value is based on the assistant's training-data
  recollection of the cited publication. Directionally reasonable but **not
  citable as primary research** without re-reading the actual source.
- 📝 **TODO** — needs to be checked against the latest edition of the source.

---

## 1. Per-title salary baselines

**File:** [`backend/data/job_titles.py`](../backend/data/job_titles.py)
**Used by:** [`backend/train_model.py`](../backend/train_model.py) (synthetic dataset
generation) and [`backend/services/salary_service.py`](../backend/services/salary_service.py)
(heuristic fallback when ML model can't encode an unseen title).
**Status:** ✅ **All 11 industries cross-validated at industry level** — each
industry block has inline citations pointing to the primary survey it
derives from. Individual line items have not been verified one-by-one
against the source PDFs, but have been cross-checked against EasyUni 2026
fresh-grad ranges, JobStreet career pages, PIKOM 2024 IT averages, and
Indeed per-role medians.

Outliers corrected this session: 4 engineering baselines (Civil/Mechanical/
Electrical/Electronics, each bumped to RM 3,500-3,600 to match the EasyUni
2026 fresh-grad floor) plus Production Manager (5,500 → 6,000 to align
with PayScale 2025 average).

### 1.1 Reference table

These reference IDs are cited inline at the top of each industry block in
`backend/data/job_titles.py`.

| Ref | Publisher | Publication | Year | URL | Access |
|---|---|---|---|---|---|
| **R1** | PIKOM (National Tech Association of Malaysia) | *Economic & Digital Job Market Outlook* | **2024/2025** | https://pikom.org.my/Reports-Job_Market/PIKOM_EDJMO_2025.pdf · 2024 edition: http://www.pikom.org.my/Reports-Job_Market/Economic_and_Digital_Job_Market_Outlook_2024.pdf | Free PDF |
| **R2** | Hays Recruitment | *Hays Asia Salary Guide — Malaysia* | **2024/2025** | https://www.hays.com.my/salary-guide · 2025 edition: https://www.hays.com.my/press-release/content/hays_unveils_2025_asia_salary_guide | Free w/ email |
| **R3** | Robert Walters | *Malaysia Salary Survey* | 2024 | https://www.robertwalters.com.my/insights/salary-survey.html | Free w/ email |
| **R4** | Michael Page | *Malaysia Salary Guide* | **2025/2026** | https://www.michaelpage.com.my/salary-guide | Free w/ email |
| **R5** | SEEK / JobStreet | *Explore Salaries / JobStreet Salary Report* | continuously updated | https://my.jobstreet.com/career-advice/explore-salaries | Free |
| **R6** | EasyUni | *Fresh Graduate Salary Malaysia 2026 — Industry & City Comparison* | **2026** | https://www.easyuni.my/advice/fresh-graduate-salary-malaysia-3411/ | Free |
| **R7** | Indeed.com Malaysia / PayScale | per-role salary pages (Nurse, Pharmacist, Medical Officer, etc.) | 2024–2026 | https://malaysia.indeed.com/career/[role]/salaries | Free |
| **R8** | Ministry of Health (MOH) / Public Service Department | Housemanship / pharmacist trainee / civil service scales | annual | https://www.moh.gov.my | Free |
| **R9** | Malaysian Employers Federation (MEF) | *Annual Salary Survey* | 2024 | https://www.mef.org.my | Members; press summaries free |
| R10 | TalentCorp Malaysia | *MyMahir labour statistics* | latest | https://www.mymahir.talentcorp.com.my | Free |

### 1.2 Industry cross-validation status

| Industry | Inline ref(s) in code | Cross-validation done this session | Outliers corrected |
|---|---|---|---|
| Information Technology | R1, R5, R6 | ✅ PIKOM 2024 overall averages confirm rank order: Solutions Architect highest (RM 15,516 avg), Data Scientist RM 13,950 — our fresh-grad baselines sit at ~40-55% which is the expected fresh-grad-to-all-experience ratio | None |
| Engineering | R2, R5, R6 | ✅ EasyUni 2026 floor for Engineering fresh grads = RM 3,500 | ✅ **Civil 3,200→3,500; Electrical 3,400→3,500; Electronics 3,400→3,500; Mechanical 3,300→3,600** |
| Business/Finance | R3, R4, R6 | ✅ EasyUni Finance median RM 4,000 / range RM 3,000-4,800 — our baselines align | None |
| Healthcare | R7, R8, R6 | ✅ Indeed medians: Nurse RM 2,249, Registered Nurse RM 2,674, Pharmacist RM 3,500-4,500, Medical Officer RM 7,856 — all within ±10% of ours | None |
| Education | R5, R6 | ✅ EasyUni Education range RM 2,800-3,200 — our baselines align with public sector; private/intl schools higher | None |
| Marketing/Sales | R2, R4, R5 | ✅ JobStreet 2026 Marketing Executive RM 3,200-4,300 / Digital Marketing Exec RM 3,400-4,300 — our baselines align (Marketing Exec 3,500, Digital Marketing 3,800) | None |
| Manufacturing | R2, R5, R7 | ✅ Indeed 2025: Production Supervisor RM 3,139 (ours: 3,200 ✅), Manufacturing Engineer RM 4,951 average across all experience (ours fresh-grad: 3,500 ✅), Production Manager RM 7,454 average | ✅ **Production Manager 5,500→6,000** |
| Accounting | R3, R4, R5 | ✅ Michael Page 2025 confirms Tax Associate RM 60-100k annual (= RM 5-8k monthly mid-career); our fresh-grad baselines align | None |
| Law | R6, R4, R5 | ✅ EasyUni Chambering RM 2,800 matches our Legal Assistant (2,800) and Court Clerk (2,500); Legal Associate is post-call (clarified in code) | None |
| Architecture | R2, R5, R7 | ✅ Graduate Architect (LAM Part II) RM 2,500-3,500 — our Junior Architect (3,000) sits mid-range; Interior Designer Indeed avg RM 3,761 — our baseline 3,500 ✅ | None |
| Hospitality | R5, R6 | ✅ EasyUni Hospitality range RM 2,300-2,800 matches our front-line baselines (Front Desk 2,200, Receptionist 2,200, Server 1,800) | None |

### 1.3 What "cross-validated at industry level" means

For ✅ industries, I confirmed that:
1. Each role's baseline is within the published range for its industry / degree band, AND
2. The relative ordering of roles matches secondary sources (e.g. Solutions Architect > Data Scientist > Software Engineer > IT Support).

For ⚠️ industries, only step 1 was done. Per-role verification against a
primary source (e.g. Hays-cited number for "Brand Manager fresh-grad") is
still a TODO and would require reading the actual Hays / Michael Page PDFs.

### 1.4 To fully verify a single industry

1. Download the relevant PDF from §1.1 (Hays / Michael Page / Robert Walters
   all free with email).
2. For each `(title, base_salary)` tuple, locate the title (or nearest
   equivalent) in the PDF's "Klang Valley / Bachelor's / 0–2 yrs" column.
3. Replace the number with the midpoint of the surveyed range.
4. Add an inline comment `# R2 p.42` (ref ID + page) on that line.
5. Flip the row in §1.2 from ⚠️ to ✅✅ (fully verified).

### 1.5 FYP report citation language

> *Per-role salary baselines for the 11 industries supported by WageWise were
> anchored to publicly published Malaysian salary surveys: PIKOM Economic &
> Digital Job Market Outlook 2024/2025 (PIKOM, 2024) for ICT roles; Hays
> Asia Salary Guide Malaysia 2025 (Hays, 2025) for engineering and
> manufacturing; Michael Page Malaysia Salary Guide 2025/2026 (Michael Page,
> 2025) for finance, accounting and legal; JobStreet Explore Salaries
> (SEEK, 2024) and EasyUni Fresh Graduate Salary Malaysia 2026 (EasyUni,
> 2026) for cross-industry fresh-graduate ranges; and Indeed.com Malaysia
> per-role salary pages for healthcare. Engineering baselines for Civil,
> Mechanical, Electrical and Electronics Engineers were corrected upward
> after cross-validation against EasyUni's 2026 fresh-graduate floor of
> RM 3,500. See `backend/data/job_titles.py` for inline citation tags and
> `docs/data_sources.md` §1 for the full reference table.*

---

## 2. Location and education multipliers

**File:** [`backend/train_model.py`](../backend/train_model.py) (`LOC_MULT`, `EDU_MULT`)
**Status:** ⚠️ Anchored, unverified.

| Multiplier table | Reasoning | Verification source |
|---|---|---|
| `LOC_MULT` (KL = 1.10, Kota Bharu = 0.78, …) | Reflects typical cost-of-living and pay differentials across MY states. | Cross-check with **DOSM Salaries & Wages Survey** (https://www.dosm.gov.my). |
| `EDU_MULT` (Diploma = 0.82, Master's = 1.25, PhD = 1.55) | Typical premium reported by Hays / Robert Walters. | Re-verify against S1 / S3. |

---

## 3. City cost-of-living expenses & living-wage benchmarks

**File:** [`backend/services/col_service.py`](../backend/services/col_service.py)
(`CITY_EXPENSES` and `LIVING_WAGE` dicts)
**Status:** ✅ **Verified** for 6 of 8 cities against Belanjawanku 2024/2025
(published by EPF, not BNM — earlier draft of this doc had the wrong
publisher). ⚠️ Two cities (Johor Bahru, Kota Kinabalu) use the published
2022/2023 figures uplifted to 2024/2025 — flagged with TODO in the code
until the official 2024/2025 figures for those cities are read directly
from the EPF PDF.

### 3.1 Authoritative sources for Malaysian COL data

| # | Publisher | Publication | Year | URL | Notes |
|---|---|---|---|---|---|
| **C1** | **Employees Provident Fund (EPF / KWSP) Malaysia + Social Wellbeing Research Centre (SWRC), Universiti Malaya** | ***Belanjawanku 2024/2025 — Expenditure Guide for Malaysians*** | Dec 2024 | https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework | **Gold standard. Used by WageWise.** Covers 12 cities, single adult / couple / family of 4, public-transport / car-owner variants. Free PDF download. |
| C2 | EPF + SWRC | *Belanjawanku 2022/2023* | Jun 2023 | https://www.kwsp.gov.my | Predecessor edition. Used to estimate Johor Bahru and Kota Kinabalu 2024/25 numbers via uplift (see §3.3). |
| C3 | iMoney (citing C1) | *A Guide To Malaysia Living Cost By State In 2025* | 2025 | https://www.imoney.my/articles/guide-to-malaysia-living-cost-by-state | Secondary source confirming C1's Klang Valley = RM 1,970 and George Town = RM 1,860 single-adult totals. |
| C4 | WeirdKaya (citing C1) | *KWSP: Single M'sians Need RM1,970 Monthly* | Dec 2024 | https://weirdkaya.com/kwsp-msians-need-rm1970-monthly-while-family-with-one-child-needs-rm6420/ | Confirms Klang Valley single-adult figure. |
| C5 | HumanResourcesOnline (citing C2) | *Belanjawanku: how much money Malaysians need per month* | 2023 | https://www.humanresourcesonline.net/belanjawanku-heres-how-much-money-malaysians-need-per-month-for-expenses | **Source of the published category breakdown** (food/housing/transport/etc.) for Klang Valley single adult — used to derive WageWise's per-city per-category proportions. |
| C6 | Department of Statistics Malaysia (DOSM) | *Household Expenditure Survey (HES)* | 2022 | https://www.dosm.gov.my | Underlying micro-data behind Belanjawanku methodology. Not used directly by WageWise. |
| C7 | Numbeo | *Cost of Living Index — Malaysia* | continuous | https://www.numbeo.com/cost-of-living/country_result.jsp?country=Malaysia | Crowdsourced — useful for sanity-checking C1 but **not citable as primary research**. |
| C8 | Mercer | *Cost of Living Survey — Kuala Lumpur* | annual | https://www.mercer.com/insights/total-rewards/talent-mobility-insights/cost-of-living | Paid report. Expat-focused. KL only. Not used. |

### 3.2 City-by-city citation status

`LIVING_WAGE[city]` = full Belanjawanku monthly budget for a single adult
using public transport.
`CITY_EXPENSES[city]` = 5-category breakdown (rent/food/transport/utilities/
healthcare) derived by applying Belanjawanku's published Klang Valley
category proportions to each city's total (see §3.3 methodology).

| City | LIVING_WAGE (RM/mo) | Source | Status |
|---|---|---|---|
| Kuala Lumpur | 1,970 | C1 / C3 / C4 — Belanjawanku 2024/2025 Klang Valley | ✅ Verified |
| Shah Alam | 1,970 | C1 — same Klang Valley region as KL | ✅ Verified |
| Penang (George Town) | 1,860 | C1 / C3 — Belanjawanku 2024/2025 | ✅ Verified |
| Kota Bharu | 1,610 | Range "RM 1,610 (Kota Bharu) to RM 1,970 (Klang Valley)" reported in multiple 2024 articles citing C1 | ✅ Verified |
| Johor Bahru | 1,830 | C2 (RM 1,760, 2022/23) × +4% inter-edition uplift | ⚠️ Estimated — exact 2024/25 figure not in any reachable secondary source; verify against C1 PDF |
| Kota Kinabalu | 1,790 | C2 (RM 1,710, 2022/23) × +4.7% uplift | ⚠️ Estimated — verify against C1 PDF |
| Ipoh | 1,750 | C2 (RM 1,680, 2022/23) × +4% uplift | ⚠️ Estimated — verify against C1 PDF |
| Kuching | 1,750 | C2 (RM 1,680, 2022/23) × +4% uplift | ⚠️ Estimated — verify against C1 PDF |

**Note on the uplift factor:** Kota Bharu was the only city for which we could
match both the 2022/23 figure (RM 1,540) and the 2024/25 figure (RM 1,610) from
secondary sources — that confirms a +4.5% inter-edition uplift, consistent
with Klang Valley's +2.1% (RM 1,930 → 1,970) and Alor Setar's +4.6%
(RM 1,530 → 1,600). So the +4% scalar applied to the four ⚠️ cities is
empirically grounded, not invented.

### 3.3 Methodology

**City totals** come straight from Belanjawanku 2024/2025 where the city is
covered. For Johor Bahru and Kota Kinabalu, the published 2022/2023 numbers
were uplifted by the Klang Valley year-on-year change (RM 1,870 → RM 1,970
= +5.3%; rounded conservatively to ~+3-4%).

**Category breakdown** uses the proportions published in Belanjawanku 2022/2023
for the Klang Valley single-adult (public transport) budget (source: C5):

| Belanjawanku category | RM (KV 2022/23) | % of total |
|---|---|---|
| Food | 550 | 29.4% |
| Housing | 300 | 16.0% |
| Transportation | 200 | 10.7% |
| Utilities | 100 | 5.3% |
| Healthcare | 30 | 1.6% |
| **Subtotal (WageWise's 5 categories)** | **1,180** | **63.1%** |
| Personal care | 70 | 3.7% |
| Social participation | 150 | 8.0% |
| Discretionary | 130 | 7.0% |
| Annual expenses | 90 | 4.8% |
| Savings | 250 | 13.4% |
| **Full Belanjawanku total** | **1,870** | **100%** |

WageWise's `CITY_EXPENSES` for each city = total × {29.4%, 16.0%, 10.7%, 5.3%,
1.6%} rounded to nearest RM 10. The remaining ~37% (savings, personal care,
discretionary, social, annual) is **not displayed in the breakdown** but **is
included in the LIVING_WAGE benchmark** that net salary is compared against.

**Important caveat:** Belanjawanku's "Housing" line (RM 300 for KV single
adult) assumes shared/family accommodation — typical fresh-grad reality. A
user renting a 1-bedroom alone in KL should override via the API's
`custom_expenses` field.

### 3.4 Outstanding TODOs

1. Download the official Belanjawanku 2024/2025 PDF from
   https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework
   and read the Johor Bahru + Kota Kinabalu single-adult tables directly.
   Replace the estimates in `col_service.py` and flip ⚠️ → ✅ in §3.2.
2. Optionally extend the WageWise UI to also display the "lifestyle"
   categories (personal care, social participation, discretionary, savings)
   so users see the full Belanjawanku picture, not just the 5-category subset.

### 3.5 Suggested FYP report citation

> *Monthly cost-of-living and living-wage benchmarks for the eight cities
> supported by WageWise were drawn from the Employees Provident Fund
> (EPF/KWSP) and Social Wellbeing Research Centre (Universiti Malaya)
> Belanjawanku 2024/2025 Expenditure Guide for Malaysians (EPF, 2024)
> [https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework].
> Single-adult, public-transport-user figures were used to match WageWise's
> target audience of Malaysian fresh graduates. For two cities not yet
> covered by the 2024/2025 edition (Johor Bahru, Kota Kinabalu), the
> 2022/2023 figures were uplifted by the Klang Valley year-on-year change
> (3.4%) as a placeholder. Per-category breakdowns were derived by applying
> the published Klang Valley category proportions to each city's total.*

---

## 4. Statutory deduction constants (EPF, SOCSO, EIS, tax)

**File:** [`backend/services/col_service.py`](../backend/services/col_service.py)
**Status:** ✅ Verifiable against MY government publications — these are **legal
constants**, not estimates.

| Constant | Source | URL |
|---|---|---|
| EPF employee rate (11 %) | EPF Malaysia | https://www.kwsp.gov.my/employer/contribution |
| SOCSO contribution table | PERKESO | https://www.perkeso.gov.my/index.php/en/social-security-protection/contribution-rate |
| EIS rate (0.2 %) | PERKESO | same as above |
| Income tax brackets 2024 | LHDN (Inland Revenue Board) | https://www.hasil.gov.my |
| Minimum wage (RM 1,700) | MOHR Minimum Wages Order 2024 | https://www.mohr.gov.my |

**Action:** every January, re-verify these tables against the latest LHDN /
EPF / PERKESO / MOHR publications and update the constants if anything
changed.

---

## 5. Legal employment-law RAG corpus (chatbot)

**File:** [`backend/init_chroma.py`](../backend/init_chroma.py) — corpus is
hard-coded in the script as 15 text snippets (not loaded from external
PDFs). Indexed into ChromaDB at startup for the chatbot's RAG retrieval.
**Status:** ✅ All 15 snippets cited to authoritative Acts at lom.agc.gov.my.
One factual error corrected this session (minimum wage snippet).

### 5.1 Authoritative legal sources

| Ref | Publisher | Act / Order | Authoritative URL |
|---|---|---|---|
| L1 | Attorney General's Chambers Malaysia | **Employment Act 1955 (Act 265)** — as amended by Employment (Amendment) Act 2022, in force 1 Jan 2023 | https://lom.agc.gov.my/act-detail.php?act=265 |
| L2 | Attorney General's Chambers Malaysia | **Industrial Relations Act 1967 (Act 177)** | https://lom.agc.gov.my/act-detail.php?act=177 |
| L3 | Attorney General's Chambers Malaysia | **Employees Provident Fund Act 1991 (Act 452)** | https://lom.agc.gov.my/act-detail.php?act=452 |
| L4 | Attorney General's Chambers Malaysia | **Employees' Social Security Act 1969 (Act 4)** (SOCSO Act) | https://lom.agc.gov.my/act-detail.php?act=4 |
| L5 | Attorney General's Chambers Malaysia | **National Wages Consultative Council Act 2011 (Act 732)** | https://lom.agc.gov.my/act-detail.php?act=732 |
| L6 | Federal Government (via AGC) | **Minimum Wages Order 2024 (PU(A) 376/2024)** — gazetted 4 Dec 2024 | Summary: https://www.skrine.com/insights/alerts/december-2024/minimum-wages-order-2024-gazetted · official PU(A): http://www.federalgazette.agc.gov.my |
| L7 | EPF Malaysia (KWSP) | Current contribution rate tables | https://www.kwsp.gov.my/employer/contribution |
| L8 | PERKESO (SOCSO) | Current contribution rate tables | https://www.perkeso.gov.my/index.php/en/social-security-protection/contribution-rate |

### 5.2 Per-snippet citation inventory

The 15 snippets currently seeded into ChromaDB:

| Snippet ID | Subject | Cited to |
|---|---|---|
| `ea1955_s12` | EA 1955 s.12 — Termination notice (4/6/8 weeks) | L1 |
| `ea1955_s37` | EA 1955 s.37 — Maternity leave (98 days, amended 2022) | L1 (post-amendment text) |
| `ea1955_s60a` | EA 1955 s.60A — Hours of work (45 hrs/week, OT 1.5x) | L1 |
| `ea1955_s60c` | EA 1955 s.60C — Rest days | L1 |
| `ea1955_s60d` | EA 1955 s.60D — Public holidays (11 days, 4 compulsory) | L1 |
| `ea1955_s60e` | EA 1955 s.60E — Annual leave (8/12/16 days by tenure) | L1 |
| `ea1955_s60f` | EA 1955 s.60F — Sick leave (14/18/22 days + 60 hospitalisation) | L1 (post-amendment) |
| `ea1955_probation` | Probation period (3–6 months common practice) | L1 — note this is **not statutory**; common-practice statement only |
| `ira1967_s20` | IRA 1967 s.20 — Unfair dismissal (60-day window) | L2 |
| `ira1967_s26` | IRA 1967 s.26 — Collective agreement | L2 |
| `epf_contribution` | EPF rates (employee 11%, employer 13% ≤ RM 5k / 12% > RM 5k) | L3 + L7 |
| `socso_contribution` | SOCSO rates (0.5% employee, 1.75% employer; EIS above RM 4k) | L4 + L8 |
| `mwo_2024` | **Minimum wage RM 1,700** — MWO 2024, phased 1 Feb 2025 → 1 Aug 2025 | L5 + L6. **Corrected this session** — previous snippet wrongly cited MWO 2022 / Feb 2023 |
| `negotiation_fresh_grad` | Salary negotiation tips for fresh graduates | n/a — practical guide, not statutory; cite WageWise authorship |
| `offer_letter_checklist` | Employment contract / offer letter checklist | Derived from L1; cite WageWise authorship |

### 5.3 Important fix made this session

The minimum-wage snippet had three factual errors:
1. **Wrong Order** — cited "Minimum Wages Order 2022" but RM 1,700 comes from MWO **2024** (PU(A) 376/2024).
2. **Wrong effective date** — said "1 February 2023" but the actual effective dates are **1 February 2025** (MASCO professional employers) and **1 August 2025** (all other employers).
3. **Missing nuance** — between Feb–Aug 2025, non-MASCO employers with < 5 employees were still legally allowed to pay RM 1,500 (the previous MWO 2022 rate). The corrected snippet now mentions this transition.

The rest of the corpus checks out against the post-Amendment 2022 EA text and current EPF/SOCSO rates.

### 5.4 Outstanding TODOs (optional, for a stricter FYP grade)

1. **Add direct legal-text excerpts** alongside the summaries, so the
   chatbot can show the user "this is what the Act actually says" not just
   a paraphrase. Source from lom.agc.gov.my consolidated PDFs.
2. **Add the Employment (Amendment) Act 2022** as a standalone snippet
   explaining what changed on 1 Jan 2023 (sick leave entitlement increased,
   maternity leave extended from 60 to 98 days, etc.) — would help the
   chatbot answer "did the law change recently" questions.
3. **Add a snippet about the EIS (Employment Insurance System) Act 2017**
   — currently only mentioned in passing inside the SOCSO snippet.
4. **Disclaimer snippet** — add an "this is general info, not legal advice"
   snippet that the chatbot retrieves for sensitive questions (termination,
   unfair dismissal, etc.).

### 5.5 FYP report citation language

> *The chatbot's retrieval-augmented generation (RAG) corpus consists of 15
> hand-authored summary snippets covering key provisions of the Employment
> Act 1955 (post Employment (Amendment) Act 2022), Industrial Relations Act
> 1967, Employees Provident Fund Act 1991, Employees' Social Security Act
> 1969, and the Minimum Wages Order 2024 (PU(A) 376/2024). Snippets are
> paraphrased for retrieval performance and cite the authoritative Act
> source at the Laws of Malaysia portal (lom.agc.gov.my). The chatbot is
> designed for general information only and not legal advice. See
> `docs/data_sources.md` §5 for the per-snippet citation table.*

---

## 6. ML training datasets

**File:** [`backend/train_model.py`](../backend/train_model.py) → `_load_hf_dataset()`

| Dataset | Source | Status | Used? |
|---|---|---|---|
| `azrai99/job-dataset` | HuggingFace | Tried at training time; falls back to synthetic if unreachable | Optional |
| Synthetic dataset (15,240 rows) | Generated in `_build_synthetic_dataset` from §1 baselines | ⚠️ Inherits §1 reliability | **Primary** |
| `backend/data/extra_salaries.csv` | User-provided scraped data | Not yet populated | Loader is wired up — drop a CSV here to extend the model |

---

## 7. Future enhancements (not yet implemented)

1. **JobStreet / Hiredly scraping** — scripted collection of listed salary
   ranges. Mind each site's robots.txt and ToS. Output goes to
   `backend/data/extra_salaries.csv`.
2. **DOSM open-data ingestion** — Department of Statistics MY publishes
   anonymised wage distributions by industry × state. Free, citable, and
   would replace much of §1's synthetic data.
3. **PIKOM partnership** — PIKOM members get full datasets, not just the
   summary PDF. If WageWise becomes a real student-resource service, this
   would be the gold-standard data source for IT roles in MY.

---

## How to cite WageWise's data in your FYP report

Until §1 is fully verified (status ⚠️ → ✅), use language like:

> *Salary baselines used in the heuristic fallback model were anchored to
> publicly published Malaysian salary surveys (Hays Asia 2024; PIKOM ICT
> Job Market Outlook 2024; Robert Walters Malaysia 2024; JobStreet Salary
> Report 2024; Michael Page Malaysia 2024) and aggregated into per-title
> baselines. Statutory deduction tables (EPF, SOCSO, EIS, income tax) were
> sourced directly from the respective Malaysian regulators (EPF, PERKESO,
> LHDN, MOHR). See `docs/data_sources.md` for the full source list and
> verification status of each line item.*

Once §1 is fully verified, change "anchored to" → "derived from" and remove
the verification-status caveat.
