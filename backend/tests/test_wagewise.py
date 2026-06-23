"""
WageWise Comprehensive Test Suite
Covers: unit tests for pure functions + integration tests for all API endpoints.
Run from backend/ directory: pytest tests/test_wagewise.py -v
"""

import sys
import os
import io

# Ensure backend/ is on the path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import pytest
from fastapi.testclient import TestClient

# ─── App import ──────────────────────────────────────────────────────────────
from main import app

client = TestClient(app)

# =============================================================================
# SECTION 1 – Health Check
# =============================================================================

class TestHealthEndpoint:
    """TC-HEALTH-*: /health endpoint"""

    def test_health_returns_200(self):
        r = client.get("/health")
        assert r.status_code == 200, "Health endpoint must return 200"

    def test_health_body_status_ok(self):
        r = client.get("/health")
        assert r.json()["status"] == "ok"

    def test_health_body_has_version(self):
        r = client.get("/health")
        assert "version" in r.json()


# =============================================================================
# SECTION 2 – Cost-of-Living: Pure Function Unit Tests
# =============================================================================

from services.col_service import calc_epf, calc_socso, calc_income_tax

class TestCalcEPF:
    """TC-EPF-*: Employee EPF contribution (11%)"""

    def test_epf_standard_salary(self):
        assert calc_epf(4000) == 440.0

    def test_epf_exact_minimum_wage(self):
        assert calc_epf(1700) == pytest.approx(187.0, rel=1e-4)

    def test_epf_zero(self):
        assert calc_epf(0) == 0.0

    def test_epf_high_salary(self):
        assert calc_epf(10000) == pytest.approx(1100.0, rel=1e-4)

    def test_epf_fractional_result_rounded(self):
        result = calc_epf(1501)
        assert result == round(1501 * 0.11, 2)


class TestCalcSOCSO:
    """TC-SOCSO-*: Employee SOCSO contribution (0.5%, capped RM 29.75)"""

    def test_socso_below_cap(self):
        # 4000 * 0.005 = 20.0 (below cap)
        assert calc_socso(4000) == 20.0

    def test_socso_at_cap_boundary(self):
        # 5950 * 0.005 = 29.75 (exactly at cap)
        assert calc_socso(5950) == 29.75

    def test_socso_above_cap(self):
        # 10000 * 0.005 = 50.0 → capped at 29.75
        assert calc_socso(10000) == 29.75

    def test_socso_minimum_wage(self):
        assert calc_socso(1700) == pytest.approx(8.5, rel=1e-4)

    def test_socso_zero(self):
        assert calc_socso(0) == 0.0


class TestCalcIncomeTax:
    """TC-TAX-*: Simplified PCB monthly income tax"""

    def test_tax_below_threshold(self):
        # Annual <= 35000 → 0 tax
        assert calc_income_tax(2916) == 0.0  # 2916*12=34992

    def test_tax_exactly_at_35k_annual(self):
        assert calc_income_tax(35000 / 12) == 0.0

    def test_tax_bracket_35k_to_50k(self):
        # Gross=3500/month → annual=42000
        # taxable = 42000-35000=7000; tax = 7000*0.08/12 = 46.67
        result = calc_income_tax(3500)
        expected = round((7000 * 0.08) / 12, 2)
        assert result == expected

    def test_tax_bracket_50k_to_70k(self):
        # Gross=5000/month → annual=60000
        # taxable = 60000-50000=10000; tax = (1200 + 10000*0.14)/12 = 216.67
        result = calc_income_tax(5000)
        expected = round((1200 + 10000 * 0.14) / 12, 2)
        assert result == expected

    def test_tax_bracket_70k_to_100k(self):
        # Gross=7000/month → annual=84000
        # taxable = 84000-70000=14000; tax = (4000 + 14000*0.21)/12 = 578.33
        result = calc_income_tax(7000)
        expected = round((4000 + 14000 * 0.21) / 12, 2)
        assert result == expected

    def test_tax_bracket_above_100k(self):
        # Gross=10000/month → annual=120000
        # taxable = 120000-100000=20000; tax = (10300 + 20000*0.24)/12 = 1258.33
        result = calc_income_tax(10000)
        expected = round((10300 + 20000 * 0.24) / 12, 2)
        assert result == expected


# =============================================================================
# SECTION 3 – COL API Endpoint Tests
# =============================================================================

class TestCOLEndpoint:
    """TC-COL-*: POST /col endpoint"""

    def test_col_kl_200(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        assert r.status_code == 200

    def test_col_response_has_correct_keys(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        data = r.json()
        assert "gross_salary" in data
        assert "cities" in data
        assert "available_cities" in data

    def test_col_deductions_correct_epf(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        city = r.json()["cities"][0]
        assert city["deductions"]["epf"] == 440.0

    def test_col_deductions_correct_socso(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        city = r.json()["cities"][0]
        assert city["deductions"]["socso"] == 20.0

    def test_col_net_salary_calculation(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        city = r.json()["cities"][0]
        d = city["deductions"]
        expected_net = round(4000 - d["epf"] - d["socso"] - d["income_tax"], 2)
        assert city["deductions"]["net_salary"] == expected_net

    def test_col_sustainability_comfortable(self):
        # 8000 gross in Kota Bharu → should be comfortable
        r = client.post("/col", json={"gross_salary": 8000, "cities": ["Kota Bharu"]})
        city = r.json()["cities"][0]
        assert city["sustainability"] == "comfortable"

    def test_col_sustainability_deficit(self):
        # Belanjawanku KL single adult = RM 1,970 minimum decent budget.
        # Gross RM 1,500 (below minimum wage) -> net ~1,332 -> deficit vs RM 1,240 expenses.
        r = client.post("/col", json={"gross_salary": 1500, "cities": ["Kuala Lumpur"]})
        city = r.json()["cities"][0]
        assert city["sustainability"] in {"deficit", "tight"}
        assert city["meets_living_wage"] is False

    def test_col_multi_city(self):
        r = client.post("/col", json={"gross_salary": 5000, "cities": ["Kuala Lumpur", "Ipoh"]})
        assert r.status_code == 200
        assert len(r.json()["cities"]) == 2

    def test_col_unknown_city_fallback_to_kl(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["NonExistentCity"]})
        assert r.status_code == 200
        city = r.json()["cities"][0]
        # Should fall back to KL data — KL rent per Belanjawanku 2024/2025 = RM 320
        assert city["expenses"]["rent"] == 320
        assert city["city"] == "Kuala Lumpur"

    def test_col_zero_salary_rejected(self):
        r = client.post("/col", json={"gross_salary": 0, "cities": ["Kuala Lumpur"]})
        assert r.status_code == 422

    def test_col_negative_salary_rejected(self):
        r = client.post("/col", json={"gross_salary": -100, "cities": ["Kuala Lumpur"]})
        assert r.status_code == 422

    def test_col_empty_cities_rejected(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": []})
        assert r.status_code == 422

    def test_col_total_deductions_sum(self):
        r = client.post("/col", json={"gross_salary": 5000, "cities": ["Penang"]})
        d = r.json()["cities"][0]["deductions"]
        expected = round(d["epf"] + d["socso"] + d["income_tax"], 2)
        assert d["total_deductions"] == expected

    def test_col_total_expenses_sum(self):
        r = client.post("/col", json={"gross_salary": 5000, "cities": ["Penang"]})
        exp = r.json()["cities"][0]["expenses"]
        expected = round(exp["rent"] + exp["food"] + exp["transport"] + exp["utilities"] + exp["healthcare"], 2)
        assert exp["total_expenses"] == expected

    def test_col_meets_living_wage_high_salary(self):
        # 8000 gross → net ≈ 6700 which exceeds KL living wage 2900
        r = client.post("/col", json={"gross_salary": 8000, "cities": ["Kuala Lumpur"]})
        assert r.json()["cities"][0]["meets_living_wage"] is True

    def test_col_does_not_meet_living_wage_low_salary(self):
        # 1700 gross → net ≈ 1461 which is below KL living wage 2900
        r = client.post("/col", json={"gross_salary": 1700, "cities": ["Kuala Lumpur"]})
        assert r.json()["cities"][0]["meets_living_wage"] is False

    def test_col_all_eight_cities_in_available(self):
        r = client.post("/col", json={"gross_salary": 4000, "cities": ["Kuala Lumpur"]})
        available = r.json()["available_cities"]
        for city in ["Kuala Lumpur", "Penang", "Johor Bahru", "Kota Kinabalu",
                     "Kuching", "Shah Alam", "Ipoh", "Kota Bharu"]:
            assert city in available

    def test_col_disposable_income_calculation(self):
        r = client.post("/col", json={"gross_salary": 5000, "cities": ["Kuala Lumpur"]})
        city = r.json()["cities"][0]
        net = city["deductions"]["net_salary"]
        total_exp = city["expenses"]["total_expenses"]
        expected_disposable = round(net - total_exp, 2)
        assert city["disposable_income"] == expected_disposable


class TestCitiesEndpoint:
    """TC-CITIES-*: GET /col/cities"""

    def test_cities_returns_200(self):
        r = client.get("/col/cities")
        assert r.status_code == 200

    def test_cities_returns_list(self):
        r = client.get("/col/cities")
        assert isinstance(r.json()["cities"], list)

    def test_cities_has_kl(self):
        r = client.get("/col/cities")
        assert "Kuala Lumpur" in r.json()["cities"]

    def test_cities_count_eight(self):
        r = client.get("/col/cities")
        assert len(r.json()["cities"]) == 8


# =============================================================================
# SECTION 4 – Salary Prediction: Pure Function Unit Tests
# =============================================================================

from services.salary_service import _heuristic_predict, _negotiation_tip, PredictRequest

class TestHeuristicPredict:
    """TC-HEURISTIC-*: Fallback salary estimation"""

    def _make_req(self, industry="Information Technology", location="Kuala Lumpur",
                  edu="Bachelor's Degree", exp=0):
        return PredictRequest(
            job_title="Software Engineer",
            industry=industry,
            education_level=edu,
            years_experience=exp,
            location=location,
        )

    def test_heuristic_it_kl_bachelor_0yr(self):
        result = _heuristic_predict(self._make_req())
        assert result.p50 > 0
        # Software Engineer per-title base=4500, KL=1.08, Bachelor=1.0, 0yr -> 4860
        assert result.p50 == pytest.approx(4860.0, rel=1e-3)

    def test_heuristic_p25_less_than_p50(self):
        result = _heuristic_predict(self._make_req())
        assert result.p25 < result.p50

    def test_heuristic_p50_less_than_p75(self):
        result = _heuristic_predict(self._make_req())
        assert result.p50 < result.p75

    def test_heuristic_p25_is_78pct_of_p50(self):
        result = _heuristic_predict(self._make_req())
        assert result.p25 == pytest.approx(result.p50 * 0.78, rel=1e-4)

    def test_heuristic_p75_is_138pct_of_p50(self):
        result = _heuristic_predict(self._make_req())
        assert result.p75 == pytest.approx(result.p50 * 1.38, rel=1e-4)

    def test_heuristic_confidence_medium_for_known_title(self):
        # Software Engineer is in the curated catalogue -> "medium" confidence
        result = _heuristic_predict(self._make_req())
        assert result.confidence == "medium"

    def test_heuristic_confidence_low_for_unknown_title(self):
        # Title not in catalogue -> falls back to industry average -> "low"
        req = PredictRequest(
            job_title="Junior Backend Specialist",  # passes validator, not in catalogue
            industry="Information Technology",
            education_level="Bachelor's Degree",
            years_experience=0,
            location="Kuala Lumpur",
        )
        result = _heuristic_predict(req)
        assert result.confidence == "low"

    def test_heuristic_experience_bonus(self):
        r0 = _heuristic_predict(self._make_req(exp=0))
        r5 = _heuristic_predict(self._make_req(exp=5))
        # 5 years adds (200 * 5) * 1.08 (KL) = +1080 to base
        assert r5.p50 > r0.p50

    def test_heuristic_unknown_location_multiplier_1(self):
        result = _heuristic_predict(self._make_req(location="Melaka"))
        # Software Engineer base=4500, unknown loc -> mult 1.0, Bachelor=1.0
        assert result.p50 == pytest.approx(4500.0, rel=1e-3)

    def test_heuristic_masters_degree_higher_than_bachelor(self):
        b = _heuristic_predict(self._make_req(edu="Bachelor's Degree"))
        m = _heuristic_predict(self._make_req(edu="Master's Degree"))
        assert m.p50 > b.p50

    def test_heuristic_phd_highest(self):
        b = _heuristic_predict(self._make_req(edu="Bachelor's Degree"))
        p = _heuristic_predict(self._make_req(edu="PhD"))
        assert p.p50 > b.p50


class TestRequestValidation:
    """TC-VALIDATION-*: PredictRequest rejects garbage input"""

    _BASE = {
        "industry": "Information Technology",
        "education_level": "Bachelor's Degree",
        "years_experience": 0,
        "location": "Kuala Lumpur",
    }

    def test_rejects_short_title(self):
        with pytest.raises(Exception):
            PredictRequest(job_title="bla", **self._BASE)

    def test_rejects_no_vowel_title(self):
        with pytest.raises(Exception):
            PredictRequest(job_title="xyzpdfk", **self._BASE)

    def test_rejects_special_chars_only(self):
        with pytest.raises(Exception):
            PredictRequest(job_title="!@#$%^", **self._BASE)

    def test_rejects_digits_only(self):
        with pytest.raises(Exception):
            PredictRequest(job_title="12345", **self._BASE)

    def test_rejects_unknown_industry(self):
        payload = dict(self._BASE)
        payload["industry"] = "Arts"
        with pytest.raises(Exception):
            PredictRequest(job_title="Software Engineer", **payload)

    def test_accepts_canonical_title(self):
        req = PredictRequest(job_title="Software Engineer", **self._BASE)
        assert req.job_title == "Software Engineer"

    def test_accepts_others_with_reasonable_title(self):
        payload = dict(self._BASE)
        payload["industry"] = "Others"
        req = PredictRequest(job_title="Aircraft Inspector", **payload)
        assert req.job_title == "Aircraft Inspector"


class TestNegotiationTip:
    """TC-NEGTIP-*: Negotiation tip text generation"""

    def test_below_market_mentions_amount(self):
        tip = _negotiation_tip("below_market", -500, 4000)
        assert "500" in tip
        assert "4000" in tip

    def test_above_market_tip_content(self):
        tip = _negotiation_tip("above_market", 500, 4000)
        assert "above market" in tip.lower()

    def test_at_market_tip_content(self):
        tip = _negotiation_tip("at_market", 0, 4000)
        assert "market rate" in tip.lower()

    def test_below_market_returns_string(self):
        assert isinstance(_negotiation_tip("below_market", -100, 3000), str)


# =============================================================================
# SECTION 5 – Salary API Endpoint Tests
# =============================================================================

class TestPredictEndpoint:
    """TC-PREDICT-*: POST /predict"""

    _VALID_PAYLOAD = {
        "job_title": "Software Engineer",
        "industry": "Information Technology",
        "education_level": "Bachelor's Degree",
        "years_experience": 0,
        "location": "Kuala Lumpur",
    }

    def test_predict_returns_200(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert r.status_code == 200

    def test_predict_has_salary_range(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert "salary_range" in r.json()

    def test_predict_salary_range_fields(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        sr = r.json()["salary_range"]
        for field in ["p25", "p50", "p75", "confidence"]:
            assert field in sr

    def test_predict_p25_lt_p50_lt_p75(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        sr = r.json()["salary_range"]
        assert sr["p25"] < sr["p50"] < sr["p75"]

    def test_predict_all_salary_values_positive(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        sr = r.json()["salary_range"]
        assert sr["p25"] > 0
        assert sr["p50"] > 0
        assert sr["p75"] > 0

    def test_predict_echoes_job_title(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert r.json()["job_title"] == "Software Engineer"

    def test_predict_echoes_location(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert r.json()["location"] == "Kuala Lumpur"

    def test_predict_experience_exceeds_max_rejected(self):
        payload = {**self._VALID_PAYLOAD, "years_experience": 41}
        r = client.post("/predict", json=payload)
        assert r.status_code == 422

    def test_predict_negative_experience_rejected(self):
        payload = {**self._VALID_PAYLOAD, "years_experience": -1}
        r = client.post("/predict", json=payload)
        assert r.status_code == 422

    def test_predict_missing_job_title_rejected(self):
        payload = {k: v for k, v in self._VALID_PAYLOAD.items() if k != "job_title"}
        r = client.post("/predict", json=payload)
        assert r.status_code == 422

    def test_predict_missing_industry_rejected(self):
        payload = {k: v for k, v in self._VALID_PAYLOAD.items() if k != "industry"}
        r = client.post("/predict", json=payload)
        assert r.status_code == 422

    def test_predict_dataset_records_present(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert "dataset_records" in r.json()

    def test_predict_confidence_is_string(self):
        r = client.post("/predict", json=self._VALID_PAYLOAD)
        assert isinstance(r.json()["salary_range"]["confidence"], str)

    def test_predict_education_phd(self):
        payload = {**self._VALID_PAYLOAD, "education_level": "PhD"}
        r = client.post("/predict", json=payload)
        assert r.status_code == 200

    def test_predict_zero_experience(self):
        payload = {**self._VALID_PAYLOAD, "years_experience": 0}
        r = client.post("/predict", json=payload)
        assert r.status_code == 200

    def test_predict_max_experience(self):
        payload = {**self._VALID_PAYLOAD, "years_experience": 40}
        r = client.post("/predict", json=payload)
        assert r.status_code == 200


class TestEvaluateOfferEndpoint:
    """TC-OFFER-*: POST /predict/evaluate-offer"""

    _BASE = {
        "job_title": "Software Engineer",
        "industry": "Information Technology",
        "education_level": "Bachelor's Degree",
        "years_experience": 0,
        "location": "Kuala Lumpur",
    }

    def test_offer_returns_200(self):
        r = client.post("/predict/evaluate-offer?offer=4000", json=self._BASE)
        assert r.status_code == 200

    def test_offer_has_required_fields(self):
        r = client.post("/predict/evaluate-offer?offer=4000", json=self._BASE)
        for field in ["offer", "median", "difference", "status", "negotiation_tip"]:
            assert field in r.json()

    def test_offer_status_values(self):
        r = client.post("/predict/evaluate-offer?offer=4000", json=self._BASE)
        assert r.json()["status"] in ("below_market", "at_market", "above_market")

    def test_offer_very_low_is_below_market(self):
        r = client.post("/predict/evaluate-offer?offer=1000", json=self._BASE)
        assert r.json()["status"] == "below_market"

    def test_offer_very_high_is_above_market(self):
        r = client.post("/predict/evaluate-offer?offer=50000", json=self._BASE)
        assert r.json()["status"] == "above_market"

    def test_offer_difference_is_offer_minus_median(self):
        r = client.post("/predict/evaluate-offer?offer=5000", json=self._BASE)
        data = r.json()
        expected_diff = round(5000 - data["median"], 2)
        assert data["difference"] == expected_diff

    def test_offer_zero_rejected(self):
        r = client.post("/predict/evaluate-offer?offer=0", json=self._BASE)
        assert r.status_code == 422

    def test_offer_missing_param_rejected(self):
        r = client.post("/predict/evaluate-offer", json=self._BASE)
        assert r.status_code == 422

    def test_offer_negotiation_tip_is_string(self):
        r = client.post("/predict/evaluate-offer?offer=3000", json=self._BASE)
        assert isinstance(r.json()["negotiation_tip"], str)

    def test_offer_median_positive(self):
        r = client.post("/predict/evaluate-offer?offer=4000", json=self._BASE)
        assert r.json()["median"] > 0


# =============================================================================
# SECTION 6 – Chatbot API Endpoint Tests
# =============================================================================

class TestChatEndpoint:
    """TC-CHAT-*: POST /chat"""

    def test_chat_labour_rights_200(self):
        r = client.post("/chat", json={
            "query": "What is the minimum wage in Malaysia?",
            "module": "labour_rights",
        })
        assert r.status_code == 200

    def test_chat_response_has_answer(self):
        r = client.post("/chat", json={
            "query": "What is the minimum wage in Malaysia?",
            "module": "labour_rights",
        })
        assert "answer" in r.json()
        assert len(r.json()["answer"]) > 0

    def test_chat_response_has_sources(self):
        r = client.post("/chat", json={
            "query": "What is the minimum wage in Malaysia?",
            "module": "labour_rights",
        })
        assert "sources" in r.json()
        assert isinstance(r.json()["sources"], list)

    def test_chat_response_echoes_module(self):
        r = client.post("/chat", json={
            "query": "What is the minimum wage in Malaysia?",
            "module": "labour_rights",
        })
        assert r.json()["module"] == "labour_rights"

    def test_chat_negotiation_coach_200(self):
        r = client.post("/chat", json={
            "query": "I want to negotiate my salary from RM 3,000 to RM 3,500.",
            "module": "negotiation_coach",
        })
        assert r.status_code == 200

    def test_chat_contract_review_200(self):
        r = client.post("/chat", json={
            "query": "The contract says probation is 6 months with no pay.",
            "module": "contract_review",
        })
        assert r.status_code == 200

    def test_chat_invalid_module_rejected(self):
        r = client.post("/chat", json={
            "query": "Hello",
            "module": "unknown_module",
        })
        assert r.status_code == 422

    def test_chat_empty_query_rejected(self):
        r = client.post("/chat", json={
            "query": "",
            "module": "labour_rights",
        })
        assert r.status_code == 422

    def test_chat_query_too_long_rejected(self):
        r = client.post("/chat", json={
            "query": "x" * 1001,
            "module": "labour_rights",
        })
        assert r.status_code == 422

    def test_chat_with_history(self):
        r = client.post("/chat", json={
            "query": "What about overtime?",
            "module": "labour_rights",
            "history": [
                {"role": "user", "content": "What is the minimum wage?"},
                {"role": "assistant", "content": "RM 1,700 per month."},
            ],
        })
        assert r.status_code == 200

    def test_chat_answer_is_string(self):
        r = client.post("/chat", json={
            "query": "How many days annual leave?",
            "module": "labour_rights",
        })
        assert isinstance(r.json()["answer"], str)


class TestChatUploadEndpoint:
    """TC-UPLOAD-*: POST /chat/upload"""

    def test_upload_text_file(self):
        content = b"My employment contract states probation is 6 months with 50% pay."
        r = client.post(
            "/chat/upload",
            data={"query": "Is this legal?", "module": "contract_review"},
            files={"file": ("contract.txt", content, "text/plain")},
        )
        assert r.status_code == 200
        assert "answer" in r.json()

    def test_upload_no_file_still_works(self):
        r = client.post(
            "/chat/upload",
            data={"query": "What is annual leave?", "module": "labour_rights"},
        )
        assert r.status_code == 200

    def test_upload_pdf_file(self):
        # Minimal valid PDF
        minimal_pdf = b"""%PDF-1.4
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj
3 0 obj<</Type/Page/MediaBox[0 0 612 792]>>endobj
xref
0 4
0000000000 65535 f
0000000009 00000 n
0000000052 00000 n
0000000101 00000 n
trailer<</Size 4/Root 1 0 R>>
startxref
148
%%EOF"""
        r = client.post(
            "/chat/upload",
            data={"query": "Review this contract.", "module": "contract_review"},
            files={"file": ("test.pdf", minimal_pdf, "application/pdf")},
        )
        assert r.status_code == 200

    def test_upload_response_has_module(self):
        content = b"Employment contract clause text."
        r = client.post(
            "/chat/upload",
            data={"query": "What does this mean?", "module": "labour_rights"},
            files={"file": ("doc.txt", content, "text/plain")},
        )
        assert r.json()["module"] == "labour_rights"


class TestContractEndpoint:
    """TC-CONTRACT-*: POST /chat/contract"""

    def test_contract_returns_200(self):
        r = client.post("/chat/contract", json={
            "clause": "Employee shall not receive any overtime pay during probation period of 12 months."
        })
        assert r.status_code == 200

    def test_contract_response_has_answer(self):
        r = client.post("/chat/contract", json={
            "clause": "The employer may terminate employment without notice at any time."
        })
        assert "answer" in r.json()
        assert len(r.json()["answer"]) > 0

    def test_contract_clause_too_short_rejected(self):
        r = client.post("/chat/contract", json={"clause": "short"})
        assert r.status_code == 422

    def test_contract_module_is_contract_review(self):
        r = client.post("/chat/contract", json={
            "clause": "Employee must work 7 days a week with no rest day."
        })
        assert r.json()["module"] == "contract_review"

    def test_contract_clause_too_long_rejected(self):
        r = client.post("/chat/contract", json={"clause": "x" * 2001})
        assert r.status_code == 422


# =============================================================================
# SECTION 7 – Cross-Endpoint Consistency Tests
# =============================================================================

class TestCrossEndpoint:
    """TC-CROSS-*: Consistency between endpoints"""

    def test_predict_then_offer_median_matches(self):
        payload = {
            "job_title": "Accountant",
            "industry": "Business/Finance",
            "education_level": "Bachelor's Degree",
            "years_experience": 2,
            "location": "Penang",
        }
        pred_r = client.post("/predict", json=payload)
        p50 = pred_r.json()["salary_range"]["p50"]

        offer_r = client.post(f"/predict/evaluate-offer?offer={p50}", json=payload)
        assert offer_r.json()["median"] == p50

    def test_col_net_salary_vs_manual(self):
        gross = 5000
        r = client.post("/col", json={"gross_salary": gross, "cities": ["Shah Alam"]})
        d = r.json()["cities"][0]["deductions"]
        manual_net = round(gross - calc_epf(gross) - calc_socso(gross) - calc_income_tax(gross), 2)
        assert d["net_salary"] == manual_net

    def test_offer_at_p25_is_below_market(self):
        payload = {
            "job_title": "Software Engineer",
            "industry": "Information Technology",
            "education_level": "Bachelor's Degree",
            "years_experience": 0,
            "location": "Kuala Lumpur",
        }
        pred_r = client.post("/predict", json=payload)
        p25 = pred_r.json()["salary_range"]["p25"]
        offer_below_p25 = p25 - 1
        if offer_below_p25 > 0:
            offer_r = client.post(f"/predict/evaluate-offer?offer={offer_below_p25}", json=payload)
            assert offer_r.json()["status"] == "below_market"

    def test_offer_above_p75_is_above_market(self):
        payload = {
            "job_title": "Software Engineer",
            "industry": "Information Technology",
            "education_level": "Bachelor's Degree",
            "years_experience": 0,
            "location": "Kuala Lumpur",
        }
        pred_r = client.post("/predict", json=payload)
        p75 = pred_r.json()["salary_range"]["p75"]
        offer_above = p75 + 1
        offer_r = client.post(f"/predict/evaluate-offer?offer={offer_above}", json=payload)
        assert offer_r.json()["status"] == "above_market"
