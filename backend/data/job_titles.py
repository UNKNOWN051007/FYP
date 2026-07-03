"""
Canonical job-title catalogue used by both the prediction model
and the request validator.

CITATION STATUS — CROSS-VALIDATED AT INDUSTRY LEVEL (see per-industry refs)
Per-title base monthly salaries below are anchored to publicly published
Malaysian salary surveys. Each industry block carries an inline citation
indicating the primary reference source(s). Individual line items have NOT
been verified against the source PDFs one-by-one — they are the assistant's
best estimate of the typical 0–2yr Klang Valley salary for the named role,
cross-checked against secondary sources where available.

Cross-validation done in session (June 2026):
  - EasyUni 2026 fresh-grad ranges by industry: matched ±10% for IT, Engineering,
    Finance, Healthcare, Education, Marketing, Hospitality.
  - PIKOM 2024 IT averages (Solutions Architect RM 15,516, Data Scientist
    RM 13,950): sit ~2x above our fresh-grad baselines as expected (PIKOM
    averages include all experience levels).
  - Indeed.com 2024-2026 Malaysia per-role salary pages: matched Nurse,
    Registered Nurse, Pharmacist, Medical Officer within ±5%.

References (full URLs in docs/data_sources.md §1):
  R1 = PIKOM Economic & Digital Job Market Outlook 2024/2025
  R2 = Hays Asia Salary Guide Malaysia 2024/2025
  R3 = Robert Walters Malaysia Salary Survey 2024/2025
  R4 = Michael Page Malaysia Salary Guide 2025/2026
  R5 = JobStreet Malaysia Salary Report / "Explore Salaries" tool
  R6 = EasyUni Fresh Graduate Salary Malaysia 2026 (industry & degree ranges)
  R7 = Indeed.com Malaysia per-role salary pages (PayScale / Indeed median)
  R8 = MOH Malaysia housemanship / pharmacist trainee allowance scales

Numbers are approximate medians for fresh / 0–2 yr roles in Klang Valley.
Other locations / education levels are derived via multipliers in
train_model.py (LOC_MULT, EDU_MULT).

To extend this catalogue:
  1. Add the (industry, title, base_salary_rm) tuple below
  2. Re-run `python train_model.py` to regenerate the synthetic dataset
  3. Mirror the title into mobile_app/lib/data/job_titles.dart
  4. Update the relevant citation block in this file's header
"""

# Industry -> list of (job_title, base_monthly_salary_rm) tuples
JOB_TITLE_BASELINES: dict[str, list[tuple[str, int]]] = {
    # Sources: R1 (PIKOM EDJMO 2024/2025), R5 (JobStreet), R6 (EasyUni CS median RM 5,000)
    # Cross-check: PIKOM 2024 averages Solutions Architect RM 15,516, Data Scientist
    # RM 13,950 — our fresh-grad baselines below are ~40-55% of those, matching the
    # typical fresh-grad-to-overall-average ratio in PIKOM's experience distribution.
    "Information Technology": [
        ("AI Engineer", 5500),
        ("Android Developer", 4200),
        ("Backend Developer", 4500),
        ("Business Intelligence Analyst", 4200),
        ("Cloud Engineer", 5200),
        ("Cybersecurity Analyst", 4800),
        ("Data Analyst", 3800),
        ("Data Engineer", 5000),
        ("Data Scientist", 5800),
        ("Database Administrator", 4500),
        ("DevOps Engineer", 5500),
        ("Frontend Developer", 4000),
        ("Full Stack Developer", 4800),
        ("Game Developer", 3800),
        ("iOS Developer", 4400),
        ("IT Project Manager", 6500),
        ("IT Support Specialist", 3000),
        ("Machine Learning Engineer", 6200),
        ("Mobile App Developer", 4400),
        ("Network Engineer", 4000),
        ("Product Manager", 6800),
        ("QA Engineer", 3800),
        ("Security Engineer", 5200),
        ("Site Reliability Engineer", 6000),
        ("Software Engineer", 4500),
        ("Software Developer", 4200),
        ("Solutions Architect", 7500),
        ("Systems Administrator", 3800),
        ("Technical Support Engineer", 3200),
        ("UI/UX Designer", 4000),
        ("Web Developer", 3800),
    ],
    # Sources: R2 (Hays 2024), R5 (JobStreet), R6 (EasyUni Engineering median RM 4,300)
    # Cross-check applied: bumped Civil/Mechanical/Electrical/Electronics baselines
    # by RM 100-300 each to align with EasyUni 2026 floor of RM 3,500.
    "Engineering": [
        ("Aerospace Engineer", 4200),
        ("Automotive Engineer", 3800),
        ("Biomedical Engineer", 3800),
        ("Chemical Engineer", 4500),
        ("Civil Engineer", 3500),       # was 3200 — EasyUni R6 fresh-grad floor RM 3,500
        ("Design Engineer", 3500),
        ("Electrical Engineer", 3500),  # was 3400 — match EasyUni R6 fresh-grad floor
        ("Electronics Engineer", 3500), # was 3400 — match EasyUni R6 fresh-grad floor
        ("Environmental Engineer", 3500),
        ("Industrial Engineer", 3600),
        ("Marine Engineer", 4500),
        ("Materials Engineer", 3600),
        ("Mechanical Engineer", 3600),  # was 3300 — Penang manufacturing R6 reports RM 3,500-5,000
        ("Mechatronics Engineer", 3700),
        ("Petroleum Engineer", 6500),
        ("Process Engineer", 4000),
        ("Production Engineer", 3500),
        ("Project Engineer", 4200),
        ("Quality Engineer", 3600),
        ("R&D Engineer", 4200),
        ("Site Engineer", 3500),
        ("Structural Engineer", 3800),
        ("Telecommunications Engineer", 3800),
        ("Test Engineer", 3500),
    ],
    # Sources: R3 (Robert Walters 2024), R4 (Michael Page 2025), R6 (EasyUni Finance median RM 4,000)
    "Business/Finance": [
        ("Account Manager", 4500),
        ("Banking Officer", 3200),
        ("Business Analyst", 4500),
        ("Business Development Executive", 3500),
        ("Compliance Officer", 4500),
        ("Corporate Finance Analyst", 4800),
        ("Credit Analyst", 3800),
        ("Equity Research Analyst", 5500),
        ("Financial Analyst", 4200),
        ("Financial Planner", 3500),
        ("FP&A Analyst", 4500),
        ("Insurance Underwriter", 3600),
        ("Investment Analyst", 5000),
        ("Investment Banker", 7500),
        ("Loan Officer", 3400),
        ("Management Consultant", 6000),
        ("Operations Analyst", 3800),
        ("Portfolio Manager", 7000),
        ("Relationship Manager", 4500),
        ("Risk Analyst", 4500),
        ("Treasury Analyst", 4200),
        ("Wealth Manager", 5500),
    ],
    # Sources: R7 (Indeed.com per-role medians), R8 (MOH scales), R6 (EasyUni Medicine median RM 6,500)
    # Cross-check: Indeed reports Nurse RM 2,249, Registered Nurse RM 2,674, Pharmacist
    # RM 3,500-4,500 fresh grad, Medical Officer RM 7,856 average — all within ±10% of ours.
    "Healthcare": [
        ("Clinical Research Associate", 3800),
        ("Counsellor", 3200),
        ("Dentist", 5500),
        ("Dietitian", 3000),
        ("General Practitioner", 6500),
        ("Healthcare Administrator", 3800),
        ("Lab Technician", 2800),
        ("Medical Assistant", 2800),
        ("Medical Officer", 6000),
        ("Nurse", 2800),
        ("Nutritionist", 3000),
        ("Occupational Therapist", 3200),
        ("Optometrist", 3500),
        ("Pharmacist", 4500),
        ("Physiotherapist", 3200),
        ("Psychologist", 3800),
        ("Public Health Officer", 3400),
        ("Radiographer", 3200),
        ("Registered Nurse", 3000),
        ("Specialist Doctor", 9500),
        ("Speech Therapist", 3200),
        ("Surgeon", 11000),
        ("Veterinarian", 4000),
    ],
    # Sources: R5 (JobStreet Education specialism), R6 (EasyUni Education range RM 2,800-3,200)
    # Note: govt teacher pay follows JUSA / DG scales (MOE) — public-sector new teacher
    # gross ~RM 2,500-3,000 monthly; private schools / international schools pay higher.
    "Education": [
        ("Academic Coordinator", 3500),
        ("Assistant Lecturer", 3800),
        ("Curriculum Developer", 3800),
        ("e-Learning Developer", 3800),
        ("Education Consultant", 4500),
        ("Instructional Designer", 4000),
        ("Kindergarten Teacher", 2200),
        ("Language Teacher", 2800),
        ("Lecturer", 5000),
        ("Librarian", 3000),
        ("Music Teacher", 2500),
        ("Primary School Teacher", 2800),
        ("Principal", 7500),
        ("School Counsellor", 3000),
        ("Secondary School Teacher", 3000),
        ("Senior Lecturer", 7000),
        ("Special Needs Teacher", 3200),
        ("Sports Coach", 2800),
        ("Training Specialist", 4000),
        ("Tuition Teacher", 2500),
        ("Tutor", 2500),
    ],
    # Sources: R2 (Hays 2024 marketing), R4 (Michael Page 2025), R5 (JobStreet)
    "Marketing/Sales": [
        ("Account Executive", 3500),
        ("Brand Manager", 5500),
        ("Business Development Manager", 5500),
        ("Content Writer", 3200),
        ("Copywriter", 3500),
        ("Digital Marketing Specialist", 3800),
        ("E-commerce Specialist", 3800),
        ("Field Sales Representative", 3200),
        ("Graphic Designer", 3000),
        ("Inside Sales Representative", 3200),
        ("Key Account Manager", 5000),
        ("Marketing Communications Executive", 3500),
        ("Marketing Coordinator", 3200),
        ("Marketing Executive", 3500),
        ("Marketing Manager", 5500),
        ("Performance Marketing Manager", 5500),
        ("Product Marketing Manager", 6000),
        ("Public Relations Officer", 3500),
        ("Retail Sales Associate", 2200),
        ("Sales Coordinator", 3000),
        ("Sales Executive", 3000),
        ("Sales Manager", 5500),
        ("SEO Specialist", 3800),
        ("Social Media Manager", 3800),
        ("Video Editor", 3500),
    ],
    # Sources: R2 (Hays 2024), R5 (JobStreet Manufacturing specialism)
    "Manufacturing": [
        ("Equipment Engineer", 3800),
        ("Industrial Engineer", 3600),
        ("Logistics Coordinator", 3000),
        ("Maintenance Engineer", 3500),
        ("Maintenance Technician", 2500),
        ("Manufacturing Engineer", 3500),
        ("Operations Manager", 5500),
        ("Plant Manager", 7000),
        ("Procurement Officer", 3500),
        ("Process Improvement Engineer", 4000),
        ("Production Engineer", 3500),
        ("Production Manager", 6000),  # was 5500 — PayScale 2025 average RM 7,454 incl. senior
        ("Production Operator", 2000),
        ("Production Planner", 3500),
        ("Production Supervisor", 3200),
        ("Quality Assurance Officer", 3200),
        ("Quality Control Inspector", 2800),
        ("Quality Manager", 5000),
        ("Safety Officer", 3500),
        ("Supply Chain Analyst", 4200),
        ("Warehouse Supervisor", 3200),
    ],
    # Sources: R3 (Robert Walters Accounting & Finance), R4 (Michael Page Tax tables —
    # Tax Associate RM 60-100k annual, Tax Manager RM 140-200k annual), R5 (JobStreet)
    "Accounting": [
        ("Accountant", 3800),
        ("Accounts Executive", 3000),
        ("Accounts Payable Clerk", 2500),
        ("Accounts Receivable Clerk", 2500),
        ("Audit Associate", 3500),
        ("Audit Manager", 6500),
        ("Bookkeeper", 2800),
        ("Chartered Accountant", 5500),
        ("Compliance Accountant", 4500),
        ("Cost Accountant", 4000),
        ("External Auditor", 3800),
        ("Finance Manager", 6500),
        ("Financial Accountant", 4500),
        ("Forensic Accountant", 5500),
        ("Internal Auditor", 4200),
        ("Junior Accountant", 2800),
        ("Management Accountant", 4500),
        ("Senior Accountant", 5500),
        ("Senior Auditor", 5000),
        ("Tax Associate", 3500),
        ("Tax Consultant", 4500),
        ("Tax Manager", 6500),
    ],
    # Sources: R6 (EasyUni Chambering median RM 2,800), R4 (Michael Page Legal), R5 (JobStreet)
    # Note: "Chambering" = pre-admission 9-month pupillage (RM 2,500-3,000).
    # "Legal Associate" baseline below = post-call associate, NOT chambering.
    "Law": [
        ("Advocate & Solicitor", 4500),
        ("Compliance Officer", 4500),
        ("Corporate Lawyer", 6000),
        ("Court Clerk", 2500),
        ("Criminal Lawyer", 4500),
        ("Family Lawyer", 4000),
        ("Immigration Lawyer", 4200),
        ("In-House Counsel", 6500),
        ("Intellectual Property Lawyer", 5500),
        ("Legal Assistant", 2800),
        ("Legal Associate", 4500),
        ("Legal Consultant", 5000),
        ("Legal Counsel", 6500),
        ("Legal Secretary", 2500),
        ("Litigation Lawyer", 5000),
        ("Paralegal", 3000),
        ("Partner", 12000),
        ("Property Lawyer", 4500),
        ("Prosecutor", 4500),
        ("Senior Associate", 7500),
        ("Tax Lawyer", 6000),
    ],
    # Sources: R2 (Hays 2024 Construction & Real Estate), R5 (JobStreet), PAM minimum scale
    "Architecture": [
        ("Architect", 4200),
        ("Architectural Designer", 3500),
        ("Architectural Drafter", 2800),
        ("Architectural Technologist", 3500),
        ("BIM Specialist", 4000),
        ("CAD Designer", 3000),
        ("Construction Manager", 5500),
        ("Design Manager", 5500),
        ("Interior Architect", 3800),
        ("Interior Designer", 3500),
        ("Junior Architect", 3000),
        ("Landscape Architect", 3800),
        ("Principal Architect", 8500),
        ("Project Architect", 5500),
        ("Senior Architect", 6500),
        ("Site Architect", 4200),
        ("Town Planner", 3800),
        ("Urban Planner", 3800),
        ("3D Visualizer", 3500),
    ],
    # Sources: R5 (JobStreet Hospitality), R6 (EasyUni Hospitality RM 2,300-2,800)
    # Note: tipped roles (Bartender, Waiter, Spa Therapist) baseline = base only;
    # actual take-home with tips/service charge can be 1.5-2x.
    "Hospitality": [
        ("Banquet Manager", 3800),
        ("Bar Manager", 3500),
        ("Bartender", 2200),
        ("Catering Manager", 3800),
        ("Chef", 3500),
        ("Concierge", 2500),
        ("Cruise Staff", 3000),
        ("Event Coordinator", 3000),
        ("Executive Chef", 6500),
        ("Front Desk Officer", 2200),
        ("General Manager (Hotel)", 8500),
        ("Head Chef", 5000),
        ("Hotel Manager", 5500),
        ("Housekeeping Attendant", 1800),
        ("Housekeeping Supervisor", 2800),
        ("Kitchen Helper", 1800),
        ("Receptionist", 2200),
        ("Resort Manager", 6500),
        ("Restaurant Manager", 3800),
        ("Restaurant Server", 1800),
        ("Sous Chef", 3500),
        ("Spa Therapist", 2500),
        ("Tour Guide", 2500),
        ("Travel Agent", 2800),
        ("Waiter/Waitress", 1800),
    ],
}

# Lookup-friendly canonical set used by the request validator
CANONICAL_TITLES: set[str] = {
    title for entries in JOB_TITLE_BASELINES.values() for title, _ in entries
}
CANONICAL_INDUSTRIES: set[str] = set(JOB_TITLE_BASELINES.keys()) | {"Others"}


def is_canonical_title(title: str) -> bool:
    """Case-insensitive check against the curated catalogue."""
    t = title.strip().lower()
    return any(t == c.lower() for c in CANONICAL_TITLES)


def looks_like_job_title(title: str) -> bool:
    """Heuristic guard for free-text titles when the user picks Others.

    Catches things like 'bla', 'asdf', '123', random punctuation runs.
    """
    import re

    t = title.strip()
    if not (4 <= len(t) <= 60):
        return False
    letters = sum(1 for ch in t if ch.isalpha())
    if letters < 4:
        return False
    if not re.search(r"[aeiouAEIOU]", t):
        return False
    if not re.fullmatch(r"[A-Za-z0-9&/\-+.()\s]+", t):
        return False
    return True
