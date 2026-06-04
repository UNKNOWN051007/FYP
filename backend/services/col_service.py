"""
Cost-of-Living (COL) Service
Computes EPF/SOCSO/tax deductions and district-level expense breakdowns
for Malaysian cities based on DOSM PAKW data.
"""

from fastapi import APIRouter
from pydantic import BaseModel, Field

router = APIRouter()

# ── City expense data (RM/month) – based on DOSM PAKW index ──
CITY_EXPENSES: dict[str, dict[str, float]] = {
    "Kuala Lumpur": {
        "rent": 1400, "food": 450, "transport": 200,
        "utilities": 120, "healthcare": 80,
    },
    "Penang": {
        "rent": 900, "food": 380, "transport": 150,
        "utilities": 100, "healthcare": 70,
    },
    "Johor Bahru": {
        "rent": 850, "food": 350, "transport": 180,
        "utilities": 100, "healthcare": 70,
    },
    "Kota Kinabalu": {
        "rent": 800, "food": 320, "transport": 160,
        "utilities": 90, "healthcare": 60,
    },
    "Kuching": {
        "rent": 750, "food": 300, "transport": 150,
        "utilities": 85, "healthcare": 60,
    },
    "Shah Alam": {
        "rent": 1100, "food": 400, "transport": 190,
        "utilities": 110, "healthcare": 75,
    },
    "Ipoh": {
        "rent": 650, "food": 280, "transport": 130,
        "utilities": 80, "healthcare": 55,
    },
    "Kota Bharu": {
        "rent": 550, "food": 260, "transport": 120,
        "utilities": 75, "healthcare": 50,
    },
}

# Living wage benchmarks (net, RM/month)
LIVING_WAGE: dict[str, float] = {
    "Kuala Lumpur": 2900, "Penang": 2500, "Johor Bahru": 2200,
    "Kota Kinabalu": 2000, "Kuching": 1900, "Shah Alam": 2600,
    "Ipoh": 1800, "Kota Bharu": 1700,
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
