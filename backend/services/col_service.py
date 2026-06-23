"""
Cost-of-Living (COL) Service
Computes EPF/SOCSO/tax deductions and district-level expense breakdowns
for Malaysian cities.

DATA SOURCE — Belanjawanku 2024/2025 (single adult, public transport user)
Published by Employees Provident Fund (EPF/KWSP) Malaysia + Social Wellbeing
Research Centre (SWRC), Universiti Malaya. Released 12 December 2024.
Booklet: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework

CITY TOTALS (LIVING_WAGE below) are TAKEN DIRECTLY from Belanjawanku 2024/2025
where the city is covered, and estimated for cities not covered (see comments).

CATEGORY BREAKDOWN (CITY_EXPENSES below) uses Belanjawanku's standard
5-category proportions derived from the published Klang Valley breakdown
(Food 29.4%, Housing 16.0%, Transport 10.7%, Utilities 5.3%, Healthcare 1.6%).
These five sum to ~63% of the full Belanjawanku budget — the remaining ~37%
covers savings, personal care, social participation, discretionary spending
and annual expenses, which are not displayed in the WageWise breakdown but
ARE included in the LIVING_WAGE benchmark.

NOTE: Belanjawanku's "Housing" line assumes shared accommodation (e.g. living
with family, or shared rental) — typical fresh-grad situation. Users renting
independently in KL should override via the API's `custom_expenses` field.

See docs/data_sources.md §3 for full citation table and verification status.
"""

from fastapi import APIRouter
from pydantic import BaseModel, Field

router = APIRouter()

# ── City expense data (RM/month) — Belanjawanku 2024/2025 proportional breakdown ──
# rent, food, transport, utilities, healthcare. See module docstring for methodology.
CITY_EXPENSES: dict[str, dict[str, float]] = {
    # Klang Valley single adult (PT) = RM 1,970 [Belanjawanku 2024/2025]
    # Sources: iMoney, WeirdKaya, Says.com, Malay Mail (all citing EPF 2024/2025)
    "Kuala Lumpur": {
        "rent": 320, "food": 580, "transport": 210,
        "utilities": 100, "healthcare": 30,
    },
    # Shah Alam falls inside the Belanjawanku "Klang Valley" region — same figures as KL
    "Shah Alam": {
        "rent": 320, "food": 580, "transport": 210,
        "utilities": 100, "healthcare": 30,
    },
    # George Town (Penang) single adult (PT) = RM 1,860 [Belanjawanku 2024/2025]
    "Penang": {
        "rent": 300, "food": 550, "transport": 200,
        "utilities": 100, "healthcare": 30,
    },
    # Johor Bahru: Belanjawanku 2022/23 = RM 1,760 + ~4% inter-edition uplift
    # = RM 1,830 estimated 2024/25. TODO: verify against Belanjawanku 2024/25 PDF
    # (single-adult JB number not surfaced in any secondary source so far).
    "Johor Bahru": {
        "rent": 290, "food": 540, "transport": 200,
        "utilities": 100, "healthcare": 30,
    },
    # Kota Kinabalu: Belanjawanku 2022/23 = RM 1,710 + ~4.7% uplift = RM 1,790 est.
    # TODO: verify against Belanjawanku 2024/25 PDF.
    "Kota Kinabalu": {
        "rent": 290, "food": 530, "transport": 190,
        "utilities": 90, "healthcare": 30,
    },
    # Ipoh: Belanjawanku 2022/23 = RM 1,680 + ~4% uplift = RM 1,750 estimated 2024/25.
    # The Kota Bharu 2024/25 figure was confirmed at +4.5% vs 2022/23, so same band assumed.
    "Ipoh": {
        "rent": 280, "food": 510, "transport": 190,
        "utilities": 90, "healthcare": 30,
    },
    # Kuching: same methodology as Ipoh — Belanjawanku 2022/23 RM 1,680 + ~4% = RM 1,750.
    "Kuching": {
        "rent": 280, "food": 510, "transport": 190,
        "utilities": 90, "healthcare": 30,
    },
    # Kota Bharu single adult (PT) = RM 1,610 [Belanjawanku 2024/2025]
    # Source: WeirdKaya / Malay Mail Dec 2024 articles citing EPF 2024/25 (range stated
    # as "RM1,610 (Kota Bharu) to RM1,970 (Klang Valley)").
    "Kota Bharu": {
        "rent": 260, "food": 470, "transport": 170,
        "utilities": 90, "healthcare": 30,
    },
}

# Living wage = full Belanjawanku 2024/2025 monthly budget (single adult, PT user)
# This is the figure WageWise compares net salary against.
LIVING_WAGE: dict[str, float] = {
    "Kuala Lumpur":   1970,  # ✅ Belanjawanku 2024/2025 Klang Valley
    "Shah Alam":      1970,  # ✅ within Klang Valley region
    "Penang":         1860,  # ✅ Belanjawanku 2024/2025 George Town
    "Johor Bahru":    1830,  # ⚠️ estimated from 2022/23 + uplift — TODO verify
    "Kota Kinabalu":  1790,  # ⚠️ estimated from 2022/23 + uplift — TODO verify
    "Ipoh":           1750,  # ⚠️ estimated from 2022/23 + uplift — TODO verify
    "Kuching":        1750,  # ⚠️ estimated from 2022/23 + uplift — TODO verify
    "Kota Bharu":     1610,  # ✅ Belanjawanku 2024/2025
}


# ── EPF / SOCSO / income tax calculators ─────────────────────

def calc_epf(gross: float) -> float:
    """Employee EPF contribution: 11% of gross."""
    return round(gross * 0.11, 2)


def calc_socso(gross: float) -> float:
    """SOCSO (PERKESO) employee contribution – capped at RM 29.75."""
    return round(min(gross * 0.005, 29.75), 2)


def calc_income_tax(gross: float) -> float:
    """Simplified monthly income tax estimate (PCB) for single individuals."""
    annual = gross * 12
    if annual <= 35000:
        return 0.0
    elif annual <= 50000:
        taxable = annual - 35000
        return round((taxable * 0.08) / 12, 2)
    elif annual <= 70000:
        taxable = annual - 50000
        return round((1200 + taxable * 0.14) / 12, 2)
    elif annual <= 100000:
        taxable = annual - 70000
        return round((4000 + taxable * 0.21) / 12, 2)
    else:
        taxable = annual - 100000
        return round((10300 + taxable * 0.24) / 12, 2)


# ── Schemas ───────────────────────────────────────────────────

class COLRequest(BaseModel):
    gross_salary: float = Field(..., gt=0, example=4000)
    cities: list[str] = Field(
        default=["Kuala Lumpur"],
        min_length=1,
        max_length=4,
    )
    custom_expenses: dict[str, float] | None = None  # override defaults


class DeductionBreakdown(BaseModel):
    epf: float
    socso: float
    income_tax: float
    total_deductions: float
    net_salary: float


class ExpenseBreakdown(BaseModel):
    rent: float
    food: float
    transport: float
    utilities: float
    healthcare: float
    total_expenses: float


class CityResult(BaseModel):
    city: str
    deductions: DeductionBreakdown
    expenses: ExpenseBreakdown
    disposable_income: float
    meets_living_wage: bool
    living_wage_benchmark: float
    sustainability: str  # "comfortable" | "tight" | "deficit"


class COLResponse(BaseModel):
    gross_salary: float
    cities: list[CityResult]
    available_cities: list[str]


# ── Routes ────────────────────────────────────────────────────

@router.post("", response_model=COLResponse)
async def evaluate_col(req: COLRequest):
    results: list[CityResult] = []

    epf = calc_epf(req.gross_salary)
    socso = calc_socso(req.gross_salary)
    tax = calc_income_tax(req.gross_salary)
    net = round(req.gross_salary - epf - socso - tax, 2)

    deductions = DeductionBreakdown(
        epf=epf,
        socso=socso,
        income_tax=tax,
        total_deductions=round(epf + socso + tax, 2),
        net_salary=net,
    )

    for city in req.cities:
        if city not in CITY_EXPENSES:
            city = "Kuala Lumpur"

        raw_exp = CITY_EXPENSES[city].copy()
        if req.custom_expenses:
            raw_exp.update(req.custom_expenses)

        total_exp = sum(raw_exp.values())
        disposable = round(net - total_exp, 2)
        lw = LIVING_WAGE.get(city, 2000)
        meets_lw = net >= lw

        if disposable > 500:
            sustainability = "comfortable"
        elif disposable >= 0:
            sustainability = "tight"
        else:
            sustainability = "deficit"

        results.append(
            CityResult(
                city=city,
                deductions=deductions,
                expenses=ExpenseBreakdown(**raw_exp, total_expenses=round(total_exp, 2)),
                disposable_income=disposable,
                meets_living_wage=meets_lw,
                living_wage_benchmark=lw,
                sustainability=sustainability,
            )
        )

    return COLResponse(
        gross_salary=req.gross_salary,
        cities=results,
        available_cities=list(CITY_EXPENSES.keys()),
    )


@router.get("/cities")
async def list_cities():
    return {"cities": list(CITY_EXPENSES.keys())}
