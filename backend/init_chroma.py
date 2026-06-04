"""
Initialise ChromaDB vector store with Malaysian employment law content.
Run once before starting the backend: python init_chroma.py

Seeds the collection with key provisions from:
- Employment Act 1955 (EA 1955)
- Industrial Relations Act 1967 (IRA 1967)
- EPF Act 1991
- SOCSO Act 1969
- Minimum Wages Order 2022
"""

import os
import sys

import chromadb
from chromadb.utils import embedding_functions

CHROMA_DIR = os.path.join(os.path.dirname(__file__), "chroma_db")
COLLECTION_NAME = "wagewise_legal_docs"

LEGAL_DOCS = [
    # ── Employment Act 1955 ──────────────────────────────────────
    {
        "id": "ea1955_s60a",
        "title": "Employment Act 1955",
        "section": "Section 60A – Hours of Work",
        "text": (
            "Section 60A of the Employment Act 1955 stipulates that an employee shall not be "
            "required to work more than five consecutive hours without a period of rest of not "
            "less than thirty minutes. The normal hours of work shall not exceed eight hours in "
            "one day or 45 hours in one week. Overtime work is permitted but must be compensated "
            "at a rate not less than one and a half times the hourly rate of pay."
        ),
    },
    {
        "id": "ea1955_s60c",
        "title": "Employment Act 1955",
        "section": "Section 60C – Rest Days",
        "text": (
            "Section 60C of the Employment Act 1955 provides that every employee shall be entitled "
            "to one rest day per week. Where an employee is required to work on a rest day, they "
            "shall be paid at double the hourly rate for work exceeding half the normal working "
            "hours, or at two days' wages if required to work the full normal hours."
        ),
    },
    {
        "id": "ea1955_s60d",
        "title": "Employment Act 1955",
        "section": "Section 60D – Public Holidays",
        "text": (
            "Section 60D of the Employment Act 1955 entitles every employee to eleven paid public "
            "holidays in a year, of which four are compulsory (National Day, Birthday of Yang "
            "di-Pertuan Agong, Birthday of Ruler/Federal Territory Day, and Labour Day). Employees "
            "required to work on a public holiday are entitled to two days' wages in addition to "
            "their ordinary rate of pay."
        ),
    },
    {
        "id": "ea1955_s60e",
        "title": "Employment Act 1955",
        "section": "Section 60E – Annual Leave",
        "text": (
            "Section 60E of the Employment Act 1955 provides for annual leave entitlement: "
            "eight days per year for employees with less than two years of service; "
            "twelve days per year for employees with two years or more but less than five years; "
            "sixteen days per year for employees with five years or more of service. "
            "Annual leave must be taken within twelve months and cannot be forfeited without "
            "replacement payment."
        ),
    },
    {
        "id": "ea1955_s60f",
        "title": "Employment Act 1955",
        "section": "Section 60F – Sick Leave",
        "text": (
            "Section 60F of the Employment Act 1955 entitles employees to paid sick leave: "
            "fourteen days per year for those with less than two years of service; "
            "eighteen days per year for two to five years of service; "
            "twenty-two days per year for more than five years. Where hospitalisation is required, "
            "the entitlement is sixty days per year inclusive of the above."
        ),
    },
    {
        "id": "ea1955_s37",
        "title": "Employment Act 1955",
        "section": "Section 37 – Maternity Leave",
        "text": (
            "Section 37 of the Employment Act 1955 provides that every female employee is entitled "
            "to maternity leave of not less than ninety-eight consecutive days (fourteen weeks). "
            "This applies to up to five surviving children. The employee is entitled to maternity "
            "allowance at her ordinary rate of pay during this period."
        ),
    },
    {
        "id": "ea1955_s12",
        "title": "Employment Act 1955",
        "section": "Section 12 – Termination Notice",
        "text": (
            "Section 12 of the Employment Act 1955 specifies notice periods for termination of "
            "contract: four weeks for employees with less than two years of service; six weeks "
            "for two to five years; eight weeks for more than five years. Either party may "
            "terminate by paying wages in lieu of notice."
        ),
    },
    {
        "id": "ea1955_probation",
        "title": "Employment Act 1955",
        "section": "Probation Period",
        "text": (
            "The Employment Act 1955 does not explicitly define a maximum probation period, but "
            "common practice is three to six months. During probation, all statutory rights still "
            "apply including EPF, SOCSO contributions, and minimum wage. An employer cannot deny "
            "statutory benefits on the basis that an employee is on probation."
        ),
    },
    # ── Industrial Relations Act 1967 ────────────────────────────
    {
        "id": "ira1967_s20",
        "title": "Industrial Relations Act 1967",
        "section": "Section 20 – Unfair Dismissal",
        "text": (
            "Section 20 of the Industrial Relations Act 1967 protects employees from unfair "
            "dismissal. An employee who believes they have been dismissed without just cause or "
            "excuse may, within sixty days of dismissal, make a representation to the Director "
            "General of Industrial Relations. The employer must prove that dismissal was for just "
            "cause. Remedies include reinstatement or back wages."
        ),
    },
    {
        "id": "ira1967_s26",
        "title": "Industrial Relations Act 1967",
        "section": "Section 26 – Collective Agreement",
        "text": (
            "Section 26 of the Industrial Relations Act 1967 governs collective agreements between "
            "employers and trade unions. A registered collective agreement is binding on both "
            "parties. Terms of a collective agreement that are more favourable to employees "
            "override individual employment contracts."
        ),
    },
    # ── EPF Act 1991 ─────────────────────────────────────────────
    {
        "id": "epf_contribution",
        "title": "Employees Provident Fund Act 1991",
        "section": "Contribution Rates",
        "text": (
            "Under the EPF Act 1991, both employer and employee must contribute to the EPF. "
            "The employee contribution rate is 11% of monthly wages (employees below 60). "
            "The employer contribution rate is 13% for monthly wages RM5,000 and below, "
            "or 12% for wages above RM5,000. Contributions are mandatory for all Malaysian "
            "citizens and permanent residents in private employment."
        ),
    },
    # ── SOCSO Act 1969 ───────────────────────────────────────────
    {
        "id": "socso_contribution",
        "title": "SOCSO Act 1969 (PERKESO)",
        "section": "Employee Contribution",
        "text": (
            "SOCSO (Social Security Organisation) contributions are mandatory under the Employees' "
            "Social Security Act 1969 for employees earning RM4,000 or below per month. "
            "The employee contributes 0.5% of wages and the employer contributes 1.75%. "
            "SOCSO provides coverage for employment injury and invalidity. Employees earning "
            "above RM4,000 are covered under the Employment Insurance System (EIS)."
        ),
    },
    # ── Minimum Wages Order ──────────────────────────────────────
    {
        "id": "mwo_2022",
        "title": "Minimum Wages Order 2022",
        "section": "Minimum Wage Rate",
        "text": (
            "The Minimum Wages Order 2022 sets the national minimum wage at RM1,700 per month "
            "(effective 1 February 2023) for all employees in Malaysia, regardless of the number "
            "of employees in the company. Employers who fail to pay the minimum wage commit an "
            "offence under the National Wages Consultative Council Act 2011 and are liable to a "
            "fine of up to RM10,000 per employee per month."
        ),
    },
    # ── Salary negotiation tips ──────────────────────────────────
    {
        "id": "negotiation_fresh_grad",
        "title": "Salary Negotiation Guide",
        "section": "Fresh Graduate Tips",
        "text": (
            "Fresh graduates in Malaysia should research market salary ranges using platforms "
            "like Jobstreet, LinkedIn, and the WageWise salary intelligence tool. When negotiating, "
            "cite your research data, highlight internship experience and relevant projects, and "
            "express enthusiasm for the role. It is acceptable to ask for 10-15% above the "
            "initial offer. Always negotiate the full package including allowances, increment "
            "timing, and annual leave entitlement."
        ),
    },
    {
        "id": "offer_letter_checklist",
        "title": "Employment Contract Guide",
        "section": "Offer Letter Checklist",
        "text": (
            "Before signing an employment offer letter in Malaysia, verify: (1) Basic salary "
            "matches agreed amount; (2) Job title and scope are clearly defined; (3) Probation "
            "period duration (typically 3-6 months); (4) Annual leave entitlement meets EA 1955 "
            "minimums; (5) Notice period is stated; (6) EPF and SOCSO contributions are included; "
            "(7) Non-compete clause scope and duration are reasonable; (8) Overtime policy "
            "complies with Section 60A EA 1955."
        ),
    },
]


def init():
    os.makedirs(CHROMA_DIR, exist_ok=True)

    print(f"Initialising ChromaDB at {CHROMA_DIR} …")
    client = chromadb.PersistentClient(path=CHROMA_DIR)

    ef = embedding_functions.SentenceTransformerEmbeddingFunction(
        model_name="all-MiniLM-L6-v2"
    )

    collection = client.get_or_create_collection(
        name=COLLECTION_NAME,
        embedding_function=ef,
    )

    existing_ids = set(collection.get()["ids"])
    new_docs = [d for d in LEGAL_DOCS if d["id"] not in existing_ids]

    if not new_docs:
        print(f"  Collection already has {len(existing_ids)} documents. Nothing to add.")
        return

    print(f"  Adding {len(new_docs)} documents …")
    collection.add(
        ids=[d["id"] for d in new_docs],
        documents=[d["text"] for d in new_docs],
        metadatas=[{"title": d["title"], "section": d["section"]} for d in new_docs],
    )
    print(f"  Done. Collection now has {collection.count()} documents.")
    print("ChromaDB initialised successfully.")


if __name__ == "__main__":
    init()
